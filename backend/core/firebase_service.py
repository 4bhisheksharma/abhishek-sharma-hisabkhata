import os
import json
import firebase_admin
from firebase_admin import credentials, messaging
from firebase_admin import exceptions as firebase_exceptions
from firebase_admin._messaging_utils import UnregisteredError
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

# App theme color — keep in sync with the Flutter AppTheme.primaryBlue
_NOTIFICATION_COLOR = "#00D09E"


def _clear_stale_fcm_token(fcm_token):
    """Clear a stale/unregistered FCM token from all users who have it."""
    try:
        from hisabauth.models import User
        updated = User.objects.filter(fcm_token=fcm_token).update(fcm_token=None)
        if updated:
            logger.info(f"Cleared stale FCM token from {updated} user(s)")
    except Exception as e:
        logger.error(f"Failed to clear stale FCM token: {str(e)}")


class FirebaseService:
    """Service class for Firebase Cloud Messaging operations.

    This is a low-level transport layer. Application code should prefer the
    higher-level helpers in ``notification.services`` which handle both the
    in-app DB record *and* the FCM push in one call.
    """
    
    _app = None
    
    @classmethod
    def initialize_firebase(cls):
        """Initialize Firebase Admin SDK if not already initialized"""
        if not cls._app:
            try:
                firebase_cred_path = getattr(settings, 'FIREBASE_ADMIN_CREDENTIAL', None)
                if not firebase_cred_path:
                    firebase_cred_path = os.path.join(settings.BASE_DIR, 'core', 'firebase-service-account.json')

                if firebase_cred_path and os.path.exists(firebase_cred_path):
                    cred = credentials.Certificate(firebase_cred_path)
                    cls._app = firebase_admin.initialize_app(cred)
                    logger.info("Firebase Admin SDK initialized successfully")
                else:
                    logger.error(f"Firebase credential file not found: {firebase_cred_path}")
                    return False
            except ValueError:
                # App already initialized (e.g. in tests or duplicate call)
                cls._app = firebase_admin.get_app()
                return True
            except Exception as e:
                logger.error(f"Failed to initialize Firebase Admin SDK: {str(e)}")
                return False
        return True
    
    @classmethod
    def _build_android_config(cls):
        """Shared Android notification config."""
        return messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                color=_NOTIFICATION_COLOR,
                sound="default",
                channel_id="hisab_khata_notifications",
                default_sound=True,
                notification_count=1,
            )
        )

    @classmethod
    def _build_apns_config(cls, title, body):
        """Shared APNs notification config."""
        return messaging.APNSConfig(
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

    @classmethod
    def send_push_notification(cls, fcm_token, title, body, data=None):
        """
        Send push notification to a single device.

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
            
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=clean_data,
                token=fcm_token,
                android=cls._build_android_config(),
                apns=cls._build_apns_config(title, body),
            )
            
            response = messaging.send(message)
            logger.info(f"Push notification sent successfully: {response}")
            return True
            
        except UnregisteredError:
            logger.warning("FCM token is unregistered/expired, clearing from DB")
            _clear_stale_fcm_token(fcm_token)
            return False
        except firebase_exceptions.InvalidArgumentError as e:
            logger.error(f"Invalid argument for push notification: {str(e)}")
            return False
        except firebase_exceptions.UnavailableError as e:
            logger.error(f"FCM service unavailable: {str(e)}")
            return False
        except firebase_exceptions.NotFoundError as e:
            logger.error(f"FCM token not found: {str(e)}")
            _clear_stale_fcm_token(fcm_token)
            return False
        except Exception as e:
            logger.error(f"Failed to send push notification: {str(e)}")
            return False
    
    @classmethod
    def send_push_notification_to_multiple(cls, fcm_tokens, title, body, data=None):
        """
        Send push notification to multiple devices using ``send_each_for_multicast``
        (the non-deprecated replacement for ``send_multicast``).

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
            clean_data = {str(k): str(v) for k, v in (data or {}).items()}
            
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=clean_data,
                tokens=fcm_tokens,
                android=cls._build_android_config(),
                apns=cls._build_apns_config(title, body),
            )
            
            # Use send_each_for_multicast (replaces deprecated send_multicast)
            response = messaging.send_each_for_multicast(message)
            logger.info(
                f"Multicast notification sent: {response.success_count} succeeded, "
                f"{response.failure_count} failed"
            )

            # Cleanup stale tokens
            for idx, send_resp in enumerate(response.responses):
                if send_resp.exception and isinstance(
                    send_resp.exception, (UnregisteredError, firebase_exceptions.NotFoundError)
                ):
                    _clear_stale_fcm_token(fcm_tokens[idx])
            
            return {
                "success_count": response.success_count,
                "failure_count": response.failure_count,
            }
            
        except Exception as e:
            logger.error(f"Failed to send multicast push notification: {str(e)}")
            return {"success_count": 0, "failure_count": len(fcm_tokens)}