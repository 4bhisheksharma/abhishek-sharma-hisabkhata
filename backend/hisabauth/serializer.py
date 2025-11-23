from rest_framework import serializers
from .models import User, Role, UserRole, Customer, Business


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User registration"""
    password = serializers.CharField(write_only=True, min_length=8)
    role = serializers.CharField(write_only=True)
    business_name = serializers.CharField(write_only=True, required=False)
    
    class Meta:
        model = User
        fields = [
            'email', 'phone_number', 'password', 'full_name', 
            'role', 'business_name', 'preferred_language'
        ]
        extra_kwargs = {
            'phone_number': {'required': False, 'allow_null': True, 'allow_blank': True},
            'preferred_language': {'required': False, 'default': 'en'}
        }
    
    def validate_role(self, value):
        """Validate that the role exists"""
        try:
            role = Role.objects.get(name__iexact=value)
            return role
        except Role.DoesNotExist:
            raise serializers.ValidationError(
                f"Role '{value}' does not exist. Valid roles are: customer, business"
            )
    
    def validate_email(self, value):
        """Validate email uniqueness"""
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("This email is already registered")
        return value
    
    def validate_phone_number(self, value):
        """Validate phone number format and uniqueness if provided"""
        if value and User.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError("This phone number is already registered")
        return value
    
    def create(self, validated_data):
        """Create user with role and profile"""
        role = validated_data.pop('role')
        business_name = validated_data.pop('business_name', None)
        password = validated_data.pop('password')
        
        # Create user (initially inactive until OTP verified)
        user = User.objects.create(
            email=validated_data['email'],
            phone_number=validated_data.get('phone_number'),
            full_name=validated_data['full_name'],
            preferred_language=validated_data.get('preferred_language', 'en'),
            is_active=False
        )
        user.set_password(password)
        user.save()
        
        # Assign role through UserRole
        UserRole.objects.create(user=user, role=role)
        
        # Create profile based on role
        if role.name.lower() == 'customer':
            Customer.objects.create(user=user, status='active')
        elif role.name.lower() == 'business':
            Business.objects.create(
                user=user,
                business_name=business_name or user.full_name,
                is_verified=False,
                is_active=False
            )
        
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for user profile data"""
    roles = serializers.SerializerMethodField()
    profile_type = serializers.SerializerMethodField()
    id = serializers.IntegerField(source='user_id', read_only=True)
    
    class Meta:
        model = User
        fields = [
            'id', 'user_id', 'email', 'phone_number', 'full_name', 'profile_picture',
            'preferred_language', 'is_active', 'is_premium', 
            'roles', 'profile_type', 'created_at'
        ]
        read_only_fields = ['id', 'user_id', 'created_at']
    
    def get_roles(self, obj):
        """Get all roles assigned to user"""
        return [ur.role.name for ur in obj.user_roles.all()]
    
    def get_profile_type(self, obj):
        """Get profile type (customer or business)"""
        if hasattr(obj, 'customer_profile'):
            return 'customer'
        elif hasattr(obj, 'business_profile'):
            return 'business'
        return None