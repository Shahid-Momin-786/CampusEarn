class ApiConfig {
  // Use 10.0.2.2 for Android emulator to hit localhost
  // Use localhost or actual IP for iOS simulator / web
  // We'll use a standard local IP format that typically works
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  static const String loginUrl = '/auth/login/';
  static const String registerUrl = '/auth/register/';
  static const String userProfileUrl = '/users/profile/';
  static const String nearbyJobsUrl = '/jobs/nearby/';
  static const String employerJobsUrl = '/jobs/employer/';
  static const String studentApplicationsUrl = '/applications/student/';
  static const String employerApplicationsUrl = '/applications/employer/';

  static String chatMessagesUrl(int appId) => '/chat/$appId/';
  static const String notificationsUrl = '/notifications/';
  static String notificationReadUrl(int id) => '/notifications/$id/read/';
  static const String updateStudentProfileUrl = '/users/student-profile/update/';
  static const String updateEmployerProfileUrl = '/users/employer-profile/update/';
}
