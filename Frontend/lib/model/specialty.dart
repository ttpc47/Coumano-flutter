// lib/model/specialty.dart
// import './department.dart'; // Import Department if needed for full object

class Specialty {
  final String uuid;
  final String department; // UUID of the department
  final String name;
  final String code;
  final int durationYears;
  final bool isActive;
  final String? departmentName; // For display purposes
  final List<String>? studentsNames;

  Specialty({
    required this.uuid,
    required this.department,
    required this.name,
    required this.code,
    required this.durationYears,
    required this.isActive,
    this.departmentName,
    this.studentsNames,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      uuid: json['uuid'] as String,
      department: json['department'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      durationYears: json['duration_years'] as int,
      isActive: json['is_active'] as bool,
      departmentName: json['department_name'] as String?,
      studentsNames: (json['students_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'department': department,
      'name': name,
      'code': code,
      'duration_years': durationYears,
      'is_active': isActive,
    };
  }
}