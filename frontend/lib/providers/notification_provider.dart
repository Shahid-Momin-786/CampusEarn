import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true; notifyListeners();
    try {
      _notifications = await _service.getNotifications();
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: id, 
          message: _notifications[index].message, 
          isRead: true, 
          createdAt: _notifications[index].createdAt
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
