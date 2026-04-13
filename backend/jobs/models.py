from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Job(models.Model):
    employer = models.ForeignKey(User, on_delete=models.CASCADE, limit_choices_to={'role': 'EMPLOYER'}, related_name='posted_jobs')
    title = models.CharField(max_length=255)
    description = models.TextField()
    requirements = models.TextField(blank=True, null=True)
    hourly_rate = models.DecimalField(max_digits=10, decimal_places=2)
    
    # Location fields
    location_name = models.CharField(max_length=255, blank=True, null=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    
    # Metadata
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} at {self.employer.first_name or self.employer.email}"
