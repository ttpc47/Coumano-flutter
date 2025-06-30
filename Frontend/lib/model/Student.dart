// lib/model/student.dart
// import 'package:intl/intl.dart';
// import './specialty.dart'; // Import Speciality if needed for full object

class Student {
  final String id;
  final String speciality; // UUID of the speciality
  final String firstName;
  final String lastName;
  final String studentId;
  final String email;
  final DateTime? dateOfBirth;
  final DateTime? enrollmentDate;
  final String? specialityName; // For display purposes
  final String? departmentName; // For display purposes

  Student({
    required this.id,
    required this.speciality,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.email,
    this.dateOfBirth,
    this.enrollmentDate,
    this.specialityName,
    this.departmentName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      speciality: json['speciality'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      studentId: json['student_id'] as String,
      email: json['email'] as String,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      enrollmentDate: json['enrollment_date'] != null
          ? DateTime.parse(json['enrollment_date'])
          : null,
      specialityName: json['speciality_name'] as String?,
      departmentName: json['department_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'speciality': speciality,
      'first_name': firstName,
      'last_name': lastName,
      'student_id': studentId,
      'email': email,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      // enrollment_date is auto_now_add in Django, so not sent in POST/PUT
    };
  }
}
