import random
from django.core.mail import send_mail
from django.utils import timezone
from core import settings
from .models import OTP


def generate_otp():
    """Generate a 6-digit OTP"""
    return str(random.randint(100000, 999999))


def send_otp_email(email, full_name='User'):
    """
    Generate and send OTP to email
    
    Args:
        email: Email address to send OTP to
        full_name: User's full name for personalization
    
    Returns:
        OTP object if successful, raises exception otherwise
    """
    try:
        # Generate OTP
        otp_code = generate_otp()
        
        # Create OTP record
        otp = OTP.objects.create(
            email=email,
            code=otp_code
        )
        
        # Prepare email content
        subject = 'Verify Your Email - Hisab Khata'
        message = f'''Hello {full_name},

Thank you for registering with Hisab Khata!

Your OTP for email verification is: {otp_code}

This OTP is valid for 10 minutes.

If you did not request this, please ignore this email.

Best regards,
Hisab Khata Team'''
        
        # Send email
        email_from = settings.EMAIL_HOST_USER
        send_mail(subject, message, email_from, [email], fail_silently=False)
        
        print(f"OTP sent successfully to {email}: {otp_code}")
        return otp
        
    except Exception as e:
        print(f"Error sending OTP email: {str(e)}")
        raise e


def verify_otp(email, otp_code):
    """
    Verify OTP for an email
    
    Args:
        email: Email address
        otp_code: OTP code to verify
    
    Returns:
        OTP object if valid, None otherwise
    """
    try:
        # Get the latest unused OTP for this email
        otp = OTP.objects.filter(
            email=email,
            code=otp_code,
            is_used=False
        ).order_by('-created_at').first()
        
        if not otp:
            return None
        
        if not otp.is_valid():
            otp.increment_attempts()
            return None
        
        # Mark OTP as used
        otp.mark_as_used()
        
        return otp
        
    except Exception as e:
        print(f"Error verifying OTP: {str(e)}")
        return None
