from django.db.models.signals import post_save
from django.dispatch import receiver
from customer_dashboard.models import CustomerBusinessRelationship
from .models import ChatRoom


@receiver(post_save, sender=CustomerBusinessRelationship)
def create_chat_room_for_relationship(sender, instance, created, **kwargs):
    """
    Automatically create a chat room when a new active relationship is created.
    """
    if created and instance.status == 'active':
        ChatRoom.objects.create(relationship=instance)
        print(f"Created chat room for relationship {instance.relationship_id}")


@receiver(post_save, sender=CustomerBusinessRelationship)
def handle_relationship_status_change(sender, instance, **kwargs):
    """
    Handle status changes on relationships.
    If status changes to active and no chat room exists, create one.
    """
    if instance.status == 'active':
        # Ensure chat room exists for active relationships
        if not hasattr(instance, 'chat_room') or instance.chat_room is None:
            try:
                # Check if chat room already exists
                instance.chat_room
            except ChatRoom.DoesNotExist:
                ChatRoom.objects.create(relationship=instance)
                print(f"Created chat room for reactivated relationship {instance.relationship_id}")
    # Note: We don't delete chat rooms when relationships are blocked/deleted
    # to preserve message history. The validation in views/serializers will prevent access.