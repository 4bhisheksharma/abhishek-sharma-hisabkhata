from django.shortcuts import render
from rest_framework.views import APIView
from hisabauth.serializer import UserSerializer
from hisabauth.models import User
from otp_verification.services import send_otp_email
from rest_framework.response import Response


class RegisterView(APIView):
    
    def post(self, request):
        try:
            data = request.data
            serializer = UserSerializer(data=data)
            if serializer.is_valid():
                user = serializer.save()
                # Send OTP using new OTP verification service
                send_otp_email(user, 'email_verification')
                return Response({
                    'status': 200,
                    'message': 'User registered successfully. Please check your email for OTP.', 
                    'data': serializer.data    
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