import uuid
import logging
import os

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db import transaction as db_transaction

from .esewa_models import BusinessEsewaAccount, EsewaPaymentRecord
from .esewa_serializers import (
    BusinessEsewaAccountSerializer,
    CreateBusinessEsewaAccountSerializer,
    InitiateEsewaPaymentSerializer,
    VerifyEsewaPaymentSerializer,
    EsewaPaymentRecordSerializer,
    BusinessEsewaStatusSerializer,
)
from .models import Transaction
from customer_dashboard.models import CustomerBusinessRelationship
from business_dashboard.models import Business
from notification.services import notify_payment_received

logger = logging.getLogger(__name__)


_ESEWA_PLACEHOLDER_VALUES = {
    '',
    'replace_me',
    'your_test_client_id',
    'your_test_secret_key',
    'your_live_client_id',
    'your_live_secret_key',
}


def _is_test_env():
    return os.getenv('ESEWA_ENV', 'test').strip().lower() == 'test'


def _esewa_client_id():
    if _is_test_env():
        # Backward compatibility with existing .env naming.
        return (
            os.getenv('ESEWA_TEST_CLIENT_ID', '').strip()
            or os.getenv('TESTCLIENTID', '').strip()
        )
    return os.getenv('ESEWA_LIVE_CLIENT_ID', '').strip()


def _esewa_secret_key():
    if _is_test_env():
        # Backward compatibility with existing .env naming.
        return (
            os.getenv('ESEWA_TEST_SECRET_KEY', '').strip()
            or os.getenv('TESTSECRETKEY', '').strip()
        )
    return os.getenv('ESEWA_LIVE_SECRET_KEY', '').strip()


def _esewa_callback_url():
    callback = os.getenv('ESEWA_CALLBACK_URL', '').strip()
    if callback:
        return callback
    return os.getenv('KHALTI_WEBSITE_URL', '').strip() or 'https://example.com'


def _is_placeholder(value):
    return (value or '').strip().lower() in _ESEWA_PLACEHOLDER_VALUES


def _validate_esewa_config():
    client_id = _esewa_client_id()
    secret_key = _esewa_secret_key()
    env_label = 'test' if _is_test_env() else 'live'

    if not client_id:
        return False, f'eSewa {env_label} client ID is not configured on the server'

    if not secret_key:
        return False, f'eSewa {env_label} secret key is not configured on the server'

    if _is_placeholder(client_id) or _is_placeholder(secret_key):
        return (
            False,
            f'eSewa {env_label} credentials are using placeholder values. Update backend .env with valid credentials.',
        )

    return True, ''


