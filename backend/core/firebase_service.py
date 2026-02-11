import os
import json
import firebase_admin
from firebase_admin import credentials, messaging
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


class FirebaseService:
    """Service class for Firebase Cloud Messaging operations"""
    
    _app = None
    
    @classmethod
    def initialize_firebase(cls):
        """Initialize Firebase Admin SDK if not already initialized"""
        if not cls._app:
            try:
                # Try to get the credential from environment variable
                firebase_cred_path = settings.FIREBASE_ADMIN_CREDENTIAL
                if firebase_cred_path and os.path.exists(firebase_cred_path):
                    cred = credentials.Certificate(firebase_cred_path)
                    cls._app = firebase_admin.initialize_app(cred)
                    logger.info("Firebase Admin SDK initialized successfully")
                else:
                    logger.error("Firebase credential file not found or not specified")
                    return False
            except Exception as e:
                logger.error(f"Failed to initialize Firebase Admin SDK: {str(e)}")
                return False
        return True
    
    @classmethod
    def send_push_notification(cls, fcm_token, title, body, data=None):
        """
        Send push notification to a single device
        
        Args:
            fcm_token (str): FCM token of the target device
            title (str): Notification title
            body (str): Notification body
            data (dict): Optional additional data
        
        Returns:
            bool: True if successful, False otherwise
        """
        if not cls.initialize_firebase():
            return False
        
        if not fcm_token:
            logger.warning("No FCM token provided")
            return False
        
        try:
            # Ensure all data values are strings (Firebase requirement)
            clean_data = {str(k): str(v) for k, v in (data or {}).items()}
            
            # Create message
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=clean_data,
                token=fcm_token,
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        color="#2196F3",
                        sound="default",
                        channel_id="hisab_khata_notifications",
                        default_sound=True,
                        notification_count=1,
                    )
                ),
                apns=messaging.APNSConfig(
                    headers={'apns-priority': '10'},
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            alert=messaging.ApsAlert(
                                title=title,
                                body=body
                            ),
                            badge=1,
                            sound="default"
                        )
                    )
                )
            )
            
            # Send message
            response = messaging.send(message)
            logger.info(f"Push notification sent successfully: {response}")
            return True
            
        except messaging.InvalidArgumentError as e:
            logger.error(f"Invalid argument for push notification: {str(e)}")
            return False
        except messaging.UnavailableError as e:
            logger.error(f"FCM service unavailable: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"Failed to send push notification: {str(e)}")
            return False
    
    @classmethod
    def send_push_notification_to_multiple(cls, fcm_tokens, title, body, data=None):
        """
        Send push notification to multiple devices
        
        Args:
            fcm_tokens (list): List of FCM tokens
            title (str): Notification title
            body (str): Notification body
            data (dict): Optional additional data
        
        Returns:
            dict: Results containing success and failure counts
        """
        if not cls.initialize_firebase():
            return {"success_count": 0, "failure_count": len(fcm_tokens)}
        
        if not fcm_tokens:
            logger.warning("No FCM tokens provided")
            return {"success_count": 0, "failure_count": 0}
        
        try:
            # Ensure all data values are strings (Firebase requirement)
            clean_data = {str(k): str(v) for k, v in (data or {}).items()}
            
            # Create multicast message
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=clean_data,
                tokens=fcm_tokens,
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        color="#2196F3",
                        sound="default",
                        channel_id="hisab_khata_notifications",
                        default_sound=True,
                        notification_count=1,
                    )
                ),
                apns=messaging.APNSConfig(
                    headers={'apns-priority': '10'},
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            alert=messaging.ApsAlert(
                                title=title,
                                body=body
                            ),
                            badge=1,
                            sound="default"
                        )
                    )
                )
            )
            
            # Send message
            response = messaging.send_multicast(message)
            logger.info(f"Multicast notification sent: {response.success_count} succeeded, {response.failure_count} failed")
            
            return {
                "success_count": response.success_count,
                "failure_count": response.failure_count,
                "responses": response.responses
            }
            
        except Exception as e:
            logger.error(f"Failed to send multicast push notification: {str(e)}")
            return {"success_count": 0, "failure_count": len(fcm_tokens)}
    
    @classmethod
    def send_connection_request_notification(cls, receiver_fcm_token, sender_name, sender_email):
        """
        Send connection request push notification
        
        Args:
            receiver_fcm_token (str): FCM token of the receiver
            sender_name (str): Name of the person sending the request
            sender_email (str): Email of the person sending the request
        
        Returns:
            bool: True if successful, False otherwise
        """
        title = "New Connection Request"
        body = f"{sender_name} sent you a connection request"
        
        data = {
            "type": "connection_request",
            "sender_name": sender_name,
            "sender_email": sender_email,
            "action": "view_requests"
        }
        
        return cls.send_push_notification(receiver_fcm_token, title, body, data)
    
    @classmethod
    def send_request_accepted_notification(cls, requester_fcm_token, accepter_name):
        """
        Send notification when connection request is accepted
        
        Args:
            requester_fcm_token (str): FCM token of the person who sent the request
            accepter_name (str): Name of the person who accepted the request
        
        Returns:
            bool: True if successful, False otherwise
        """
        title = "Connection Request Accepted"
        body = f"{accepter_name} accepted your connection request"
        
        data = {
            "type": "request_accepted",
            "accepter_name": accepter_name,
            "action": "view_connections"
        }
        
        return cls.send_push_notification(requester_fcm_token, title, body, data)
    
    @classmethod
    def send_request_rejected_notification(cls, requester_fcm_token, rejecter_name):
        """
        Send notification when connection request is rejected
        
        Args:
            requester_fcm_token (str): FCM token of the person who sent the request
            rejecter_name (str): Name of the person who rejected the request
        
        Returns:
            bool: True if successful, False otherwise
        """
        title = "Connection Request Rejected"
        body = f"{rejecter_name} rejected your connection request"
        
        data = {
            "type": "request_rejected",
            "rejecter_name": rejecter_name,
            "action": "view_requests"
        }
        
        return cls.send_push_notification(requester_fcm_token, title, body, data)
    
    @classmethod
    def send_connection_deleted_notification(cls, receiver_fcm_token, deleter_name):
        """
        Send notification when a connection is deleted
        
        Args:
            receiver_fcm_token (str): FCM token of the other user
            deleter_name (str): Name of the person who deleted the connection
        
        Returns:
            bool: True if successful, False otherwise
        """
        title = "Connection Deleted"
        body = f"{deleter_name} has removed the connection with you."
        
        data = {
            "type": "connection_deleted",
            "deleter_name": deleter_name,
            "action": "view_connections"
        }
        
        return cls.send_push_notification(receiver_fcm_token, title, body, data)
    
    @classmethod
    def send_notification(cls, fcm_token, title, body, data=None):
        """
        Send a push notification with optional data
        
        Args:
            fcm_token (str): FCM token of the target device
            title (str): Notification title
            body (str): Notification body
            data (dict): Optional additional data
        
        Returns:
            bool: True if successful, False otherwise
        """
        return cls.send_push_notification(fcm_token, title, body, data)