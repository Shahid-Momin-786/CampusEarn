import 'package:dio/dio.dart';
import '../core/api_config.dart';
import '../models/application_model.dart';
import 'api_client.dart';

class ApplicationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ApplicationModel>> getStudentApplications() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.studentApplicationsUrl);
      return (response.data as List).map((json) => ApplicationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to load applications');
    }
  }

  Future<List<ApplicationModel>> getEmployerApplications() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.employerApplicationsUrl);
      return (response.data as List).map((json) => ApplicationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to load applicants');
    }
  }

  Future<ApplicationModel> applyForJob(int jobId, {String? message}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.studentApplicationsUrl,
        data: {
          'job': jobId,
          'message': message,
        },
      );
      return ApplicationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to apply for job');
    }
  }

  Future<ApplicationModel> updateApplicationStatus(int applicationId, String status) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConfig.employerApplicationsUrl}$applicationId/decision/',
        data: {'status': status},
      );
      return ApplicationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update status');
    }
  }
}
