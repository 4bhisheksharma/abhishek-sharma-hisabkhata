import json
import logging
import os
import uuid
from decimal import Decimal

import requests

from django.db import transaction as db_transaction
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from business_dashboard.models import Business
from customer_dashboard.models import CustomerBusinessRelationship
from notification.services import notify_payment_received

from .khalti_models import BusinessKhaltiAccount, KhaltiPaymentRecord
from .khalti_serializers import (
    BusinessKhaltiAccountSerializer,
    CreateBusinessKhaltiAccountSerializer,
    InitiateKhaltiPaymentSerializer,
    VerifyKhaltiPaymentSerializer,
    KhaltiPaymentRecordSerializer,
)
from .models import Transaction

logger = logging.getLogger(__name__)

_KNOWN_SAMPLE_KEYS = {
    "test_secret_key_dc74e0fd57cb46cd93832aee0a390234",
    "test_public_key_dc74e0fd57cb46cd93832aee0a390234",
}


def _is_test_env():
    return os.getenv("KHALTI_ENV", "test").lower() == "test"


def _khalti_secret_key():
    if _is_test_env():
        return os.getenv("KHALTI_TEST_SECRET_KEY", "")
    return os.getenv("KHALTI_LIVE_SECRET_KEY", "")


def _khalti_public_key():
    if _is_test_env():
        return os.getenv("KHALTI_TEST_PUBLIC_KEY", "")
    return os.getenv("KHALTI_LIVE_PUBLIC_KEY", "")


def _khalti_base_url():
    override = os.getenv("KHALTI_BASE_URL", "").strip().rstrip("/")
    if override:
        return override
    return "https://dev.khalti.com" if _is_test_env() else "https://khalti.com"


def _is_sample_or_placeholder_key(value):
    normalized = (value or "").strip().lower()
    if not normalized:
        return True
    return normalized in _KNOWN_SAMPLE_KEYS or normalized in {
        "replace_me",
        "your_test_secret_key",
        "your_test_public_key",
        "your_live_secret_key",
        "your_live_public_key",
    }


def _validate_khalti_config():
    secret_key = _khalti_secret_key().strip()

    if not secret_key:
        return False, "Khalti secret key is not configured on the server"

    if _is_sample_or_placeholder_key(secret_key):
        env_label = "test" if _is_test_env() else "live"
        return (
            False,
            f"Khalti {env_label} secret key is using a sample/placeholder value. Update backend .env with a real merchant secret key.",
        )

    return True, ""


def _sanitize_customer_phone(raw_phone):
    cleaned = "".join(ch for ch in str(raw_phone or "") if ch.isdigit())
    if len(cleaned) == 10 and cleaned.startswith("9"):
        return cleaned
    return "9800000001"


def _post_json(url, payload, headers):
    response = requests.post(url, json=payload, headers=headers, timeout=20)
    response.raise_for_status()
    if not response.text:
        return {}
    return response.json()


def _extract_http_error_details(exc):
    response_body = ""
    parsed_body = {}
    message = "Khalti request failed"
    status_code = 502

    response = getattr(exc, "response", None)
    if response is not None:
        status_code = response.status_code
        response_body = response.text or ""
        try:
            parsed_body = response.json() if response_body else {}
        except ValueError:
            parsed_body = {}
    else:
        try:
            response_body = exc.read().decode("utf-8") if hasattr(exc, "read") else ""
        except Exception:  # noqa: BLE001
            response_body = ""
        status_code = getattr(exc, "code", 502)

    if response_body:
        try:
            parsed_body = parsed_body or json.loads(response_body)
            message = (
                parsed_body.get("detail")
                or parsed_body.get("message")
                or parsed_body.get("error_key")
                or message
            )
            if str(message).strip().lower() == "invalid token.":
                message = "Invalid Khalti secret key configured on server"
        except Exception:  # noqa: BLE001
            message = response_body
    else:
        message = str(exc)

    return {
        "status": status_code,
        "message": message,
        "payload": parsed_body or {"raw": response_body or str(exc)},
    }


