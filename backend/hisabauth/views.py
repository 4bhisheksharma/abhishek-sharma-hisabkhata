from django.shortcuts import render
from rest_framework.views import APIView
from hisabauth.emails import send_verification_email
from hisabauth.serializer import UserSerializer
from rest_framework.response import Response


class RegisterView(APIView):
    
    def post(self, request):
        try:
            data = request.data
            serializer = UserSerializer(data=data)
            if serializer.is_valid():
                serializer.save()
                send_verification_email(serializer.data['email'])
                return Response({
                    'status': 200,
                    'message': 'User registered successfully', 
                    
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