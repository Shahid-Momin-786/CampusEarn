import 'package:dio/dio.dart';
import '../core/api_config.dart';
import '../models/chat_model.dart';
import 'api_client.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ChatMessageModel>> getMessages(int appId) async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.chatMessagesUrl(appId));
      return (response.data as List).map((j) => ChatMessageModel.fromJson(j)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?.toString() ?? 'Failed to load messages';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to load messages');
    }
  }

  Future<ChatMessageModel> sendMessage(int appId, String content) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.chatMessagesUrl(appId),
        data: {'message': content},
      );
      return ChatMessageModel.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ??
          e.response?.data?.toString() ??
          'Failed to send message';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to send message');
    }
  }
}
