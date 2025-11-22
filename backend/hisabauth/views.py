from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
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


class LoginView(APIView):
    
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
            
            # Authenticate user
            user = authenticate(request, username=email, password=password)
            
            if user is None:
                return Response({
                    'status': 401,
                    'message': 'Invalid credentials',
                    'data': None
                })
            
            if not user.is_verified:
                return Response({
                    'status': 403,
                    'message': 'Please verify your email before logging in',
                    'data': None
                })
            
            # Generate JWT tokens
            refresh = RefreshToken.for_user(user)
            
            # Return user data with tokens
            return Response({
                'status': 200,
                'message': 'Login successful',
                'data': {
                    'user': {
                        'id': user.id,
                        'email': user.email,
                        'first_name': user.first_name,
                        'last_name': user.last_name,
                        'role': user.role.name if user.role else None,
                        'is_verified': user.is_verified,
                    },
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