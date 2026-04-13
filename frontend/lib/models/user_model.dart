class StudentProfileData {
  final String university;
  final String major;
  final String skills;
  final String bio;
  final bool availability;

  StudentProfileData({
    this.university = '',
    this.major = '',
    this.skills = '',
    this.bio = '',
    this.availability = true,
  });

  factory StudentProfileData.fromJson(Map<String, dynamic> json) {
    return StudentProfileData(
      university: json['university'] ?? '',
      major: json['major'] ?? '',
      skills: json['skills'] ?? '',
      bio: json['bio'] ?? '',
      availability: json['availability'] ?? true,
    );
  }
}

class EmployerProfileData {
  final String companyName;
  final String companyDescription;
  final String website;

  EmployerProfileData({
    this.companyName = '',
    this.companyDescription = '',
    this.website = '',
  });

  factory EmployerProfileData.fromJson(Map<String, dynamic> json) {
    return EmployerProfileData(
      companyName: json['company_name'] ?? '',
      companyDescription: json['company_description'] ?? '',
      website: json['website'] ?? '',
    );
  }
}

class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final StudentProfileData? studentProfile;
  final EmployerProfileData? employerProfile;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.studentProfile,
    this.employerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'STUDENT',
      studentProfile: json['student_profile'] != null
          ? StudentProfileData.fromJson(json['student_profile'])
          : null,
      employerProfile: json['employer_profile'] != null
          ? EmployerProfileData.fromJson(json['employer_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    };
  }
}
