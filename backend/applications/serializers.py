from rest_framework import serializers
from .models import Application
from jobs.serializers import JobSerializer

class ApplicationSerializer(serializers.ModelSerializer):
    student_name = serializers.CharField(source='student.first_name', read_only=True)
    job_details = JobSerializer(source='job', read_only=True)

    class Meta:
        model = Application
        fields = '__all__'
        read_only_fields = ('student', 'status', 'created_at', 'updated_at')
