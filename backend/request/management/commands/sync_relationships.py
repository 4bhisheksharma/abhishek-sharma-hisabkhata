from django.core.management.base import BaseCommand
from request.models import BusinessCustomerRequest
from customer_dashboard.models import CustomerBusinessRelationship


class Command(BaseCommand):
    help = 'Sync existing accepted connections to CustomerBusinessRelationship table'

    def handle(self, *args, **options):
        # Get all accepted connection requests
        accepted_requests = BusinessCustomerRequest.objects.filter(status='accepted')
        
        created_count = 0
        skipped_count = 0
        
        for request in accepted_requests:
            sender = request.sender
            receiver = request.receiver
            
            # Determine who is customer and who is business
            customer = None
            business = None
            
            # Check sender's profile
            if hasattr(sender, 'customer_profile'):
                customer = sender.customer_profile
            if hasattr(sender, 'business_profile'):
                business = sender.business_profile
                
            # Check receiver's profile
            if hasattr(receiver, 'customer_profile'):
                customer = receiver.customer_profile
            if hasattr(receiver, 'business_profile'):
                business = receiver.business_profile
            
            # Create relationship if both exist
            if customer and business:
                relationship, created = CustomerBusinessRelationship.objects.get_or_create(
                    customer=customer,
                    business=business,
                    defaults={
                        'pending_due': 0.00,
                    }
                )
                # Update created_at to match the original request acceptance time
                if created:
                    relationship.created_at = request.updated_at
                    relationship.save(update_fields=['created_at'])
                    created_count += 1
                    self.stdout.write(
                        f'Created: {customer.user.full_name} <-> {business.business_name}'
                    )
                else:
                    skipped_count += 1
            else:
                self.stdout.write(
                    self.style.WARNING(
                        f'Skipped: {sender.email} <-> {receiver.email} (missing customer/business profile)'
                    )
                )
        
        self.stdout.write(
            self.style.SUCCESS(
                f'\nSync complete! Created: {created_count}, Skipped (already exists): {skipped_count}'
            )
        )
