import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _service = ChatService();
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  int? _activeAppId;

  // Total unread messages across ALL chats (for the bottom nav badge)
  int _totalUnread = 0;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalUnread => _totalUnread;

  // Count unread in the CURRENT open chat (messages not sent by me)
  int unreadCount(int myUserId) =>
      _messages.where((m) => !m.isRead && m.sender != myUserId).length;

  void clearMessages() {
    _messages = [];
    _error = null;
    _activeAppId = null;
    notifyListeners();
  }

  /// Poll all accepted application IDs to count total unread messages.
  /// Called from the dashboard on a timer.
  Future<void> refreshUnreadCount(List<int> appIds, int myUserId) async {
    if (appIds.isEmpty) {
      if (_totalUnread != 0) {
        _totalUnread = 0;
        notifyListeners();
      }
      return;
    }
    int count = 0;
    for (final appId in appIds) {
      try {
        final msgs = await _service.getMessages(appId);
        count += msgs.where((m) => !m.isRead && m.sender != myUserId).length;
      } catch (_) {}
    }
    if (count != _totalUnread) {
      _totalUnread = count;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int appId, {bool silent = false}) async {
    _activeAppId = appId;
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final fetched = await _service.getMessages(appId);
      if (_activeAppId == appId) {
        _messages = fetched;
        notifyListeners();
      }
    } catch (e) {
      if (!silent && _activeAppId == appId) {
        _error = e.toString().replaceAll('Exception: ', '');
        notifyListeners();
      }
    } finally {
      if (!silent && _activeAppId == appId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Returns null on success, or an error string on failure.
  Future<String?> sendMessage(int appId, String content) async {
    try {
      final newMsg = await _service.sendMessage(appId, content);
      _messages.add(newMsg);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}