class BusinessEsewaAccountView(APIView):
    """Manage business eSewa account (GET, POST, PATCH, DELETE)"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        """Get current business's eSewa account"""
        try:
            business = Business.objects.get(user=request.user)
            try:
                account = BusinessEsewaAccount.objects.get(business=business)
                serializer = BusinessEsewaAccountSerializer(account)
                return Response({
                    'status': 200,
                    'message': 'eSewa account retrieved successfully',
                    'data': serializer.data
                }, status=status.HTTP_200_OK)
            except BusinessEsewaAccount.DoesNotExist:
                return Response({
                    'status': 200,
                    'message': 'No eSewa account linked',
                    'data': None
                }, status=status.HTTP_200_OK)
        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)

    def post(self, request):
        """Link an eSewa account to the business"""
        try:
            business = Business.objects.get(user=request.user)

            # Check if already linked
            if BusinessEsewaAccount.objects.filter(business=business).exists():
                return Response({
                    'status': 400,
                    'message': 'eSewa account already linked. Use PATCH to update.',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)

            serializer = CreateBusinessEsewaAccountSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)

            account = BusinessEsewaAccount.objects.create(
                business=business,
                esewa_id=serializer.validated_data['esewa_id'],
                account_name=serializer.validated_data['account_name'],
            )

            return Response({
                'status': 201,
                'message': 'eSewa account linked successfully',
                'data': BusinessEsewaAccountSerializer(account).data
            }, status=status.HTTP_201_CREATED)

        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)

    def patch(self, request):
        """Update the linked eSewa account"""
        try:
            business = Business.objects.get(user=request.user)
            account = BusinessEsewaAccount.objects.get(business=business)

            serializer = CreateBusinessEsewaAccountSerializer(
                data=request.data, partial=True
            )
            serializer.is_valid(raise_exception=True)

            if 'esewa_id' in serializer.validated_data:
                account.esewa_id = serializer.validated_data['esewa_id']
            if 'account_name' in serializer.validated_data:
                account.account_name = serializer.validated_data['account_name']
            account.save()

            return Response({
                'status': 200,
                'message': 'eSewa account updated successfully',
                'data': BusinessEsewaAccountSerializer(account).data
            }, status=status.HTTP_200_OK)

        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except BusinessEsewaAccount.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'No eSewa account linked',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)

    def delete(self, request):
        """Unlink the eSewa account"""
        try:
            business = Business.objects.get(user=request.user)
            account = BusinessEsewaAccount.objects.get(business=business)
            account.delete()

            return Response({
                'status': 200,
                'message': 'eSewa account unlinked successfully',
                'data': None
            }, status=status.HTTP_200_OK)

        except Business.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Business profile not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
        except BusinessEsewaAccount.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'No eSewa account linked',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)


class CheckBusinessEsewaStatusView(APIView):
    """Check if a business has an active eSewa account (for customers)"""
    permission_classes = [IsAuthenticated]

    def get(self, request, relationship_id):
        """Check eSewa status for a business in a relationship"""
        try:
            relationship = CustomerBusinessRelationship.objects.get(
                relationship_id=relationship_id
            )

            # Verify user is part of this relationship
            user = request.user
            is_customer = (
                hasattr(user, 'customer_profile')
                and relationship.customer == user.customer_profile
            )
            is_business = (
                hasattr(user, 'business_profile')
                and relationship.business == user.business_profile
            )
            if not is_customer and not is_business:
                return Response({
                    'status': 403,
                    'message': 'Access denied',
                    'data': None
                }, status=status.HTTP_403_FORBIDDEN)

            business = relationship.business
            try:
                account = BusinessEsewaAccount.objects.get(
                    business=business, is_active=True
                )
                data = {
                    'has_esewa': True,
                    'esewa_id': account.esewa_id,
                    'account_name': account.account_name,
                    'is_active': account.is_active,
                }
            except BusinessEsewaAccount.DoesNotExist:
                data = {
                    'has_esewa': False,
                    'esewa_id': None,
                    'account_name': None,
                    'is_active': False,
                }

            return Response({
                'status': 200,
                'message': 'eSewa status retrieved',
                'data': data
            }, status=status.HTTP_200_OK)

        except CustomerBusinessRelationship.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Relationship not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)


