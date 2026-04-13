class JobModel {
  final int id;
  final String employerName;
  final String employerCompany;
  final String title;
  final String description;
  final String? requirements;
  final double hourlyRate;
  final String? locationName;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final bool isActive;
  final String createdAt;

  JobModel({
    required this.id,
    required this.employerName,
    required this.employerCompany,
    required this.title,
    required this.description,
    this.requirements,
    required this.hourlyRate,
    this.locationName,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    required this.isActive,
    required this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      employerName: json['employer_name'] ?? 'Unknown',
      employerCompany: json['employer_company'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'],
      hourlyRate: double.tryParse(json['hourly_rate']?.toString() ?? '0') ?? 0.0,
      locationName: json['location_name'],
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] ?? '',
    );
  }
}
