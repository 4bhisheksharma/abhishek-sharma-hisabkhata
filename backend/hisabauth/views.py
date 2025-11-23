from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import AllowAny
from hisabauth.serializer import UserSerializer, UserProfileSerializer
from hisabauth.models import User
from otp_verification.services import send_otp_email, verify_otp
from rest_framework.response import Response


class RegisterView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        try:
            data = request.data
            email = data.get('email')
            
            # Check if user already exists
            if User.objects.filter(email=email).exists():
                return Response({
                    'status': 400,
                    'message': 'User with this email already exists',
                    'data': None
                })
            
            serializer = UserSerializer(data=data)
            if serializer.is_valid():
                # Create user (is_active=False by default)
                user = serializer.save()
                
                # Send OTP for email verification
                send_otp_email(user.email, user.full_name)
                
                return Response({
                    'status': 200,
                    'message': 'Registration initiated. Please check your email for OTP to complete registration.', 
                    'data': {
                        'user_id': user.user_id,
                        'email': user.email,
                        'phone_number': user.phone_number,
                        'full_name': user.full_name
                    }
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