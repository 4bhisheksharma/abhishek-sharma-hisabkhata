from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model
from django.utils import timezone
from .services import send_otp_email, verify_otp
from .models import OTP, PendingRegistration
from hisabauth.models import Role, UserRole
from customer_dashboard.models import Customer
from business_dashboard.models import Business

User = get_user_model()


class VerifyOTPView(APIView):
    """Verify OTP and complete registration"""
    
    def post(self, request):
        try:
            email = request.data.get('email')
            otp_code = request.data.get('otp')
            
            if not email or not otp_code:
                return Response({
                    'status': 400,
                    'message': 'Email and OTP are required',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Verify OTP
            otp = verify_otp(email, otp_code)
            
            if otp:
                # Get pending registration
                try:
                    pending = PendingRegistration.objects.get(email=email)
                    
                    # Check if expired
                    if pending.is_expired():
                        pending.delete()
                        return Response({
                            'status': 'error',
                            'message': 'Registration session expired. Please register again.',
                            'data': None
                        }, status=status.HTTP_400_BAD_REQUEST)
                    
                    # Get role
                    role = Role.objects.get(name__iexact=pending.role)
                    
                    # Create user
                    user = User.objects.create(
                        email=pending.email,
                        phone_number=pending.phone_number,
                        full_name=pending.full_name,
                        preferred_language=pending.preferred_language,
                        is_active=True
                    )
                    user.password = pending.password_hash
                    user.save()
                    
                    # Assign role
                    UserRole.objects.create(user=user, role=role)
                    
                    # Create profile based on role
                    if role.name.lower() == 'customer':
                        Customer.objects.create(user=user, status='active')
                    elif role.name.lower() == 'business':
                        Business.objects.create(
                            user=user,
                            business_name=pending.business_name or pending.full_name,
                            is_verified=False
                        )
                    
                    # Delete pending registration
                    pending.delete()
                    
                    return Response({
                        'status': 200,
                        'message': 'Email verified successfully. Your account is now active.',
                        'data': {
                            'email': email,
                            'phone_number': user.phone_number,
                            'is_active': user.is_active
                        }
                    }, status=status.HTTP_200_OK)
                    
                except PendingRegistration.DoesNotExist:
                    return Response({
                        'status': 404,
                        'message': 'No pending registration found for this email',
                        'data': None
                    }, status=status.HTTP_404_NOT_FOUND)
            else:
                return Response({
                    'status': 400,
                    'message': 'Invalid or expired OTP',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ResendOTPView(APIView):
    """Resend OTP with 1-minute cooldown"""
    
    def post(self, request):
        try:
            email = request.data.get('email')
            full_name = request.data.get('full_name', 'User')
            
            if not email:
                return Response({
                    'status': 400,
                    'message': 'Email is required',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Check cooldown period (1 minute)
            last_otp = OTP.objects.filter(email=email).order_by('-created_at').first()
            
            if last_otp:
                time_since_last = (timezone.now() - last_otp.created_at).total_seconds()
                if time_since_last < 60:
                    remaining_seconds = int(60 - time_since_last)
                    return Response({
                        'status': 400,
                        'message': f'Please wait {remaining_seconds} seconds before resending OTP',
                        'data': {'remaining_seconds': remaining_seconds}
                    }, status=status.HTTP_400_BAD_REQUEST)
            
            # Send new OTP
            send_otp_email(email, full_name)
            
            return Response({
                'status': 200,
                'message': 'OTP has been resent to your email',
                'data': {'email': email}
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
