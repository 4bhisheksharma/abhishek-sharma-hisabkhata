from django.core.management.base import BaseCommand
from hisabauth.models import Role


class Command(BaseCommand):
    help = 'Create default roles (customer and business)'

    def handle(self, *args, **kwargs):
        roles = [
            {'name': 'customer', 'description': 'Regular customer who can manage personal finances'},
            {'name': 'business', 'description': 'Business owner who can manage business finances'},
        ]
        
        for role_data in roles:
            role, created = Role.objects.get_or_create(
                name=role_data['name'],
                defaults={'description': role_data['description']}
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Successfully created role: {role.name}'))
            else:
                self.stdout.write(self.style.WARNING(f'Role already exists: {role.name}'))