from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import AllowAny, IsAuthenticated
from hisabauth.serializer import UserSerializer, UserProfileSerializer
from hisabauth.models import User, Role
from otp_verification.services import send_otp_email, verify_otp
from otp_verification.models import PendingRegistration
from rest_framework.response import Response
from django.contrib.auth.hashers import make_password
from core.firebase_service import FirebaseService
import logging

logger = logging.getLogger(__name__)


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


class ChangePasswordView(APIView):
    """API endpoint for changing user password"""
    permission_classes = [AllowAny]  # Will check authentication manually
    
    def post(self, request):
        from rest_framework.permissions import IsAuthenticated
        from hisabauth.serializer import ChangePasswordSerializer
        
        # Check if user is authenticated
        if not request.user.is_authenticated:
            return Response({
                'status': 401,
                'message': 'Authentication required',
                'data': None
            }, status=status.HTTP_401_UNAUTHORIZED)
        
        try:
            serializer = ChangePasswordSerializer(data=request.data)
            
            if not serializer.is_valid():
                return Response({
                    'status': 400,
                    'message': 'Validation error',
                    'data': serializer.errors
                }, status=status.HTTP_400_BAD_REQUEST)
            
            user = request.user
            old_password = serializer.validated_data['old_password']
            new_password = serializer.validated_data['new_password']
            
            # Verify old password
            if not user.check_password(old_password):
                return Response({
                    'status': 400,
                    'message': 'Current password is incorrect',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Check if new password is same as old password
            if user.check_password(new_password):
                return Response({
                    'status': 400,
                    'message': 'New password must be different from current password',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Update password
            user.set_password(new_password)
            user.save()
            
            return Response({
                'status': 200,
                'message': 'Password updated successfully',
                'data': {
                    'email': user.email,
                    'updated_at': user.updated_at
                }
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class FCMTokenView(APIView):
    """
    Handle FCM token operations for push notifications
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        """Store/update FCM token for the authenticated user"""
        try:
            fcm_token = request.data.get('fcm_token')
            
            if not fcm_token:
                return Response({
                    'status': 400,
                    'message': 'FCM token is required',
                    'data': None
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Update user's FCM token
            user = request.user
            old_token = user.fcm_token
            user.fcm_token = fcm_token
            user.save()
            
            logger.info(f"FCM token updated for user {user.email} (user_id={user.user_id})")
            logger.info(f"  New token: {fcm_token[:30]}...")
            if old_token:
                token_changed = old_token != fcm_token
                logger.info(f"  Token changed: {token_changed}")
            else:
                logger.info(f"  Previous token was None")
            
            return Response({
                'status': 200,
                'message': 'FCM token updated successfully',
                'data': {
                    'user_id': user.user_id,
                    'email': user.email,
                    'fcm_token_updated': True
                }
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"Error updating FCM token: {str(e)}")
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def delete(self, request):
        """Remove FCM token for the authenticated user (on logout)"""
        try:
            user = request.user
            user.fcm_token = None
            user.save()
            
            logger.info(f"FCM token cleared for user {user.email}")
            
            return Response({
                'status': 200,
                'message': 'FCM token removed successfully',
                'data': {
                    'user_id': user.user_id,
                    'email': user.email,
                    'fcm_token_removed': True
                }
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'status': 500,
                'message': 'Internal server error',
                'data': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class FCMTestView(APIView):
    """
    Send a test push notification to the currently authenticated user.
    Use this to verify FCM delivery end-to-end.
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        user = request.user
        
        logger.info(f"\n{'='*50}")
        logger.info(f"FCM TEST NOTIFICATION for {user.email}")
        logger.info(f"  User ID: {user.user_id}")
        logger.info(f"  FCM Token in DB: {user.fcm_token[:40] if user.fcm_token else 'NONE'}...")
        logger.info(f"{'='*50}")
        
        if not user.fcm_token:
            return Response({
                'status': 400,
                'message': 'No FCM token stored for your account. Open the app first to register the token.',
                'data': {
                    'user_id': user.user_id,
                    'email': user.email,
                    'fcm_token': None
                }
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Send test notification
        success = FirebaseService.send_push_notification(
            fcm_token=user.fcm_token,
            title="Test Notification",
            body=f"Hello {user.full_name}! If you see this, FCM is working.",
            data={
                "type": "test",
                "message": "This is a test push notification"
            }
        )
        
        if success:
            return Response({
                'status': 200,
                'message': 'Test notification sent successfully via FCM',
                'data': {
                    'user_id': user.user_id,
                    'email': user.email,
                    'fcm_token_prefix': user.fcm_token[:30] + '...',
                    'firebase_accepted': True
                }
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'status': 500,
                'message': 'Failed to send test notification. Check server logs.',
                'data': {
                    'user_id': user.user_id,
                    'email': user.email,
                    'fcm_token_prefix': user.fcm_token[:30] + '...',
                    'firebase_accepted': False
                }
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def get(self, request):
        """Check FCM token status for current user and all users (debug)"""
        user = request.user
        
        # Get all users with FCM tokens
        users_with_tokens = User.objects.exclude(fcm_token__isnull=True).exclude(fcm_token='').values_list(
            'user_id', 'email', 'full_name', 'fcm_token'
        )
        
        token_info = []
        for uid, email, name, token in users_with_tokens:
            token_info.append({
                'user_id': uid,
                'email': email,
                'full_name': name,
                'fcm_token_prefix': token[:30] + '...' if token else None,
                'is_current_user': uid == user.user_id
            })
        
        return Response({
            'status': 200,
            'message': 'FCM token debug info',
            'data': {
                'current_user': {
                    'user_id': user.user_id,
                    'email': user.email,
                    'has_fcm_token': bool(user.fcm_token),
                    'fcm_token_prefix': user.fcm_token[:30] + '...' if user.fcm_token else None,
                },
                'all_users_with_tokens': token_info,
                'total_users_with_tokens': len(token_info)
            }
        }, status=status.HTTP_200_OK)