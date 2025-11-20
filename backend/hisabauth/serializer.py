from rest_framework import serializers
from .models import User, Role

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    role = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['email', 'password', 'first_name', 'last_name', 'role', 'is_verified']
        extra_kwargs = {
            'is_verified': {'read_only': True}
        }
    
    def validate_role(self, value):
        """Validate that the role exists"""
        try:
            role = Role.objects.get(name__iexact=value)
            return role
        except Role.DoesNotExist:
            raise serializers.ValidationError(f"Role '{value}' does not exist. Valid roles are: customer, business")
    
    def save(self, commit=True, **kwargs):
        # Create user instance without saving to database
        user = User(
            email=self.validated_data['email'],
            first_name=self.validated_data.get('first_name', ''),
            last_name=self.validated_data.get('last_name', ''),
            role=self.validated_data['role']
        )
        user.set_password(self.validated_data['password'])
        
        if commit:
            user.save()
        
        return user