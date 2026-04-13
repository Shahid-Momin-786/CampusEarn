from django.urls import path
from .views import ChatMessageListCreateView, ChatMessageDetailView

urlpatterns = [
    path('chat/<int:app_id>/', ChatMessageListCreateView.as_view(), name='chat-list-create'),
    path('chat/message/<int:pk>/read/', ChatMessageDetailView.as_view(), name='chat-message-read'),
]
