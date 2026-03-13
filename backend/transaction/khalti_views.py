import json
import logging
import os
import uuid
from decimal import Decimal
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

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
    return "https://a.khalti.com" if _is_test_env() else "https://khalti.com"


def _post_json(url, payload, headers):
    data = json.dumps(payload).encode("utf-8")
    request = Request(url, data=data, headers=headers, method="POST")
    with urlopen(request, timeout=20) as response:
        body = response.read().decode("utf-8")
        return json.loads(body)


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

            secret_key = _khalti_secret_key()
            public_key = _khalti_public_key()
            if not secret_key or not public_key:
                return Response(
                    {
                        "status": 500,
                        "message": "Khalti keys are not configured on the server",
                        "data": None,
                    },
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                )

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
                    "name": request.user.full_name,
                    "email": request.user.email,
                    "phone": request.user.phone_number or "9800000001",
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
            except (HTTPError, URLError, TimeoutError) as exc:
                payment_record.status = "failed"
                payment_record.khalti_response_data = {
                    "error": str(exc),
                    "phase": "initiate",
                }
                payment_record.save()
                return Response(
                    {
                        "status": 502,
                        "message": "Unable to initiate Khalti payment",
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
