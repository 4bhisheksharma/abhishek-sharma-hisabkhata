from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.pagination import PageNumberPagination
from django.db.models import Q
from .models import BusinessCustomerRequest
from .serializers import (
    ConnectionRequestSerializer,
    ConnectedUserSerializer,
    SendRequestSerializer,
    UpdateRequestStatusSerializer,
    UserSearchSerializer,
    BulkSendRequestSerializer,
    BulkRequestResultSerializer,
    BulkUpdateStatusSerializer
)
from hisabauth.models import User
from notification.services import (
    notify_connection_request,
    notify_connection_accepted,
    notify_connection_rejected,
    notify_connection_cancelled,
    notify_connection_deleted,
)
from customer_dashboard.models import CustomerBusinessRelationship
import logging

logger = logging.getLogger(__name__)


def _resolve_customer_business_profiles(sender, receiver):
    """Resolve relationship orientation from a request pair.

    For hybrid users, sender direction is used when both orientations are possible.
    """
    sender_has_customer = hasattr(sender, 'customer_profile')
    sender_has_business = hasattr(sender, 'business_profile')
    receiver_has_customer = hasattr(receiver, 'customer_profile')
    receiver_has_business = hasattr(receiver, 'business_profile')

    if sender_has_customer and receiver_has_business:
        return sender.customer_profile, receiver.business_profile

    if sender_has_business and receiver_has_customer:
        return receiver.customer_profile, sender.business_profile

    return None, None


def _get_relationship_for_users(current_user, other_user):
    """Find relationship between two users in either valid direction."""
    candidates = []
    if hasattr(current_user, 'customer_profile') and hasattr(other_user, 'business_profile'):
        candidates.append((current_user.customer_profile, other_user.business_profile))
    if hasattr(current_user, 'business_profile') and hasattr(other_user, 'customer_profile'):
        candidates.append((other_user.customer_profile, current_user.business_profile))

    for customer_profile, business_profile in candidates:
        relationship = CustomerBusinessRelationship.objects.filter(
            customer=customer_profile,
            business=business_profile,
        ).first()
        if relationship:
            return relationship

    return None


