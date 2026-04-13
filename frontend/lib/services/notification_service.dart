import '../core/api_config.dart';
import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.notificationsUrl);
      return (response.data as List).map((j) => NotificationModel.fromJson(j)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.dio.patch(ApiConfig.notificationReadUrl(id));
    } catch (e) {
      throw Exception('Failed to mark read');
    }
  }
}
