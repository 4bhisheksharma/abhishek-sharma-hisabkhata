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
        
        # Plain text version
        text_message = f'''Hello {full_name},

Your verification code is: {otp_code}

This code expires in 10 minutes.

If you didn't request this, please ignore this email.

- Hisab Khata Team'''
        
        # HTML version
        html_message = f'''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f5f5f5; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 500px; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #00D09E 0%, #00BF92 100%); padding: 32px 24px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;">Hisab Khata</h1>
                        </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 32px;">
                            <p style="margin: 0 0 24px 0; color: #212121; font-size: 16px; line-height: 1.5;">Hello <strong>{full_name}</strong>,</p>
                            
                            <p style="margin: 0 0 32px 0; color: #757575; font-size: 14px; line-height: 1.6;">Your verification code is:</p>
                            
                            <!-- OTP Box -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 0 0 32px 0;">
                                        <div style="display: inline-block; background-color: #E0F7F1; border-radius: 8px; padding: 20px 40px;">
                                            <span style="font-size: 32px; font-weight: 700; color: #00D09E; letter-spacing: 8px; font-family: 'Courier New', monospace;">{otp_code}</span>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin: 0 0 24px 0; color: #757575; font-size: 13px; line-height: 1.5; text-align: center;">This code expires in <strong style="color: #212121;">10 minutes</strong></p>
                            
                            <p style="margin: 0; color: #9e9e9e; font-size: 12px; line-height: 1.5; text-align: center;">If you didn't request this, please ignore this email.</p>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #fafafa; padding: 24px 32px; text-align: center; border-top: 1px solid #e0e0e0;">
                            <p style="margin: 0; color: #9e9e9e; font-size: 12px;">© 2025 Hisab Khata. All rights reserved.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
        '''
        
        # Send email with both plain text and HTML
        email_from = settings.EMAIL_HOST_USER
        from django.core.mail import EmailMultiAlternatives
        
        email_message = EmailMultiAlternatives(
            subject=subject,
            body=text_message,
            from_email=email_from,
            to=[email]
        )
        email_message.attach_alternative(html_message, "text/html")
        email_message.send(fail_silently=False)
        
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
