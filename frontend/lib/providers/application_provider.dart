import 'package:flutter/foundation.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

class ApplicationProvider with ChangeNotifier {
  final ApplicationService _applicationService = ApplicationService();
  
  List<ApplicationModel> _studentApplications = [];
  List<ApplicationModel> _employerApplications = [];
  
  bool _isLoading = false;
  String? _error;

  List<ApplicationModel> get studentApplications => _studentApplications;
  List<ApplicationModel> get employerApplications => _employerApplications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStudentApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _studentApplications = await _applicationService.getStudentApplications();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEmployerApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employerApplications = await _applicationService.getEmployerApplications();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForJob(int jobId, {String? message}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newApp = await _applicationService.applyForJob(jobId, message: message);
      _studentApplications.insert(0, newApp);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateApplicationStatus(int applicationId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _applicationService.updateApplicationStatus(applicationId, status);
      // Re-fetch fresh list from server — ensures Messages tab also reflects the new ACCEPTED status
      _employerApplications = await _applicationService.getEmployerApplications();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
