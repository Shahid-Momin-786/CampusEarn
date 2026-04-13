from django.db import models
from django.contrib.auth import get_user_model
from jobs.models import Job

User = get_user_model()

class Application(models.Model):
    class Status(models.TextChoices):
        APPLIED = 'APPLIED', 'Applied'
        ACCEPTED = 'ACCEPTED', 'Accepted'
        REJECTED = 'REJECTED', 'Rejected'
        COMPLETED = 'COMPLETED', 'Completed'

    job = models.ForeignKey(Job, on_delete=models.CASCADE, related_name='applications')
    student = models.ForeignKey(User, on_delete=models.CASCADE, limit_choices_to={'role': 'STUDENT'}, related_name='applications')
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.APPLIED)
    message = models.TextField(blank=True, null=True, help_text="Optional cover letter or message from student")
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        # Prevent a student from applying to the same job twice
        unique_together = ('job', 'student')

    def __str__(self):
        return f"{self.student.email} applied for {self.job.title} - {self.status}"
