from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import AllowAny
from hisabauth.serializer import UserSerializer, UserProfileSerializer
from hisabauth.models import User, Role
from otp_verification.services import send_otp_email, verify_otp
from otp_verification.models import PendingRegistration
from rest_framework.response import Response
from django.contrib.auth.hashers import make_password


class RegisterView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        try:
            data = request.data
            email = data.get('email')
            password = data.get('password')
            full_name = data.get('full_name')
            phone_number = data.get('phone_number')
            role = data.get('role')
            business_name = data.get('business_name')
            preferred_language = data.get('preferred_language', 'en')
            
            # Check if user already exists
            if User.objects.filter(email=email).exists():
                return Response({
                    'status': 400,
                    'message': 'User with this email already exists',
                    'data': None
                })
            
            # Check if pending registration exists
            if PendingRegistration.objects.filter(email=email).exists():
                # Delete old pending registration
                PendingRegistration.objects.filter(email=email).delete()
            
            # Validate role exists
            try:
                Role.objects.get(name__iexact=role)
            except Role.DoesNotExist:
                return Response({
                    'status': 400,
                    'message': f"Role '{role}' does not exist. Valid roles are: customer, business",
                    'data': None
                })
            
            # Create pending registration
            pending = PendingRegistration.objects.create(
                email=email,
                password_hash=make_password(password),
                phone_number=phone_number,
                full_name=full_name,
                role=role,
                business_name=business_name,
                preferred_language=preferred_language
            )
            
            # Send OTP for email verification
            send_otp_email(email, full_name)
            
            return Response({
                'status': 200,
                'message': 'Registration initiated. Please check your email for OTP to complete registration.', 
                'data': {
                    'email': email,
                    'phone_number': phone_number,
                    'full_name': full_name
                }
            })
        except Exception as e:
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            })


class LoginView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        try:
            email = request.data.get('email')
            password = request.data.get('password')
            
            if not email or not password:
                return Response({
                    'status': 400,
                    'message': 'Email and password are required',
                    'data': None
                })
            
            # Authenticate user (username field is email)
            user = authenticate(request, username=email, password=password)
            
            if user is None:
                return Response({
                    'status': 401,
                    'message': 'Invalid credentials',
                    'data': None
                })
            
            if not user.is_active:
                return Response({
                    'status': 403,
                    'message': 'Please verify your email before logging in',
                    'data': None
                })
            
            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)
            
            # Get user profile data
            profile_serializer = UserProfileSerializer(user)
            
            # Return user data with tokens
            return Response({
                'status': 200,
                'message': 'Login successful',
                'data': {
                    'user': profile_serializer.data,
                    'tokens': {
                        'access': str(refresh.access_token),
                        'refresh': str(refresh),
                    }
                }
            })
            
        except Exception as e:
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            })