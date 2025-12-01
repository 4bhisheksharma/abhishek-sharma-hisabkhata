from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Role, UserRole


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ['role_id', 'name', 'created_at', 'updated_at']
    search_fields = ['name']


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['user_id', 'phone_number', 'full_name', 'profile_picture', 'is_active', 'is_premium', 'is_staff']
    list_filter = ['is_active', 'is_premium', 'is_staff', 'preferred_language']
    search_fields = ['phone_number', 'full_name']
    ordering = ['-created_at']
    
    fieldsets = (
        (None, {'fields': ('phone_number', 'password')}),
        ('Personal Info', {'fields': ('full_name', 'profile_picture', 'preferred_language')}),
        ('Permissions', {'fields': ('is_active', 'is_premium', 'is_staff', 'is_superuser')}),
        ('Important dates', {'fields': ('created_at', 'updated_at')}),
    )
    
    readonly_fields = ('created_at', 'updated_at')
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone_number', 'full_name', 'password1', 'password2'),
        }),
    )


@admin.register(UserRole)
class UserRoleAdmin(admin.ModelAdmin):
    list_display = ['user_role_id', 'user', 'role', 'created_at']
    list_filter = ['role']
    search_fields = ['user__phone_number', 'user__full_name', 'role__name']


