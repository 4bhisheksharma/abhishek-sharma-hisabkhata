from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    
    class Meta:
        model = User
        fields = ['email', 'password', 'first_name', 'last_name', 'is_verified']
        extra_kwargs = {
            'is_verified': {'read_only': True}
        }
    
    def save(self, commit=True, **kwargs):
        # Create user instance without saving to database
        user = User(
            email=self.validated_data['email'],
            first_name=self.validated_data.get('first_name', ''),
            last_name=self.validated_data.get('last_name', '')
        )
        user.set_password(self.validated_data['password'])
        
        if commit:
            user.save()
        
        return user