from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Job
from .serializers import JobSerializer
from .utils import calculate_haversine_distance, get_bounding_box
from users.models import CustomUser

class EmployerJobListView(generics.ListCreateAPIView):
    """
    Employers can list their posted jobs and create new ones.
    """
    serializer_class = JobSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Job.objects.filter(employer=self.request.user).order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(employer=self.request.user)


class EmployerJobDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Employers can update or delete their own jobs.
    """
    serializer_class = JobSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Job.objects.filter(employer=self.request.user)


class NearbyJobsView(APIView):
    """
    Students can fetch active jobs near their specified location.
    Query params required: ?lat=XXX&lng=YYY&radius=ZZ
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        lat = request.query_params.get('lat')
        lng = request.query_params.get('lng')
        radius = request.query_params.get('radius', 10)  # default 10km

        if not lat or not lng:
            return Response({"error": "Please provide 'lat' and 'lng' query parameters."}, 
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            user_lat = float(lat)
            user_lng = float(lng)
            radius_km = float(radius)
        except ValueError:
            return Response({"error": "Invalid coordinates or radius."}, 
                            status=status.HTTP_400_BAD_REQUEST)

        # 1. Broad filter using Bounding Box (Fast DB query)
        min_lat, max_lat, min_lng, max_lng = get_bounding_box(user_lat, user_lng, radius_km)
        
        queryset = Job.objects.filter(
            is_active=True,
            latitude__gte=min_lat, latitude__lte=max_lat,
            longitude__gte=min_lng, longitude__lte=max_lng
        )

        # 2. Precise Haversine calculation in Python
        jobs_with_distance = []
        for job in queryset:
            dist = calculate_haversine_distance(user_lat, user_lng, float(job.latitude), float(job.longitude))
            if dist <= radius_km:
                job.distance_km = round(dist, 2)
                jobs_with_distance.append(job)

        # 3. Sort by distance
        jobs_with_distance.sort(key=lambda x: x.distance_km)

        # 4. Serialize
        serializer = JobSerializer(jobs_with_distance, many=True)
        return Response(serializer.data)
