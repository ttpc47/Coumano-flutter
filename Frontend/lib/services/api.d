class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<Department>> getDepartments() async {
    final response = await http.get(Uri.parse('$baseUrl/departments/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Department.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load departments: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Department> createDepartment(Department department) async {
    final response = await http.post(
      Uri.parse('$baseUrl/departments/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(department.toJson()),
    );
    if (response.statusCode == 201) {
      return Department.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create department: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Department> updateDepartment(Department department) async {
    final response = await http.put(
      Uri.parse('$baseUrl/departments/${department.uuid}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(department.toJson()),
    );
    if (response.statusCode == 200) {
      return Department.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update department: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deleteDepartment(String uuid) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/departments/$uuid/'),
    );
    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete department: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<Speciality>> getSpecialties() async {
    final response = await http.get(Uri.parse('$baseUrl/specialities/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Speciality.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load specialties: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Speciality> createSpeciality(Speciality speciality) async {
    final response = await http.post(
      Uri.parse('$baseUrl/specialities/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(speciality.toJson()),
    );
    if (response.statusCode == 201) {
      return Speciality.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create speciality: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Speciality> updateSpeciality(Speciality speciality) async {
    final response = await http.put(
      Uri.parse('$baseUrl/specialities/${speciality.uuid}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(speciality.toJson()),
    );
    if (response.statusCode == 200) {
      return Speciality.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update speciality: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deleteSpeciality(String uuid) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/specialities/$uuid/'),
    );
    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete speciality: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<Student>> getStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/students/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load students: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Student> createStudent(Student student) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(student.toJson()),
    );
    if (response.statusCode == 201) {
      return Student.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to create student: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Student> updateStudent(Student student) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/${student.uuid}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(student.toJson()),
    );
    if (response.statusCode == 200) {
      return Student.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update student: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deleteStudent(String uuid) async {
    final response = await http.delete(Uri.parse('$baseUrl/students/$uuid/'));
    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete student: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
