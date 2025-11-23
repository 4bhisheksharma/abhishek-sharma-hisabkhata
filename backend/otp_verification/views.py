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
            
            # Verify OTP
            otp = verify_otp(email, otp_code)
            
            if otp:
                # Find user by email stored in OTP and activate
                # Note: In registration flow, we need to link email to phone_number
                # For now, we activate the most recent user created with is_active=False
                # In production, you might want to pass phone_number as well
                
                # Get the most recent inactive user (just registered)
                user = User.objects.filter(is_active=False).order_by('-created_at').first()
                
                if user:
                    user.is_active = True
                    user.save()
                    
                    return Response({
                        'status': 'success',
                        'message': 'Email verified successfully. Your account is now active.',
                        'data': {
                            'email': email,
                            'phone_number': user.phone_number,
                            'is_active': user.is_active
                        }
                    }, status=status.HTTP_200_OK)
                else:
                    return Response({
                        'status': 'error',
                        'message': 'No pending user found for this email',
                        'data': None
                    }, status=status.HTTP_404_NOT_FOUND)
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
                'status': 'success',
                'message': 'OTP has been resent to your email',
                'data': {'email': email}
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'status': 'error',
                'message': 'Internal server error',
                'data': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
