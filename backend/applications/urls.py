from django.urls import path
from .views import (
    StudentApplicationView,
    StudentApplicationDetailView,
    EmployerApplicationView,
    EmployerApplicationDecisionView
)

urlpatterns = [
    # Student endpoints
    path('applications/student/', StudentApplicationView.as_view(), name='student_applications'),
    path('applications/student/<int:pk>/', StudentApplicationDetailView.as_view(), name='student_application_detail'),
    
    # Employer endpoints
    path('applications/employer/', EmployerApplicationView.as_view(), name='employer_applications'),
    path('applications/employer/<int:pk>/decision/', EmployerApplicationDecisionView.as_view(), name='employer_application_decision'),
]