class UserSearchPagination(PageNumberPagination):
    """Pagination for user search/list endpoint"""
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 50


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
        Search/list users with cursor-based pagination.
        
        Query params:
            - search (optional): Filter by email, phone_number, or full_name
            - page (optional): Page number (default: 1)
            - page_size (optional): Items per page (default: 20, max: 50)
        
        If no search query is provided, returns all users (paginated).
        Always excludes the current authenticated user.
        """
        search_query = request.query_params.get('search', '').strip()
        
        # Base queryset: all active users except the current user
        users_qs = User.objects.filter(
            is_active=True
        ).exclude(
            user_id=request.user.user_id
        ).order_by('full_name', 'user_id')
        
        # Apply search filter if provided
        if search_query:
            users_qs = users_qs.filter(
                Q(email__icontains=search_query) | 
                Q(phone_number__icontains=search_query) |
                Q(full_name__icontains=search_query)
            )
        
        # Paginate
        paginator = UserSearchPagination()
        page = paginator.paginate_queryset(users_qs, request)
        
        if page is None:
            page = []
        
        # Build results with connection status
        results = []
        for user in page:
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
        
        return paginator.get_paginated_response(results)
    
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
            # If there's an accepted request, check if relationship still exists
            if existing_request.status == 'accepted':
                # Verify no active relationship exists (connection was properly deleted)
                sender_user = existing_request.sender
                receiver_user = existing_request.receiver
                
                relationship_exists = CustomerBusinessRelationship.objects.filter(
                    Q(customer__user=sender_user, business__user=receiver_user) |
                    Q(customer__user=receiver_user, business__user=sender_user)
                ).exists()
                
                if relationship_exists:
                    return Response(
                        {
                            'error': 'You are already connected with this user',
                            'existing_request': ConnectionRequestSerializer(existing_request).data
                        },
                        status=status.HTTP_400_BAD_REQUEST
                    )
                
                # Connection was deleted, so delete the old request and allow new one
                existing_request.delete()
            elif existing_request.status == 'rejected':
                # Rejected request still in DB (legacy), delete it and allow re-sending
                existing_request.delete()
            elif existing_request.status == 'pending':
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
        
        # Send in-app + push notification via centralized service
        try:
            notify_connection_request(sender=request.user, receiver=receiver)
        except Exception as e:
            logger.error(f"Connection request notification error: {e}")
        
        return Response(
            {
                'message': 'Connection request sent successfully',
                'request': ConnectionRequestSerializer(connection_request).data
            },
            status=status.HTTP_201_CREATED
        )
    
    @action(detail=False, methods=['post'], url_path='bulk-send-request')
    def bulk_send_request(self, request):
        """
        Send connection requests to multiple users in bulk
        Body: {
            "receivers": [
                {"email": "user1@example.com"},
                {"user_id": 123},
                {"email": "user2@example.com"}
            ]
        }
        """
        serializer = BulkSendRequestSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        
        receivers = serializer.validated_data['receivers']
        
        # Track results
        results = {
            'successful': [],
            'failed': [],
            'skipped': []
        }
        
        # Check existing connections and requests
        from django.db import transaction
        
        for receiver in receivers:
            try:
                # Check if already connected (accepted request exists)
                existing_connection = CustomerBusinessRelationship.objects.filter(
                    Q(customer__user=request.user, business__user=receiver) |
                    Q(customer__user=receiver, business__user=request.user)
                ).exists()
                
                if existing_connection:
                    results['skipped'].append({
                        'user_id': receiver.user_id,
                        'email': receiver.email,
                        'full_name': receiver.full_name,
                        'reason': 'Already connected'
                    })
                    continue
                
                # Check if request already exists
                existing_request = BusinessCustomerRequest.objects.filter(
                    Q(sender=request.user, receiver=receiver) |
                    Q(sender=receiver, receiver=request.user)
                ).first()
                
                if existing_request:
                    # If pending, skip
                    if existing_request.status == 'pending':
                        results['skipped'].append({
                            'user_id': receiver.user_id,
                            'email': receiver.email,
                            'full_name': receiver.full_name,
                            'reason': f'Request already exists with status: {existing_request.status}',
                            'existing_request_id': existing_request.business_customer_request_id,
                            'existing_status': existing_request.status
                        })
                        continue
                    # If rejected, delete the old request and allow creating a new one
                    elif existing_request.status == 'rejected':
                        existing_request.delete()
                    # If accepted, skip (already connected)
                    elif existing_request.status == 'accepted':
                        results['skipped'].append({
                            'user_id': receiver.user_id,
                            'email': receiver.email,
                            'full_name': receiver.full_name,
                            'reason': 'Already connected',
                            'existing_request_id': existing_request.business_customer_request_id,
                            'existing_status': existing_request.status
                        })
                        continue
                
                # Create new request within transaction
                with transaction.atomic():
                    connection_request = BusinessCustomerRequest.objects.create(
                        sender=request.user,
                        receiver=receiver
                    )
                    
                    # Send in-app + push notification via centralized service
                    notify_connection_request(sender=request.user, receiver=receiver)
                
                results['successful'].append({
                    'user_id': receiver.user_id,
                    'email': receiver.email,
                    'full_name': receiver.full_name,
                    'request_id': connection_request.business_customer_request_id,
                    'status': connection_request.status
                })
                
            except Exception as e:
                results['failed'].append({
                    'user_id': receiver.user_id,
                    'email': receiver.email,
                    'full_name': receiver.full_name,
                    'error': str(e)
                })
        
        # Prepare summary
        summary = {
            'total_requested': len(receivers),
            'successful': len(results['successful']),
            'failed': len(results['failed']),
            'skipped': len(results['skipped']),
            'results': results,
            'summary': {
                'message': f"Sent {len(results['successful'])} request(s), skipped {len(results['skipped'])}, failed {len(results['failed'])}"
            }
        }
        
        # Determine HTTP status code
        if results['successful']:
            response_status = status.HTTP_201_CREATED
        elif results['skipped'] and not results['failed']:
            response_status = status.HTTP_200_OK
        else:
            response_status = status.HTTP_207_MULTI_STATUS
        
        return Response(summary, status=response_status)
    
    @action(detail=False, methods=['get'], url_path='sent')
    def sent_requests(self, request):
        """Get all requests sent by the authenticated user (pending and accepted only)"""
        requests = BusinessCustomerRequest.objects.filter(sender=request.user)
        serializer = ConnectionRequestSerializer(requests, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], url_path='received')
    def received_requests(self, request):
        """Get all requests received by the authenticated user (pending and accepted only)"""
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
        """Get all connected users (accepted connections) with detailed info"""
        connected_requests = BusinessCustomerRequest.objects.filter(
            Q(sender=request.user, status='accepted') |
            Q(receiver=request.user, status='accepted')
        ).select_related(
            'sender__business_profile',
            'sender__customer_profile',
            'receiver__business_profile',
            'receiver__customer_profile'
        )
        
        # Get the other user from each connection
        connected_users = []
        for conn in connected_requests:
            if conn.sender == request.user:
                other_user = conn.receiver
            else:
                other_user = conn.sender
            
            user_data = ConnectedUserSerializer(other_user).data
            user_data['connected_at'] = conn.updated_at
            user_data['request_id'] = conn.business_customer_request_id
            
            # Get relationship_id from CustomerBusinessRelationship
            relationship_id = None
            pending_due = 0.00
            current_user = request.user
            
            relationship = _get_relationship_for_users(current_user, other_user)
            if relationship:
                relationship_id = relationship.relationship_id
                pending_due = float(relationship.pending_due)
            
            user_data['relationship_id'] = relationship_id
            user_data['pending_due'] = pending_due
            connected_users.append(user_data)
        
        return Response(connected_users, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['delete'], url_path='delete-connection')
    def delete_connection(self, request):
        """
        Delete a connection between users
        Body: { "user_id": 123 } OR { "request_id": 456 }
        """
        user_id = request.data.get('user_id')
        request_id = request.data.get('request_id')
        
        if not user_id and not request_id:
            return Response(
                {'error': 'Either user_id or request_id must be provided'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Find the connection request
            if request_id:
                connection_request = BusinessCustomerRequest.objects.get(
                    business_customer_request_id=request_id,
                    status='accepted'
                )
                # Verify that the current user is part of this connection
                if connection_request.sender != request.user and connection_request.receiver != request.user:
                    return Response(
                        {'error': 'You are not part of this connection'},
                        status=status.HTTP_403_FORBIDDEN
                    )
            else:
                # Find by user_id
                connection_request = BusinessCustomerRequest.objects.filter(
                    Q(sender=request.user, receiver__user_id=user_id, status='accepted') |
                    Q(receiver=request.user, sender__user_id=user_id, status='accepted')
                ).first()
                
                if not connection_request:
                    return Response(
                        {'error': 'No accepted connection found with this user'},
                        status=status.HTTP_404_NOT_FOUND
                    )
            
            # Determine the other user
            other_user = connection_request.receiver if connection_request.sender == request.user else connection_request.sender
            
            # Check for pending dues in CustomerBusinessRelationship
            relationship = _get_relationship_for_users(request.user, other_user)
            
            # Check if there are pending dues
            if relationship and relationship.pending_due != 0:
                return Response(
                    {
                        'error': 'Cannot delete connection with pending dues',
                        'pending_due': float(relationship.pending_due),
                        'message': f'Please settle the pending amount of {abs(relationship.pending_due)} before deleting this connection'
                    },
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Delete the relationship if it exists (this will cascade delete transactions)
            if relationship:
                relationship.delete()
            
            # Delete the connection request
            connection_request.delete()
            
            # Send in-app + push notification via centralized service
            try:
                notify_connection_deleted(deleter=request.user, other_user=other_user)
            except Exception as e:
                logger.error(f"Connection deleted notification error: {e}")
            
            return Response(
                {
                    'message': 'Connection deleted successfully',
                    'deleted_user': {
                        'user_id': other_user.user_id,
                        'email': other_user.email,
                        'full_name': other_user.full_name
                    }
                },
                status=status.HTTP_200_OK
            )
            
        except BusinessCustomerRequest.DoesNotExist:
            return Response(
                {'error': 'Connection request not found'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=True, methods=['delete'], url_path='cancel')
    def cancel_request(self, request, pk=None):
        """
        Cancel a pending connection request.
        Only the sender can cancel their own pending request.
        """
        connection_request = self.get_object()
        
        # Only the sender can cancel
        if connection_request.sender != request.user:
            return Response(
                {'error': 'Only the sender can cancel a request'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Can only cancel pending requests
        if connection_request.status != 'pending':
            return Response(
                {'error': f'Cannot cancel request with status: {connection_request.status}'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        request_id = connection_request.business_customer_request_id
        receiver = connection_request.receiver
        
        # Delete the request
        connection_request.delete()
        
        # Notify the receiver (in-app + push) — previously missing FCM push
        try:
            notify_connection_cancelled(canceller=request.user, receiver=receiver)
        except Exception as e:
            logger.error(f"Connection cancelled notification error: {e}")
        
        return Response(
            {
                'message': 'Connection request cancelled successfully',
                'request_id': request_id
            },
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['patch'], url_path='update-status')
    def update_status(self, request, pk=None):
        """
        Accept or reject a connection request
        Body: { "status": "accepted" | "rejected" }
        
        Note: When a request is rejected, it is immediately deleted from the database
        to allow the sender to send a new request in the future.
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
        
        status_text = serializer.validated_data['status']
        sender = connection_request.sender
        
        # If accepted, create CustomerBusinessRelationship
        if status_text == 'accepted':
            from django.db import transaction
            try:
                with transaction.atomic():
                    self._create_customer_business_relationship(connection_request)
                    connection_request.status = status_text
                    connection_request.save()
            except ValueError as exc:
                return Response(
                    {'error': str(exc)},
                    status=status.HTTP_400_BAD_REQUEST,
                )
        elif status_text == 'rejected':
            # Delete rejected requests immediately to allow re-sending
            connection_request.delete()
        
        # Send in-app + push notification via centralized service
        try:
            if status_text == 'accepted':
                notify_connection_accepted(accepter=request.user, requester=sender)
            elif status_text == 'rejected':
                notify_connection_rejected(rejecter=request.user, requester=sender)
        except Exception as e:
            logger.error(f"Connection status notification error: {e}")
        
        response_data = {
            'message': f'Request {status_text} successfully',
        }
        
        # Only include request data if it still exists (not rejected)
        if status_text == 'accepted':
            response_data['request'] = ConnectionRequestSerializer(connection_request).data
        
        return Response(response_data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['patch'], url_path='bulk-update-status')
    def bulk_update_status(self, request):
        """
        Accept or reject multiple connection requests in bulk
        Body: {
            "request_ids": [1, 2, 3, 4],
            "status": "accepted" | "rejected"
        }
        """
        serializer = BulkUpdateStatusSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        request_ids = serializer.validated_data['request_ids']
        new_status = serializer.validated_data['status']
        
        # Track results
        results = {
            'successful': [],
            'failed': [],
            'skipped': []
        }
        
        from django.db import transaction
        
        for request_id in request_ids:
            try:
                connection_request = BusinessCustomerRequest.objects.get(
                    business_customer_request_id=request_id
                )
                
                # Only receiver can update the status
                if connection_request.receiver != request.user:
                    results['failed'].append({
                        'request_id': request_id,
                        'error': 'Only the receiver can accept or reject the request'
                    })
                    continue
                
                # Can only update pending requests
                if connection_request.status != 'pending':
                    results['skipped'].append({
                        'request_id': request_id,
                        'current_status': connection_request.status,
                        'reason': f'Request is not pending (current status: {connection_request.status})'
                    })
                    continue
                
                # Update status within transaction
                with transaction.atomic():
                    sender = connection_request.sender
                    sender_name = sender.full_name
                    sender_email = sender.email
                    
                    # If accepted, update and create CustomerBusinessRelationship
                    if new_status == 'accepted':
                        try:
                            self._create_customer_business_relationship(connection_request)
                        except ValueError as exc:
                            results['failed'].append({
                                'request_id': request_id,
                                'error': str(exc),
                            })
                            continue

                        connection_request.status = new_status
                        connection_request.save()
                    elif new_status == 'rejected':
                        # Delete rejected requests immediately to allow re-sending
                        connection_request.delete()
                    
                    # Send in-app + push notification via centralized service
                    if new_status == 'accepted':
                        notify_connection_accepted(accepter=request.user, requester=sender)
                    elif new_status == 'rejected':
                        notify_connection_rejected(rejecter=request.user, requester=sender)
                
                results['successful'].append({
                    'request_id': request_id,
                    'sender_name': sender_name,
                    'sender_email': sender_email,
                    'new_status': new_status
                })
                
            except BusinessCustomerRequest.DoesNotExist:
                results['failed'].append({
                    'request_id': request_id,
                    'error': 'Request not found'
                })
            except Exception as e:
                results['failed'].append({
                    'request_id': request_id,
                    'error': str(e)
                })
        
        # Prepare summary
        summary = {
            'total_requested': len(request_ids),
            'successful': len(results['successful']),
            'failed': len(results['failed']),
            'skipped': len(results['skipped']),
            'results': results,
            'summary': {
                'message': f"{new_status.capitalize()} {len(results['successful'])} request(s), skipped {len(results['skipped'])}, failed {len(results['failed'])}"
            }
        }
        
        # Determine HTTP status code
        if results['successful']:
            response_status = status.HTTP_200_OK
        elif results['skipped'] and not results['failed']:
            response_status = status.HTTP_200_OK
        else:
            response_status = status.HTTP_207_MULTI_STATUS
        
        return Response(summary, status=response_status)
    
    def _create_customer_business_relationship(self, connection_request):
        """
        Create a CustomerBusinessRelationship when a connection is accepted.
        Determines who is customer and who is business based on their profiles.
        """
        sender = connection_request.sender
        receiver = connection_request.receiver
        
        customer, business = _resolve_customer_business_profiles(sender, receiver)

        if not customer or not business:
            raise ValueError('Cannot create relationship: one user must act as customer and the other as business.')

        CustomerBusinessRelationship.objects.get_or_create(
            customer=customer,
            business=business,
            defaults={'pending_due': 0.00}
        )
