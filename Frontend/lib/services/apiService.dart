import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/department.dart';
import '../model/specialty.dart';
import '../model/student.dart';


const String API_BASE_URL = 'http://localhost:8000/api'; 

class ApiService {
  final String _baseUrl = API_BASE_URL; // Use the global constant

  // Constructor 
  ApiService();

  Future<List<Department>> getDepartments() async {
    final response = await http.get(Uri.parse('$_baseUrl/departments/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Department.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load departments: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Department> createDepartment(Department department) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/departments/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(department.toJson()),
    );
    if (response.statusCode == 201) {
      return Department.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create department: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Department> updateDepartment(Department department) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/departments/${department.uuid}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(department.toJson()),
    );
    if (response.statusCode == 200) {
      return Department.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update department: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteDepartment(String uuid) async {
    final response = await http.delete(Uri.parse('$_baseUrl/departments/$uuid/'));
    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete department: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Specialty>> getSpecialties() async {
    final response = await http.get(Uri.parse('$_baseUrl/specialities/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Specialty.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load specialties: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Specialty> createSpecialty(Specialty specialty) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/specialities/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(specialty.toJson()),
    );
    if (response.statusCode == 201) {
      return Specialty.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create specialty: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Specialty> updateSpecialty(Specialty specialty) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/specialities/${specialty.uuid}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(specialty.toJson()),
    );
    if (response.statusCode == 200) {
      return Specialty.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update specialty: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteSpecialty(String uuid) async {
    final response = await http.delete(Uri.parse('$_baseUrl/specialities/$uuid/'));
    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete specialty: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Student>> getStudents() async {
    final response = await http.get(Uri.parse('$_baseUrl/students/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load students: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Student> createStudent(Student student) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/students/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(student.toJson()),
    );
    if (response.statusCode == 201) {
      return Student.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create student: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Student> updateStudent(Student student) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/students/${student.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(student.toJson()),
    );
    if (response.statusCode == 200) {
      return Student.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update student: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteStudent(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/students/$id/'));
    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete student: ${response.statusCode} - ${response.body}');
    }
  }
}