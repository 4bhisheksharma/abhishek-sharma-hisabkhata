import random
from django.core.mail import send_mail
from django.utils import timezone
from core import settings
from .models import OTP


def generate_otp():
    """Generate a 6-digit OTP"""
    return str(random.randint(100000, 999999))


def send_otp_email(user, purpose='email_verification'):
    """
    Generate and send OTP to user's email
    
    Args:
        user: User object
        purpose: Purpose of OTP ('email_verification', 'password_reset', 'login')
    
    Returns:
        OTP object if successful, raises exception otherwise
    """
    try:
        # Generate OTP
        otp_code = generate_otp()
        
        # Create OTP record
        otp = OTP.objects.create(
            user=user,
            otp_code=otp_code,
            purpose=purpose
        )
        
        # Prepare email content based on purpose
        if purpose == 'email_verification':
            subject = 'Verify Your Email - Hisab Khata'
            message = f'''Hello {user.first_name or user.email},

Thank you for registering with Hisab Khata!

Your OTP for email verification is: {otp_code}

This OTP is valid for 10 minutes.

If you did not request this, please ignore this email.

Best regards,
Hisab Khata Team'''
        elif purpose == 'password_reset':
            subject = 'Reset Your Password - Hisab Khata'
            message = f'''Hello {user.first_name or user.email},

Your OTP for password reset is: {otp_code}

This OTP is valid for 10 minutes.

If you did not request this, please ignore this email and your password will remain unchanged.

Best regards,
Hisab Khata Team'''
        else:
            subject = 'Your OTP - Hisab Khata'
            message = f'''Hello {user.first_name or user.email},

Your OTP is: {otp_code}

This OTP is valid for 10 minutes.

Best regards,
Hisab Khata Team'''
        
        # Send email
        email_from = settings.EMAIL_HOST_USER
        send_mail(subject, message, email_from, [user.email], fail_silently=False)
        
        print(f"OTP sent successfully to {user.email}: {otp_code}")
        return otp
        
    except Exception as e:
        print(f"Error sending OTP email: {str(e)}")
        raise e


def verify_otp(user, otp_code, purpose='email_verification'):
    """
    Verify OTP for a user
    
    Args:
        user: User object
        otp_code: OTP code to verify
        purpose: Purpose of OTP
    
    Returns:
        True if valid, False otherwise
    """
    try:
        # Get the latest unused OTP for this user and purpose
        otp = OTP.objects.filter(
            user=user,
            otp_code=otp_code,
            purpose=purpose,
            is_used=False
        ).order_by('-created_at').first()
        
        if not otp:
            return False
        
        if not otp.is_valid():
            return False
        
        # Mark OTP as used
        otp.is_used = True
        otp.save()
        
        return True
        
    except Exception as e:
        print(f"Error verifying OTP: {str(e)}")
        return False
