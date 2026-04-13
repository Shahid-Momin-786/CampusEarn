import 'package:dio/dio.dart';
import '../core/api_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.loginUrl,
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.registerUrl,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Registration failed');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.userProfileUrl);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to load profile');
    }
  }

  Future<void> updateStudentProfile(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.patch(ApiConfig.updateStudentProfileUrl, data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update profile');
    }
  }

  Future<void> updateEmployerProfile(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.patch(ApiConfig.updateEmployerProfileUrl, data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Failed to update profile');
    }
  }
}
