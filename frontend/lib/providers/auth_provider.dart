import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      await _storage.write(key: 'access_token', value: data['access']);
      await _storage.write(key: 'refresh_token', value: data['refresh']);
      
      await fetchProfile();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    try {
      _user = await _authService.getProfile();
    } catch (e) {
      // Invalid token, logout smoothly
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      _isLoading = true;
      notifyListeners();
      await fetchProfile();
      if (_user == null) {
          _isLoading = false;
          notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    _user = null;
    notifyListeners();
  }

  Future<String?> updateStudentProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.updateStudentProfile(data);
      await fetchProfile();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> updateEmployerProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.updateEmployerProfile(data);
      await fetchProfile();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}