class InitiateEsewaPaymentView(APIView):
    """Initiate an eSewa payment - creates a payment record before SDK call"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        """Create a payment record and return payment params for the SDK"""
        serializer = InitiateEsewaPaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            relationship = CustomerBusinessRelationship.objects.get(
                relationship_id=data['relationship_id']
            )

            # Verify user is the customer in this relationship
            user = request.user
            if not (
                hasattr(user, 'customer_profile')
                and relationship.customer == user.customer_profile
            ):
                return Response({
                    'status': 403,
                    'message': 'Only customers can initiate eSewa payments',
                    'data': None
                }, status=status.HTTP_403_FORBIDDEN)

            # Check business has eSewa account
            try:
                esewa_account = BusinessEsewaAccount.objects.get(
                    business=relationship.business, is_active=True
                )
            except BusinessEsewaAccount.DoesNotExist:
                return Response({
                    'status': 400,
                    'message': 'This business has not linked an eSewa account',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)

            is_config_valid, config_error = _validate_esewa_config()
            if not is_config_valid:
                return Response({
                    'status': 500,
                    'message': config_error,
                    'data': None
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            # Generate unique product ID
            product_id = f"HISAB-{relationship.relationship_id}-{uuid.uuid4().hex[:8]}"

            # Create payment record
            payment_record = EsewaPaymentRecord.objects.create(
                relationship=relationship,
                amount=data['amount'],
                esewa_product_id=product_id,
                status='initiated',
            )

            return Response({
                'status': 201,
                'message': 'Payment initiated',
                'data': {
                    'payment_record_id': payment_record.id,
                    'product_id': product_id,
                    'product_name': f"Payment to {relationship.business.business_name}",
                    'amount': str(data['amount']),
                    'business_esewa_id': esewa_account.esewa_id,
                    'client_id': _esewa_client_id(),
                    'secret_key': _esewa_secret_key(),
                    'environment': 'test' if _is_test_env() else 'prod',
                    'callback_url': _esewa_callback_url(),
                }
            }, status=status.HTTP_201_CREATED)

        except CustomerBusinessRelationship.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Relationship not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)


class VerifyEsewaPaymentView(APIView):
    """Verify an eSewa payment after success callback from SDK"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        """Verify the payment and create an internal transaction"""
        serializer = VerifyEsewaPaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        try:
            payment_record = EsewaPaymentRecord.objects.get(
                id=data['payment_record_id']
            )

            if payment_record.status in ['verified', 'success']:
                return Response({
                    'status': 400,
                    'message': 'Payment already verified',
                    'data': EsewaPaymentRecordSerializer(payment_record).data
                }, status=status.HTTP_400_BAD_REQUEST)

            relationship = payment_record.relationship

            # Verify user is the customer
            user = request.user
            if not (
                hasattr(user, 'customer_profile')
                and relationship.customer == user.customer_profile
            ):
                return Response({
                    'status': 403,
                    'message': 'Access denied',
                    'data': None
                }, status=status.HTTP_403_FORBIDDEN)

            esewa_status = data.get('status', '').upper()

            if esewa_status == 'COMPLETE':
                with db_transaction.atomic():
                    # Create the internal transaction (payment type, negative amount)
                    description = f"eSewa Payment (Ref: {data['esewa_ref_id']})"
                    new_transaction = Transaction.objects.create(
                        relationship=relationship,
                        amount=-abs(payment_record.amount),
                        transaction_type='payment',
                        description=description,
                    )
                    relationship.update_pending_due()

                    # Update payment record
                    payment_record.transaction = new_transaction
                    payment_record.esewa_ref_id = data['esewa_ref_id']
                    payment_record.status = 'verified'
                    payment_record.esewa_response_data = data.get('esewa_response', {})
                    payment_record.save()

                # Send notification
                try:
                    customer_user = relationship.customer.user
                    business_user = relationship.business.user
                    notify_payment_received(
                        payer_user=customer_user,
                        business_user=business_user,
                        amount=-abs(payment_record.amount),
                        relationship_id=relationship.relationship_id,
                        via_esewa=True,
                    )
                except Exception as e:
                    logger.error(f"eSewa payment notification error: {e}")

                return Response({
                    'status': 200,
                    'message': 'Payment verified and recorded successfully',
                    'data': EsewaPaymentRecordSerializer(payment_record).data
                }, status=status.HTTP_200_OK)
            else:
                # Payment failed
                payment_record.status = 'failed'
                payment_record.esewa_ref_id = data.get('esewa_ref_id', '')
                payment_record.esewa_response_data = data.get('esewa_response', {})
                payment_record.save()

                return Response({
                    'status': 400,
                    'message': 'eSewa payment verification failed',
                    'data': EsewaPaymentRecordSerializer(payment_record).data
                }, status=status.HTTP_400_BAD_REQUEST)

        except EsewaPaymentRecord.DoesNotExist:
            return Response({
                'status': 404,
                'message': 'Payment record not found',
                'data': None
            }, status=status.HTTP_404_NOT_FOUND)
