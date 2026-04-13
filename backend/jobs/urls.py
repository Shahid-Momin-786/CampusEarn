from django.urls import path
from .views import (
    EmployerJobListView,
    EmployerJobDetailView,
    NearbyJobsView,
)

urlpatterns = [
    # Employer endpoints
    path('jobs/employer/', EmployerJobListView.as_view(), name='employer_jobs'),
    path('jobs/employer/<int:pk>/', EmployerJobDetailView.as_view(), name='employer_job_detail'),
    
    # Student endpoints
    path('jobs/nearby/', NearbyJobsView.as_view(), name='nearby_jobs'),
]
