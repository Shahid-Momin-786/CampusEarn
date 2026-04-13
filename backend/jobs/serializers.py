from rest_framework import serializers
from .models import Job

class JobSerializer(serializers.ModelSerializer):
    employer_name = serializers.CharField(source='employer.first_name', read_only=True)
    employer_company = serializers.CharField(source='employer.employer_profile.company_name', read_only=True, default="Company")
    distance_km = serializers.FloatField(read_only=True, required=False) # Will be dynamically added by list views

    class Meta:
        model = Job
        fields = '__all__'
        read_only_fields = ('employer', 'is_active', 'created_at', 'updated_at')
