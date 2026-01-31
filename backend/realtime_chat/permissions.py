from rest_framework import permissions
from .models import ChatRoom


class IsChatRoomParticipant(permissions.BasePermission):
    """
    Permission to check if user is a participant in the chat room.
    User must be either the customer or the business owner in the relationship.
    """
    
    def has_object_permission(self, request, view, obj):
        """
        Check if user has access to the chat room or message.
        """
        user = request.user
        
        # If obj is a ChatRoom
        if isinstance(obj, ChatRoom):
            chat_room = obj
        # If obj is a Message, get its chat_room
        elif hasattr(obj, 'chat_room'):
            chat_room = obj.chat_room
        else:
            return False
        
        relationship = chat_room.relationship
        
        # Check if user is the customer in the relationship
        is_customer = (
            hasattr(user, 'customer_profile') and 
            relationship.customer == user.customer_profile
        )
        
        # Check if user is the business owner in the relationship
        is_business = (
            hasattr(user, 'business_profile') and 
            relationship.business == user.business_profile
        )
        
        return is_customer or is_business


class IsMessageSender(permissions.BasePermission):
    """
    Permission to check if user is the sender of the message.
    Only the sender can edit or delete their own messages.
    """
    
    def has_object_permission(self, request, view, obj):
        """
        Check if user is the sender of the message.
        """
        # Read permissions are handled by IsChatRoomParticipant
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions: only the sender can modify
        return obj.sender == request.user


class CanAccessChatRoom(permissions.BasePermission):
    """
    Permission to check if a user can access a specific chat room.
    Users can only access chat rooms they are part of.
    """
    
    def has_permission(self, request, view):
        """
        Check if user is authenticated.
        """
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        """
        Check if user is a participant in the chat room.
        """
        user = request.user
        relationship = obj.relationship
        
        # Check if user is customer or business in this relationship
        is_customer = (
            hasattr(user, 'customer_profile') and 
            relationship.customer == user.customer_profile
        )
        is_business = (
            hasattr(user, 'business_profile') and 
            relationship.business == user.business_profile
        )
        
        return is_customer or is_business
