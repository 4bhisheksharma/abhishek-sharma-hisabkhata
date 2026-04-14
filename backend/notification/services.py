"""
Centralized notification service.

Every notification in the app should be created through this module.
It handles BOTH the in-app DB notification AND the FCM push in a single call,
guaranteeing they stay consistent and reducing boilerplate in views.
"""
import logging
from django.db import transaction as db_transaction
from .models import Notification, NotificationType
from core.firebase_service import FirebaseService

logger = logging.getLogger(__name__)


def _push(user, title, body, data):
    """Send FCM push to a single user if they have a token. Fire-and-forget."""
    if not user or not getattr(user, 'fcm_token', None):
        return
    try:
        sent = FirebaseService.send_push_notification(user.fcm_token, title, body, data)
        if sent:
            logger.info(f"Push sent to {user.email} [{data.get('type', '')}]")
        else:
            logger.warning(f"Push not delivered to {user.email} [{data.get('type', '')}]")
    except Exception as e:
        logger.error(f"Push failed for {user.email}: {e}")


def _push_multiple(users, title, body, data):
    """Send FCM push to a list of users."""
    tokens = [u.fcm_token for u in users if getattr(u, 'fcm_token', None)]
    if not tokens:
        return
    try:
        result = FirebaseService.send_push_notification_to_multiple(tokens, title, body, data)
        logger.info(
            f"Multicast push result [{data.get('type', '')}] "
            f"success={result.get('success_count', 0)} failure={result.get('failure_count', 0)}"
        )
    except Exception as e:
        logger.error(f"Multicast push failed: {e}")


# ---------------------------------------------------------------------------
# Connection notifications
# ---------------------------------------------------------------------------

def notify_connection_request(sender, receiver):
    """Notify receiver of a new connection request."""
    title = "New Connection Request"
    message = f"{sender.full_name} sent you a connection request."
    n_type = NotificationType.CONNECTION_REQUEST
    data = {
        "type": n_type,
        "sender_name": sender.full_name,
        "sender_email": sender.email,
        "action": "view_requests",
    }
    Notification.objects.create(
        sender=sender, receiver=receiver,
        title=title, message=message, type=n_type, data=data,
    )
    _push(receiver, title, message, data)


def notify_connection_accepted(accepter, requester):
    """Notify the original requester that their request was accepted."""
    title = "Connection Request Accepted"
    message = f"{accepter.full_name} accepted your connection request."
    n_type = NotificationType.CONNECTION_ACCEPTED
    data = {
        "type": n_type,
        "accepter_name": accepter.full_name,
        "action": "view_connections",
    }
    Notification.objects.create(
        sender=accepter, receiver=requester,
        title=title, message=message, type=n_type, data=data,
    )
    _push(requester, title, message, data)


def notify_connection_rejected(rejecter, requester):
    """Notify the original requester that their request was rejected."""
    title = "Connection Request Rejected"
    message = f"{rejecter.full_name} rejected your connection request."
    n_type = NotificationType.CONNECTION_REJECTED
    data = {
        "type": n_type,
        "rejecter_name": rejecter.full_name,
        "action": "view_requests",
    }
    Notification.objects.create(
        sender=rejecter, receiver=requester,
        title=title, message=message, type=n_type, data=data,
    )
    _push(requester, title, message, data)


def notify_connection_cancelled(canceller, receiver):
    """Notify receiver that sender cancelled their pending request."""
    title = "Connection Request Cancelled"
    message = f"{canceller.full_name} cancelled their connection request."
    n_type = NotificationType.CONNECTION_CANCELLED
    data = {
        "type": n_type,
        "canceller_name": canceller.full_name,
        "action": "view_requests",
    }
    Notification.objects.create(
        sender=canceller, receiver=receiver,
        title=title, message=message, type=n_type, data=data,
    )
    _push(receiver, title, message, data)


