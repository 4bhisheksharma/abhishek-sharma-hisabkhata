from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q
from .models import SupportTicket
from .serializers import (
    SupportTicketSerializer, 
    CreateSupportTicketSerializer,
    UpdateTicketStatusSerializer
)


class IsAdminUser(permissions.BasePermission):
    """
    Custom permission to only allow admin users to access certain views.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.is_superuser


class SupportTicketViewSet(viewsets.ModelViewSet):
    queryset = SupportTicket.objects.all()
    serializer_class = SupportTicketSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return CreateSupportTicketSerializer
        elif self.action in ['update_status', 'partial_update', 'update']:
            return UpdateTicketStatusSerializer
        return SupportTicketSerializer
    
    def get_queryset(self):
        """
        Regular users can only see their own tickets.
        Admin users can see all tickets.
        """
        user = self.request.user
        if user.is_superuser:
            # Admin sees all tickets
            return SupportTicket.objects.all()
        else:
            # Regular users see only their tickets
            return SupportTicket.objects.filter(user=user)
    
    def create(self, request, *args, **kwargs):
        """Create a new support ticket"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        ticket = serializer.save()
        
        # Return full ticket details
        response_serializer = SupportTicketSerializer(ticket)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my_tickets(self, request):
        """Get all tickets created by the current user"""
        tickets = SupportTicket.objects.filter(user=request.user)
        serializer = self.get_serializer(tickets, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAdminUser])
    def admin_tickets(self, request):
        """Admin endpoint to get all tickets with filtering"""
        status_filter = request.query_params.get('status', None)
        priority_filter = request.query_params.get('priority', None)
        category_filter = request.query_params.get('category', None)
        
        queryset = SupportTicket.objects.all()
        
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        if priority_filter:
            queryset = queryset.filter(priority=priority_filter)
        if category_filter:
            queryset = queryset.filter(category=category_filter)
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['patch'], permission_classes=[IsAdminUser])
    def update_status(self, request, pk=None):
        """Admin endpoint to update ticket status and add response"""
        ticket = self.get_object()
        serializer = UpdateTicketStatusSerializer(
            ticket, 
            data=request.data, 
            partial=True,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        
        # Return full ticket details
        response_serializer = SupportTicketSerializer(ticket)
        return Response(response_serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[IsAdminUser])
    def statistics(self, request):
        """Get ticket statistics for admin dashboard"""
        total_tickets = SupportTicket.objects.count()
        open_tickets = SupportTicket.objects.filter(status='open').count()
        in_progress_tickets = SupportTicket.objects.filter(status='in_progress').count()
        resolved_tickets = SupportTicket.objects.filter(status='resolved').count()
        closed_tickets = SupportTicket.objects.filter(status='closed').count()
        
        urgent_tickets = SupportTicket.objects.filter(priority='urgent', status__in=['open', 'in_progress']).count()
        
        return Response({
            'total_tickets': total_tickets,
            'open_tickets': open_tickets,
            'in_progress_tickets': in_progress_tickets,
            'resolved_tickets': resolved_tickets,
            'closed_tickets': closed_tickets,
            'urgent_tickets': urgent_tickets,
        })
