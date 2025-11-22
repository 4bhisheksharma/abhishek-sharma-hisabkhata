from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model
from django.utils import timezone
from .services import send_otp_email, verify_otp
from .models import OTP

User = get_user_model()


class VerifyOTPView(APIView):
    """Verify OTP for email verification"""
    
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
            
            # Get user
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return Response({
                    'status': 404,
                    'message': 'User not found',
                    'data': None
                }, status=status.HTTP_404_NOT_FOUND)
            
            # Verify OTP
            if verify_otp(user, otp_code, 'email_verification'):
                # Activate user account
                user.is_active = True
                user.is_verified = True
                user.save()
                
                return Response({
                    'status': 'success',
                    'message': 'Email verified successfully. Your account is now active.',
                    'data': {
                        'email': user.email,
                        'is_verified': user.is_verified
                    }
                }, status=status.HTTP_200_OK)
            else:
                return Response({
                    'status': 'error',
                    'message': 'Invalid or expired OTP',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            return Response({
                'status': 'error',
                'message': 'Internal server error',
                'data': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ResendOTPView(APIView):
    """Resend OTP with 1-minute cooldown"""
    
    def post(self, request):
        try:
            email = request.data.get('email')
            
            if not email:
                return Response({
                    'status': 400,
                    'message': 'Email is required',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Get user
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return Response({
                    'status': 404,
                    'message': 'User not found',
                    'data': None
                }, status=status.HTTP_404_NOT_FOUND)
            
            # Check if user is already verified
            if user.is_verified:
                return Response({
                    'status': 400,
                    'message': 'Email is already verified',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Check cooldown period (1 minute)
            last_otp = OTP.objects.filter(
                user=user, 
                purpose='email_verification'
            ).first()
            
            if last_otp and not last_otp.can_resend(cooldown_minutes=1):
                remaining_seconds = int((last_otp.last_sent_at.timestamp() + 60) - 
                                       timezone.now().timestamp())
                return Response({
                    'status': 400,
                    'message': f'Please wait {remaining_seconds} seconds before resending OTP',
                    'data': {'remaining_seconds': remaining_seconds}
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Send new OTP (this will delete old OTPs automatically)
            send_otp_email(user, 'email_verification')
            
            return Response({
                'status': 'success',
                'message': 'OTP has been resent to your email',
                'data': {'email': user.email}
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'status': 'error',
                'message': 'Internal server error',
                'data': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