def notify_connection_deleted(deleter, other_user):
    """Notify when a connection is deleted."""
    title = "Connection Deleted"
    message = f"{deleter.full_name} has removed the connection with you."
    n_type = NotificationType.CONNECTION_DELETED
    data = {
        "type": n_type,
        "deleter_name": deleter.full_name,
        "action": "view_connections",
    }
    Notification.objects.create(
        sender=deleter, receiver=other_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(other_user, title, message, data)


# ---------------------------------------------------------------------------
# Transaction notifications
# ---------------------------------------------------------------------------

def notify_transaction_added(sender_user, receiver_user, amount, transaction_type,
                             relationship_id, description=""):
    """Notify when a new transaction is added (purchase, credit, adjustment)."""
    abs_amount = abs(amount)
    title = "New Transaction"
    message = f"{sender_user.full_name} added a {transaction_type} of Rs. {abs_amount:.2f}"
    if description:
        message += f" — {description}"
    n_type = NotificationType.TRANSACTION_ADDED
    data = {
        "type": n_type,
        "amount": str(abs_amount),
        "transaction_type": transaction_type,
        "relationship_id": str(relationship_id),
        "action": "view_transactions",
    }
    Notification.objects.create(
        sender=sender_user, receiver=receiver_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(receiver_user, title, message, data)


def notify_payment_received(
    payer_user,
    business_user,
    amount,
    relationship_id,
    via_esewa=False,
    via_khalti=False,
):
    """Notify business when a customer records a payment."""
    abs_amount = abs(amount)
    title = "Payment Received"
    if via_esewa:
        message = f"{payer_user.full_name} paid Rs. {abs_amount:.2f} via eSewa"
    elif via_khalti:
        message = f"{payer_user.full_name} paid Rs. {abs_amount:.2f} via Khalti"
    else:
        message = f"{payer_user.full_name} recorded a payment of Rs. {abs_amount:.2f}"
    n_type = NotificationType.PAYMENT_RECEIVED
    data = {
        "type": n_type,
        "amount": str(abs_amount),
        "relationship_id": str(relationship_id),
        "action": "view_transactions",
    }
    Notification.objects.create(
        sender=payer_user, receiver=business_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(business_user, title, message, data)


# ---------------------------------------------------------------------------
# Due reminder / Smart payment reminder
# ---------------------------------------------------------------------------

def notify_due_reminder(business_user, customer_user, amount, relationship_id):
    """Send a due reminder from business to customer."""
    abs_amount = abs(amount)
    title = "Payment Due Reminder"
    message = f"{business_user.full_name} reminds you about a pending due of Rs. {abs_amount:.2f}"
    n_type = NotificationType.DUE_REMINDER
    data = {
        "type": n_type,
        "amount": str(abs_amount),
        "relationship_id": str(relationship_id),
        "sender_name": business_user.full_name,
        "action": "view_transactions",
    }
    Notification.objects.create(
        sender=business_user, receiver=customer_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(customer_user, title, message, data)


def notify_bulk_payment_reminder(business_user, overdue_relationships):
    """
    Smart Payment Reminder — send bulk due reminders to all overdue customers.
    `overdue_relationships` is a queryset/list of CustomerBusinessRelationship.
    Returns count of notifications sent.
    """
    count = 0
    for rel in overdue_relationships:
        customer_user = rel.customer.user
        abs_amount = abs(rel.pending_due)
        title = "Payment Due Reminder"
        message = (
            f"{business_user.full_name} reminds you about a pending due of Rs. {abs_amount:.2f}. "
            "Please settle your dues at your earliest convenience."
        )
        n_type = NotificationType.BULK_PAYMENT_REMINDER
        data = {
            "type": n_type,
            "amount": str(abs_amount),
            "relationship_id": str(rel.relationship_id),
            "sender_name": business_user.full_name,
            "action": "view_transactions",
        }
        Notification.objects.create(
            sender=business_user, receiver=customer_user,
            title=title, message=message, type=n_type, data=data,
        )
        _push(customer_user, title, message, data)
        count += 1
    return count


# ---------------------------------------------------------------------------
# Monthly limit exceeded
# ---------------------------------------------------------------------------

def notify_monthly_limit_exceeded(customer_user, total_spent, monthly_limit):
    """Notify customer when their monthly spending exceeds the set limit."""
    title = "Monthly Limit Exceeded"
    message = (
        f"You have spent Rs. {total_spent:.2f} this month, "
        f"exceeding your limit of Rs. {monthly_limit:.2f}."
    )
    n_type = NotificationType.MONTHLY_LIMIT_EXCEEDED
    data = {
        "type": n_type,
        "total_spent": str(total_spent),
        "monthly_limit": str(monthly_limit),
        "action": "view_dashboard",
    }
    Notification.objects.create(
        sender=None, receiver=customer_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(customer_user, title, message, data)


# ---------------------------------------------------------------------------
# Favorites
# ---------------------------------------------------------------------------

def notify_favorite_added(customer_user, business_user):
    """Notify business when a customer adds them as favorite."""
    title = "New Favorite!"
    message = f"{customer_user.full_name} added your business to their favorites."
    n_type = NotificationType.FAVORITE_ADDED
    data = {
        "type": n_type,
        "customer_name": customer_user.full_name,
        "action": "view_dashboard",
    }
    Notification.objects.create(
        sender=customer_user, receiver=business_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(business_user, title, message, data)


# ---------------------------------------------------------------------------
# Loyalty points (Gazab Customer point)
# ---------------------------------------------------------------------------

def notify_loyalty_points(customer_user, points, reason=""):
    """Notify customer about loyalty points earned."""
    title = "Loyalty Points Earned!"
    message = f"You earned {points} Gazab Customer points"
    if reason:
        message += f" for {reason}"
    message += "."
    n_type = NotificationType.LOYALTY_POINTS
    data = {
        "type": n_type,
        "points": str(points),
        "reason": reason,
        "action": "view_dashboard",
    }
    Notification.objects.create(
        sender=None, receiver=customer_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(customer_user, title, message, data)


# ---------------------------------------------------------------------------
# Business verification
# ---------------------------------------------------------------------------

def notify_verification_approved(business_user):
    """Notify business when their profile is verified."""
    title = "Business Verified!"
    message = "Congratulations! Your business profile has been verified."
    n_type = NotificationType.VERIFICATION_APPROVED
    data = {
        "type": n_type,
        "action": "view_profile",
    }
    Notification.objects.create(
        sender=None, receiver=business_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(business_user, title, message, data)


def notify_verification_rejected(business_user, remarks=""):
    """Notify business when their verification is rejected."""
    title = "Verification Rejected"
    message = "Your business verification request was rejected."
    if remarks:
        message += f" Reason: {remarks}"
    n_type = NotificationType.VERIFICATION_REJECTED
    data = {
        "type": n_type,
        "remarks": remarks,
        "action": "view_profile",
    }
    Notification.objects.create(
        sender=None, receiver=business_user,
        title=title, message=message, type=n_type, data=data,
    )
    _push(business_user, title, message, data)


# ---------------------------------------------------------------------------
# Broadcast (admin → all users)
# ---------------------------------------------------------------------------

def notify_broadcast(title, message, sender_user=None):
    """
    Send a broadcast notification to ALL active users.
    Used for announcements like new features, maintenance, etc.
    Returns count of notifications sent.
    """
    from hisabauth.models import User
    active_users = User.objects.filter(is_active=True)
    n_type = NotificationType.BROADCAST
    data = {
        "type": n_type,
        "action": "view_notifications",
    }

    notifications = []
    for user in active_users:
        notifications.append(Notification(
            sender=sender_user, receiver=user,
            title=title, message=message, type=n_type, data=data,
        ))

    # Bulk create for performance
    Notification.objects.bulk_create(notifications)

    # Send FCM push to all users with tokens
    _push_multiple(list(active_users), title, message, data)

    return len(notifications)
