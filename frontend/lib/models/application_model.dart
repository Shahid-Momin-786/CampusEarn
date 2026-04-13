import 'job_model.dart';

class ApplicationModel {
  final int id;
  final int job;
  final int student;
  final String status;
  final String? message;
  final String studentName;
  final JobModel? jobDetails;
  final String createdAt;

  ApplicationModel({
    required this.id,
    required this.job,
    required this.student,
    required this.status,
    this.message,
    required this.studentName,
    this.jobDetails,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      job: json['job'],
      student: json['student'],
      status: json['status'] ?? 'APPLIED',
      message: json['message'],
      studentName: json['student_name'] ?? 'Unknown',
      jobDetails: json['job_details'] != null ? JobModel.fromJson(json['job_details']) : null,
      createdAt: json['created_at'] ?? '',
    );
  }
}
