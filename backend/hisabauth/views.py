from django.shortcuts import render
from rest_framework.views import APIView
from hisabauth.serializer import UserSerializer
from hisabauth.models import User
from otp_verification.services import send_otp_email, verify_otp
from rest_framework.response import Response


class RegisterView(APIView):
    
    def post(self, request):
        try:
            data = request.data
            
            # Check if user already exists
            if User.objects.filter(email=data.get('email')).exists():
                return Response({
                    'status': 400,
                    'message': 'User with this email already exists',
                    'data': None
                })
            
            serializer = UserSerializer(data=data)
            if serializer.is_valid():
                # Create user but keep is_active=False and is_verified=False
                user = serializer.save(commit=False)
                user.is_active = False
                user.is_verified = False
                user.save()
                
                # Send OTP for email verification
                send_otp_email(user, 'email_verification')
                
                return Response({
                    'status': 200,
                    'message': 'Registration initiated. Please check your email for OTP to complete registration.', 
                    'data': {'email': user.email}
                })
            return Response({
                'status': 400,
                'message': 'User registration failed',
                'data': serializer.errors
            })
        except Exception as e:
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            })


class VerifyOTPView(APIView):
    
    def post(self, request):
        try:
            email = request.data.get('email')
            otp_code = request.data.get('otp')
            
            if not email or not otp_code:
                return Response({
                    'status': 400,
                    'message': 'Email and OTP are required',
                    'data': None
                })
            
            # Get user
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return Response({
                    'status': 404,
                    'message': 'User not found',
                    'data': None
                })
            
            # Verify OTP
            if verify_otp(user, otp_code, 'email_verification'):
                # Activate user account
                user.is_active = True
                user.is_verified = True
                user.save()
                
                return Response({
                    'status': 200,
                    'message': 'Email verified successfully. Your account is now active.',
                    'data': {
                        'email': user.email,
                        'is_verified': user.is_verified
                    }
                })
            else:
                return Response({
                    'status': 400,
                    'message': 'Invalid or expired OTP',
                    'data': None
                })
                
        except Exception as e:
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            })