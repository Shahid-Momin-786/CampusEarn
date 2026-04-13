from rest_framework import serializers
from .models import ChatMessage

class ChatMessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source='sender.first_name', read_only=True)
    sender_email = serializers.CharField(source='sender.email', read_only=True)

    class Meta:
        model = ChatMessage
        fields = ['id', 'application', 'sender', 'sender_name', 'sender_email', 'message', 'is_read', 'created_at']
        read_only_fields = ['id', 'application', 'sender', 'is_read', 'created_at']
