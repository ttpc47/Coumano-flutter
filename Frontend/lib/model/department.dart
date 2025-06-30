// lib/model/department.dart
class Department {
  final String uuid;
  final String name;
  final String code;
  final String? description;
  final DateTime? establishedDate;
  final List<String>? specialtiesNames;

  Department({
    required this.uuid,
    required this.name,
    required this.code,
    this.description,
    this.establishedDate,
    this.specialtiesNames,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      establishedDate: json['established_date'] != null
          ? DateTime.parse(json['established_date'])
          : null,
      specialtiesNames: (json['specialties_names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'code': code,
      'description': description,
      'established_date': establishedDate?.toIso8601String().split('T')[0],
    };
  }
}
