from django.core.management.base import BaseCommand
from hisabauth.models import Role


class Command(BaseCommand):
    help = 'Create default roles (customer and business)'

    def handle(self, *args, **kwargs):
        roles = ['customer', 'business', 'admin']
        
        for role_name in roles:
            role, created = Role.objects.get_or_create(name=role_name)
            if created:
                self.stdout.write(self.style.SUCCESS(f'Successfully created role: {role.name}'))
            else:
                self.stdout.write(self.style.WARNING(f'Role already exists: {role.name}'))