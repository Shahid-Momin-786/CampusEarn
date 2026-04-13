import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'campusearn.settings')
django.setup()

from django.contrib.auth import get_user_model
from jobs.models import Job

User = get_user_model()

# Create Employer
employer, created = User.objects.get_or_create(
    email='employer_seed@example.com',
    defaults={
        'first_name': 'Seed',
        'last_name': 'Employer',
        'role': 'EMPLOYER'
    }
)

if created:
    employer.set_password('password123')
    employer.save()

# Create Jobs
jobs_data = [
    {
        'title': 'Library Assistant',
        'description': 'Help organize books at the local library.',
        'requirements': 'Must be able to lift 20 lbs.',
        'hourly_rate': '15.00',
        'location_name': 'NY Public Library',
        'latitude': '40.7532',
        'longitude': '-73.9822',
        'employer': employer
    },
    {
        'title': 'Campus Guide',
        'description': 'Guide new students around the campus.',
        'requirements': 'Good communication skills.',
        'hourly_rate': '18.50',
        'location_name': 'Washington Square Park',
        'latitude': '40.7308',
        'longitude': '-73.9973',
        'employer': employer
    },
    {
        'title': 'Cafe Barista',
        'description': 'Make coffee for students.',
        'requirements': 'Previous experience preferred.',
        'hourly_rate': '16.00',
        'location_name': 'Joe Coffee',
        'latitude': '40.7150',
        'longitude': '-74.0080', 
        'employer': employer
    }
]

for jd in jobs_data:
    Job.objects.get_or_create(title=jd['title'], defaults=jd)

print('Successfully seeded 3 jobs!')
