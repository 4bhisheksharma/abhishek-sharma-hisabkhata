"""
Management command: Send due reminders to customers with overdue balances.

Usage:
    python manage.py send_due_reminders
    python manage.py send_due_reminders --min-amount 100
    python manage.py send_due_reminders --days-overdue 7

Can be scheduled as a cron job / Celery beat task.
"""
from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from decimal import Decimal

from customer_dashboard.models import CustomerBusinessRelationship
from notification.services import notify_due_reminder

import logging
logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = 'Send due reminders to customers with outstanding (positive) pending_due.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--min-amount',
            type=float,
            default=0.01,
            help='Minimum pending_due to trigger a reminder (default: 0.01)',
        )
        parser.add_argument(
            '--days-overdue',
            type=int,
            default=0,
            help='Only remind if no transaction in the last N days (default: 0 = always)',
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Preview what would be sent without actually sending.',
        )

    def handle(self, *args, **options):
        min_amount = Decimal(str(options['min_amount']))
        days_overdue = options['days_overdue']
        dry_run = options['dry_run']

        relationships = CustomerBusinessRelationship.objects.filter(
            pending_due__gte=min_amount,
            status='active',
        ).select_related('customer__user', 'business__user')

        if days_overdue > 0:
            cutoff = timezone.now() - timedelta(days=days_overdue)
            # Exclude relationships that had a transaction after cutoff
            relationships = relationships.exclude(
                transactions__transaction_date__gte=cutoff
            )

        count = 0
        for rel in relationships:
            business_user = rel.business.user
            customer_user = rel.customer.user
            amount = rel.pending_due

            if dry_run:
                self.stdout.write(
                    f"[DRY RUN] Would remind {customer_user.email} "
                    f"about Rs. {amount:.2f} owed to {business_user.full_name}"
                )
            else:
                try:
                    notify_due_reminder(
                        business_user=business_user,
                        customer_user=customer_user,
                        amount=amount,
                        relationship_id=rel.relationship_id,
                    )
                    count += 1
                except Exception as e:
                    logger.error(f"Due reminder failed for relationship {rel.relationship_id}: {e}")

        self.stdout.write(self.style.SUCCESS(
            f"{'[DRY RUN] ' if dry_run else ''}Sent {count} due reminder(s)."
        ))
