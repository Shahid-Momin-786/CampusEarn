from rest_framework import generics, permissions, status
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import ChatMessage
from .serializers import ChatMessageSerializer
from applications.models import Application
from django.db.models import Q

class ChatMessageListCreateView(generics.ListCreateAPIView):
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        application_id = self.kwargs['app_id']
        application = get_object_or_404(Application, id=application_id)
        
        # Ensure only the employer or student of this application can view chat
        user = self.request.user
        if application.student != user and application.job.employer != user:
            return ChatMessage.objects.none()
            
        return ChatMessage.objects.filter(application=application).order_by('created_at')

    def create(self, request, *args, **kwargs):
        application_id = self.kwargs['app_id']
        application = get_object_or_404(Application, id=application_id)
        
        user = request.user
        if application.student != user and application.job.employer != user:
            return Response({"error": "You do not have permission to send a message in this application."}, status=status.HTTP_403_FORBIDDEN)
            
        if application.status != Application.Status.ACCEPTED:
            return Response({"error": "Chat is only available for accepted applications."}, status=status.HTTP_400_BAD_REQUEST)
            
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(application=application, sender=user)
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class ChatMessageDetailView(generics.UpdateAPIView):
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        return ChatMessage.objects.filter(
            Q(application__student=user) | Q(application__job__employer=user)
        )
        
    def patch(self, request, *args, **kwargs):
        message = self.get_object()
        # You can only mark a message as read if you didn't send it
        if message.sender != request.user:
            message.is_read = True
            message.save()
        serializer = self.get_serializer(message)
        return Response(serializer.data)
