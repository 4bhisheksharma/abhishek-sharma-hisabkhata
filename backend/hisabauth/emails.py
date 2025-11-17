import random
from django.core.mail import send_mail
from core import settings
from .models import User

def send_verification_email(email):
    try:
        subject = 'Verify your email'
        otp = random.randint(100000, 999999)
        message = f'Your OTP for email verification is: {otp}\n\nThis OTP is valid for 10 minutes.'
        email_from = settings.EMAIL_HOST_USER
        
        # Save OTP first
        user_obj = User.objects.get(email=email)
        user_obj.otp = str(otp)
        user_obj.save()
        
        # Send email with fail_silently=False to raise exceptions
        send_mail(subject, message, email_from, [email], fail_silently=False)
        print(f"OTP sent successfully to {email}: {otp}")
        return True
    except Exception as e:
        print(f"Error sending email: {str(e)}")
        raise e