class BusinessKhaltiAccountView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            business = Business.objects.get(user=request.user)
            try:
                account = BusinessKhaltiAccount.objects.get(business=business)
                serializer = BusinessKhaltiAccountSerializer(account)
                return Response(
                    {
                        "status": 200,
                        "message": "Khalti account retrieved successfully",
                        "data": serializer.data,
                    },
                    status=status.HTTP_200_OK,
                )
            except BusinessKhaltiAccount.DoesNotExist:
                return Response(
                    {
                        "status": 200,
                        "message": "No Khalti account linked",
                        "data": None,
                    },
                    status=status.HTTP_200_OK,
                )
        except Business.DoesNotExist:
            return Response(
                {
                    "status": 404,
                    "message": "Business profile not found",
                    "data": None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )

    def post(self, request):
        try:
            business = Business.objects.get(user=request.user)

            if BusinessKhaltiAccount.objects.filter(business=business).exists():
                return Response(
                    {
                        "status": 400,
                        "message": "Khalti account already linked. Use PATCH to update.",
                        "data": None,
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            serializer = CreateBusinessKhaltiAccountSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            account = BusinessKhaltiAccount.objects.create(
                business=business,
                khalti_id=serializer.validated_data["khalti_id"],
                account_name=serializer.validated_data["account_name"],
            )

            return Response(
                {
                    "status": 201,
                    "message": "Khalti account linked successfully",
                    "data": BusinessKhaltiAccountSerializer(account).data,
                },
                status=status.HTTP_201_CREATED,
            )
        except Business.DoesNotExist:
            return Response(
                {
                    "status": 404,
                    "message": "Business profile not found",
                    "data": None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )

    def patch(self, request):
        try:
            business = Business.objects.get(user=request.user)
            account = BusinessKhaltiAccount.objects.get(business=business)

            serializer = CreateBusinessKhaltiAccountSerializer(data=request.data, partial=True)
            serializer.is_valid(raise_exception=True)

            if "khalti_id" in serializer.validated_data:
                account.khalti_id = serializer.validated_data["khalti_id"]
            if "account_name" in serializer.validated_data:
                account.account_name = serializer.validated_data["account_name"]
            account.save()

            return Response(
                {
                    "status": 200,
                    "message": "Khalti account updated successfully",
                    "data": BusinessKhaltiAccountSerializer(account).data,
                },
                status=status.HTTP_200_OK,
            )
        except Business.DoesNotExist:
            return Response(
                {
                    "status": 404,
                    "message": "Business profile not found",
                    "data": None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )
        except BusinessKhaltiAccount.DoesNotExist:
            return Response(
                {
                    "status": 404,
                    "message": "No Khalti account linked",
                    "data": None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )

    def delete(self, request):
        try:
            business = Business.objects.get(user=request.user)
            account = BusinessKhaltiAccount.objects.get(business=business)
            account.delete()
            return Response(
                {
                    "status": 200,
                    "message": "Khalti account unlinked successfully",
                    "data": None,
                },
                status=status.HTTP_200_OK,
            )
        except Business.DoesNotExist:
            return Response(
                {
                    "status": 404,
                    "message": "Business profile not found",
                    "data": None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )
        except BusinessKhaltiAccount.DoesNotExist:
            return Response(
                {
                    "status": 404,
                    "message": "No Khalti account linked",
                    "data": None,
                },
                status=status.HTTP_404_NOT_FOUND,
            )


class CheckBusinessKhaltiStatusView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, relationship_id):
        try:
            relationship = CustomerBusinessRelationship.objects.get(
                relationship_id=relationship_id
            )

            user = request.user
            is_customer = (
                hasattr(user, "customer_profile")
                and relationship.customer == user.customer_profile
            )
            is_business = (
                hasattr(user, "business_profile")
                and relationship.business == user.business_profile
            )
            if not is_customer and not is_business:
                return Response(
                    {"status": 403, "message": "Access denied", "data": None},
                    status=status.HTTP_403_FORBIDDEN,
                )

            business = relationship.business
            try:
                account = BusinessKhaltiAccount.objects.get(
                    business=business,
                    is_active=True,
                )
                data = {
                    "has_khalti": True,
                    "khalti_id": account.khalti_id,
                    "account_name": account.account_name,
                    "is_active": account.is_active,
                }
            except BusinessKhaltiAccount.DoesNotExist:
                data = {
                    "has_khalti": False,
                    "khalti_id": None,
                    "account_name": None,
                    "is_active": False,
                }

            return Response(
                {"status": 200, "message": "Khalti status retrieved", "data": data},
                status=status.HTTP_200_OK,
            )
        except CustomerBusinessRelationship.DoesNotExist:
            return Response(
                {"status": 404, "message": "Relationship not found", "data": None},
                status=status.HTTP_404_NOT_FOUND,
            )


class InitiateKhaltiPaymentView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = InitiateKhaltiPaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            relationship = CustomerBusinessRelationship.objects.get(
                relationship_id=data["relationship_id"]
            )

            user = request.user
            if not (
                hasattr(user, "customer_profile")
                and relationship.customer == user.customer_profile
            ):
                return Response(
                    {
                        "status": 403,
                        "message": "Only customers can initiate Khalti payments",
                        "data": None,
                    },
                    status=status.HTTP_403_FORBIDDEN,
                )

            try:
                BusinessKhaltiAccount.objects.get(
                    business=relationship.business,
                    is_active=True,
                )
            except BusinessKhaltiAccount.DoesNotExist:
                return Response(
                    {
                        "status": 400,
                        "message": "This business has not linked a Khalti account",
                        "data": None,
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            is_config_valid, config_error = _validate_khalti_config()
            if not is_config_valid:
                return Response(
                    {
                        "status": 500,
                        "message": config_error,
                        "data": None,
                    },
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

            secret_key = _khalti_secret_key().strip()
            public_key = _khalti_public_key().strip()

            purchase_order_id = (
                f"HISAB-KHALTI-{relationship.relationship_id}-{uuid.uuid4().hex[:10]}"
            )

            payment_record = KhaltiPaymentRecord.objects.create(
                relationship=relationship,
                amount=data["amount"],
                purchase_order_id=purchase_order_id,
                status="initiated",
            )

            amount_paisa = int((Decimal(data["amount"]) * Decimal("100")).quantize(Decimal("1")))

            payload = {
                "return_url": os.getenv("KHALTI_RETURN_URL", "https://example.com"),
                "website_url": os.getenv("KHALTI_WEBSITE_URL", "https://example.com"),
                "amount": amount_paisa,
                "purchase_order_id": purchase_order_id,
                "purchase_order_name": (
                    data.get("description")
                    or f"Payment to {relationship.business.business_name}"
                )[:100],
                "customer_info": {
                    "name": (request.user.full_name or request.user.username or "Customer").strip(),
                    "email": (request.user.email or "customer@example.com").strip(),
                    "phone": _sanitize_customer_phone(request.user.phone_number),
                },
            }

            headers = {
                "Authorization": f"Key {secret_key}",
                "Content-Type": "application/json",
            }

            try:
                khalti_response = _post_json(
                    f"{_khalti_base_url()}/api/v2/epayment/initiate/",
                    payload,
                    headers,
                )
            except requests.HTTPError as exc:
                details = _extract_http_error_details(exc)
                response_status = details["status"]
                if response_status in [401, 403]:
                    response_status = 400
                logger.error(
                    "Khalti initiate failed with HTTP %s: %s",
                    details["status"],
                    details["message"],
                )
                payment_record.status = "failed"
                payment_record.khalti_response_data = {
                    "error": details["message"],
                    "http_status": details["status"],
                    "khalti_payload": details["payload"],
                    "phase": "initiate",
                    "request_payload": payload,
                }
                payment_record.save()
                return Response(
                    {
                        "status": response_status,
                        "message": f"Khalti initiate failed: {details['message']}",
                        "data": None,
                    },
                    status=(
                        response_status
                        if isinstance(response_status, int)
                        and response_status >= 400
                        and response_status < 600
                        else status.HTTP_502_BAD_GATEWAY
                    ),
                )
            except (requests.Timeout, requests.ConnectionError, requests.RequestException) as exc:
                logger.error("Khalti initiate network failure: %s", exc)
                payment_record.status = "failed"
                payment_record.khalti_response_data = {
                    "error": str(exc),
                    "phase": "initiate",
                    "request_payload": payload,
                }
                payment_record.save()
                return Response(
                    {
                        "status": 502,
                        "message": "Unable to reach Khalti gateway. Please try again.",
                        "data": None,
                    },
                    status=status.HTTP_502_BAD_GATEWAY,
                )

            pidx = khalti_response.get("pidx")
            if not pidx:
                payment_record.status = "failed"
                payment_record.khalti_response_data = khalti_response
                payment_record.save()
                return Response(
                    {
                        "status": 400,
                        "message": "Khalti did not return a payment identifier",
                        "data": None,
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            payment_record.pidx = pidx
            payment_record.khalti_response_data = khalti_response
            payment_record.save()

            return Response(
                {
                    "status": 201,
                    "message": "Khalti payment initiated",
                    "data": {
                        "payment_record_id": payment_record.id,
                        "pidx": pidx,
                        "public_key": public_key,
                        "environment": "test" if _is_test_env() else "prod",
                        "amount": str(data["amount"]),
                        "purchase_order_id": purchase_order_id,
                        "purchase_order_name": payload["purchase_order_name"],
                    },
                },
                status=status.HTTP_201_CREATED,
            )

        except CustomerBusinessRelationship.DoesNotExist:
            return Response(
                {"status": 404, "message": "Relationship not found", "data": None},
                status=status.HTTP_404_NOT_FOUND,
            )


class VerifyKhaltiPaymentView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = VerifyKhaltiPaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            payment_record = KhaltiPaymentRecord.objects.get(id=data["payment_record_id"])

            if payment_record.status in ["verified", "success"]:
                return Response(
                    {
                        "status": 400,
                        "message": "Payment already verified",
                        "data": KhaltiPaymentRecordSerializer(payment_record).data,
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )

            relationship = payment_record.relationship
            user = request.user
            if not (
                hasattr(user, "customer_profile")
                and relationship.customer == user.customer_profile
            ):
                return Response(
                    {"status": 403, "message": "Access denied", "data": None},
                    status=status.HTTP_403_FORBIDDEN,
                )

            secret_key = _khalti_secret_key()
            lookup_status = ""
            lookup_payload = {}

            if secret_key:
                headers = {
                    "Authorization": f"Key {secret_key}",
                    "Content-Type": "application/json",
                }
                try:
                    lookup_payload = _post_json(
                        f"{_khalti_base_url()}/api/v2/epayment/lookup/",
                        {"pidx": data["pidx"]},
                        headers,
                    )
                    lookup_status = str(lookup_payload.get("status", "")).lower()
                except Exception as exc:  # noqa: BLE001
                    logger.error("Khalti lookup failed: %s", exc)
                    lookup_payload = {"error": str(exc)}

            client_status = str(data.get("status", "")).lower()
            is_success = lookup_status == "completed" or client_status in [
                "completed",
                "complete",
                "success",
            ]

            if is_success:
                with db_transaction.atomic():
                    transaction_id = data.get("transaction_id") or lookup_payload.get(
                        "transaction_id",
                        "",
                    )
                    description = (
                        f"Khalti Payment (Ref: {transaction_id or data['pidx']})"
                    )

                    new_transaction = Transaction.objects.create(
                        relationship=relationship,
                        amount=-abs(payment_record.amount),
                        transaction_type="payment",
                        description=description,
                    )
                    relationship.update_pending_due()

                    payment_record.transaction = new_transaction
                    payment_record.pidx = data["pidx"]
                    payment_record.khalti_transaction_id = transaction_id
                    payment_record.status = "verified"
                    payment_record.khalti_response_data = {
                        "client_response": data.get("khalti_response", {}),
                        "lookup_response": lookup_payload,
                    }
                    payment_record.save()

                try:
                    notify_payment_received(
                        payer_user=relationship.customer.user,
                        business_user=relationship.business.user,
                        amount=-abs(payment_record.amount),
                        relationship_id=relationship.relationship_id,
                        via_khalti=True,
                    )
                except Exception as exc:  # noqa: BLE001
                    logger.error("Khalti payment notification error: %s", exc)

                return Response(
                    {
                        "status": 200,
                        "message": "Payment verified and recorded successfully",
                        "data": KhaltiPaymentRecordSerializer(payment_record).data,
                    },
                    status=status.HTTP_200_OK,
                )

            payment_record.status = "failed"
            payment_record.khalti_response_data = {
                "client_response": data.get("khalti_response", {}),
                "lookup_response": lookup_payload,
            }
            payment_record.save()
            return Response(
                {
                    "status": 400,
                    "message": "Khalti payment verification failed",
                    "data": KhaltiPaymentRecordSerializer(payment_record).data,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        except KhaltiPaymentRecord.DoesNotExist:
            return Response(
                {"status": 404, "message": "Payment record not found", "data": None},
                status=status.HTTP_404_NOT_FOUND,
            )
