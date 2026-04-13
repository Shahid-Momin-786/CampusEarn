import 'package:dio/dio.dart';
import '../core/api_config.dart';
import '../models/job_model.dart';
import 'api_client.dart';

class JobService {
  final ApiClient _apiClient = ApiClient();

  Future<List<JobModel>> getNearbyJobs(double lat, double lng, {double radius = 10}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConfig.nearbyJobsUrl,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
        },
      );
      return (response.data as List).map((json) => JobModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to load nearby jobs');
    }
  }

  Future<List<JobModel>> getEmployerJobs() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.employerJobsUrl);
      return (response.data as List).map((json) => JobModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to load employer jobs');
    }
  }

  Future<JobModel> createJob(Map<String, dynamic> jobData) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.employerJobsUrl,
        data: jobData,
      );
      return JobModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to create job');
    }
  }
}
