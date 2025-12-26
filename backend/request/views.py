from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import BusinessCustomerRequest
from .serializers import (
    ConnectionRequestSerializer,
    SendRequestSerializer,
    UpdateRequestStatusSerializer,
    UserSearchSerializer
)
from hisabauth.models import User
from notification.models import Notification


class ConnectionRequestViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing connection requests between users
    """
    serializer_class = ConnectionRequestSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Get requests for the authenticated user"""
        user = self.request.user
        return BusinessCustomerRequest.objects.filter(
            Q(sender=user) | Q(receiver=user)
        )
    
    @action(detail=False, methods=['get'], url_path='search-users')
    def search_users(self, request):
        """
        Search for users by email or phone_number
        Query params: search (email or phone_number)
        """
        search_query = request.query_params.get('search', '').strip()
        
        if not search_query:
            return Response(
                {'error': 'Please provide a search query (email or phone_number)'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Search by email or phone_number
        users = User.objects.filter(
            Q(email__icontains=search_query) | Q(phone_number__icontains=search_query)
        ).exclude(user_id=request.user.user_id)[:10]  # Limit to 10 results
        
        # Check existing connections for each user
        results = []
        for user in users:
            user_data = UserSearchSerializer(user).data
            
            # Check if there's an existing request
            existing_request = BusinessCustomerRequest.objects.filter(
                Q(sender=request.user, receiver=user) |
                Q(sender=user, receiver=request.user)
            ).first()
            
            user_data['connection_status'] = None
            if existing_request:
                user_data['connection_status'] = existing_request.status
                user_data['request_id'] = existing_request.business_customer_request_id
                user_data['is_sender'] = existing_request.sender == request.user
            
            results.append(user_data)
        
        return Response(results, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['post'], url_path='send-request')
    def send_request(self, request):
        """
        Send a connection request to another user
        Body: { "receiver_email": "user@example.com" } OR { "receiver_id": 123 }
        """
        serializer = SendRequestSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        
        # Receiver is already validated and fetched in the serializer
        receiver = serializer.validated_data['receiver']
        
        # Check if request already exists
        existing_request = BusinessCustomerRequest.objects.filter(
            Q(sender=request.user, receiver=receiver) |
            Q(sender=receiver, receiver=request.user)
        ).first()
        
        if existing_request:
            return Response(
                {
                    'error': 'A connection request already exists between you and this user',
                    'existing_request': ConnectionRequestSerializer(existing_request).data
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Create new request
        connection_request = BusinessCustomerRequest.objects.create(
            sender=request.user,
            receiver=receiver
        )
        
        # Send in-app notification to receiver
        Notification.objects.create(
            sender=request.user,
            receiver=receiver,
            title="New Connection Request",
            message=f"{request.user.full_name} sent you a connection request.",
            type="connection_request"
        )
        
        return Response(
            {
                'message': 'Connection request sent successfully',
                'request': ConnectionRequestSerializer(connection_request).data
            },
            status=status.HTTP_201_CREATED
        )
    
    @action(detail=False, methods=['get'], url_path='sent')
    def sent_requests(self, request):
        """Get all requests sent by the authenticated user"""
        requests = BusinessCustomerRequest.objects.filter(sender=request.user)
        serializer = ConnectionRequestSerializer(requests, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], url_path='received')
    def received_requests(self, request):
        """Get all requests received by the authenticated user"""
        requests = BusinessCustomerRequest.objects.filter(receiver=request.user)
        serializer = ConnectionRequestSerializer(requests, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], url_path='pending-received')
    def pending_received_requests(self, request):
        """Get pending requests received by the authenticated user"""
        requests = BusinessCustomerRequest.objects.filter(
            receiver=request.user,
            status='pending'
        )
        serializer = ConnectionRequestSerializer(requests, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], url_path='connected')
    def connected_users(self, request):
        """Get all connected users (accepted connections)"""
        connected = BusinessCustomerRequest.objects.filter(
            Q(sender=request.user, status='accepted') |
            Q(receiver=request.user, status='accepted')
        )
        serializer = ConnectionRequestSerializer(connected, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['patch'], url_path='update-status')
    def update_status(self, request, pk=None):
        """
        Accept or reject a connection request
        Body: { "status": "accepted" | "rejected" }
        """
        connection_request = self.get_object()
        
        # Only receiver can update the status
        if connection_request.receiver != request.user:
            return Response(
                {'error': 'Only the receiver can accept or reject the request'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Can only update pending requests
        if connection_request.status != 'pending':
            return Response(
                {'error': f'Cannot update request with status: {connection_request.status}'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = UpdateRequestStatusSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        connection_request.status = serializer.validated_data['status']
        connection_request.save()
        
        # Send notification to sender about status update
        status_text = serializer.validated_data['status']
        Notification.objects.create(
            sender=request.user,
            receiver=connection_request.sender,
            title=f"Connection Request {status_text.capitalize()}",
            message=f"{request.user.full_name} {status_text} your connection request.",
            type=f"connection_request_{status_text}"
        )
        
        return Response(
            {
                'message': f'Request {serializer.validated_data["status"]} successfully',
                'request': ConnectionRequestSerializer(connection_request).data
            },
            status=status.HTTP_200_OK
        )
