import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';

class JobProvider with ChangeNotifier {
  final JobService _jobService = JobService();
  
  List<JobModel> _nearbyJobs = [];
  List<JobModel> _employerJobs = [];
  
  bool _isLoading = false;
  String? _error;

  List<JobModel> get nearbyJobs => _nearbyJobs;
  List<JobModel> get employerJobs => _employerJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNearbyJobs(double lat, double lng, {double radius = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _nearbyJobs = await _jobService.getNearbyJobs(lat, lng, radius: radius);
      
      // Fallback dummy data if backend is empty so the UI doesn't look empty
      if (_nearbyJobs.isEmpty) {
        _nearbyJobs = [
          JobModel(
            id: 101,
            employerName: 'Alice Anderson',
            employerCompany: 'Central Library',
            title: 'Library Assistant',
            description: 'Help organize books, assist students with locating materials, and manage checkout desk.',
            requirements: 'Friendly demeanor, organized, can lift 20 lbs.',
            hourlyRate: 15.50,
            locationName: 'Campus Library Main Building',
            latitude: 40.7128,
            longitude: -74.0060,
            distanceKm: 0.5,
            isActive: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
          JobModel(
            id: 102,
            employerName: 'Bob Builder',
            employerCompany: 'Campus Cafe',
            title: 'Barista (Part-Time)',
            description: 'Brew coffee, serve pastries, and maintain a clean workspace during morning shifts.',
            requirements: 'Previous barista experience goes a long way. Must handle fast-paced environment.',
            hourlyRate: 17.00,
            locationName: 'Student Union Building',
            latitude: 40.7138,
            longitude: -74.0070,
            distanceKm: 1.2,
            isActive: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
          JobModel(
            id: 103,
            employerName: 'Carol Chemistry',
            employerCompany: 'Science Dept',
            title: 'Undergraduate Lab Tutor',
            description: 'Tutor 1st year students in basic chemistry lab procedures and safety protocols.',
            requirements: 'Completed Chem 101/102 with A grade.',
            hourlyRate: 20.00,
            locationName: 'Science Wing Room 304',
            latitude: 40.7110,
            longitude: -74.0050,
            distanceKm: 2.1,
            isActive: true,
            createdAt: DateTime.now().toIso8601String(),
          ),
        ];
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEmployerJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employerJobs = await _jobService.getEmployerJobs();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJob(Map<String, dynamic> jobData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newJob = await _jobService.createJob(jobData);
      _employerJobs.insert(0, newJob); // Insert at top
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
