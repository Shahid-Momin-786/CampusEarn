from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    RegisterView,
    CustomTokenObtainPairView,
    LogoutView,
    UserProfileView,
    UpdateStudentProfileView,
    UpdateEmployerProfileView,
)

urlpatterns = [
    # Auth endpoints
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', CustomTokenObtainPairView.as_view(), name='login'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/logout/', LogoutView.as_view(), name='logout'),
    
    # User Profile endpoints
    path('users/profile/', UserProfileView.as_view(), name='user_profile'),
    path('users/student-profile/update/', UpdateStudentProfileView.as_view(), name='update_student_profile'),
    path('users/employer-profile/update/', UpdateEmployerProfileView.as_view(), name='update_employer_profile'),
]
