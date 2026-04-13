from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from .models import Application
from .serializers import ApplicationSerializer
from jobs.models import Job

class StudentApplicationView(generics.ListCreateAPIView):
    """
    Students can view their applications and apply for a job.
    """
    serializer_class = ApplicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Application.objects.filter(student=self.request.user).order_by('-created_at')

    def create(self, request, *args, **kwargs):
        if request.user.role != 'STUDENT':
            return Response({"error": "Only students can apply for jobs."}, status=status.HTTP_403_FORBIDDEN)
            
        job_id = request.data.get('job')
        if not job_id:
            return Response({"error": "Job ID is required."}, status=status.HTTP_400_BAD_REQUEST)

        job = get_object_or_404(Job, id=job_id)
        
        # Check if already applied
        if Application.objects.filter(student=request.user, job=job).exists():
            return Response({"error": "You have already applied for this job."}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(student=request.user, job=job)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class StudentApplicationDetailView(generics.RetrieveAPIView):
    """
    Students can view details of a specific application.
    """
    serializer_class = ApplicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Application.objects.filter(student=self.request.user)


class EmployerApplicationView(generics.ListAPIView):
    """
    Employers view all applications made to their posted jobs.
    """
    serializer_class = ApplicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Application.objects.filter(job__employer=self.request.user).order_by('-created_at')


class EmployerApplicationDecisionView(APIView):
    """
    Employers can accept or reject an application.
    """
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        application = get_object_or_404(Application, pk=pk, job__employer=request.user)
        
        new_status = request.data.get('status')
        if new_status not in [Application.Status.ACCEPTED, Application.Status.REJECTED]:
            return Response(
                {"error": "Invalid status. Must be 'ACCEPTED' or 'REJECTED'."}, 
                status=status.HTTP_400_BAD_REQUEST
            )
            
        application.status = new_status
        application.save()
        
        # Trigger notification to student
        from notifications.models import Notification
        status_text = "accepted" if new_status == Application.Status.ACCEPTED else "rejected"
        Notification.objects.create(
            user=application.student,
            message=f"Your application for '{application.job.title}' has been {status_text}."
        )
        
        serializer = ApplicationSerializer(application)
        return Response(serializer.data)
