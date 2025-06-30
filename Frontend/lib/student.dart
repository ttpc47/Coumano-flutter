import 'package:flutter/material.dart';
import 'model/student.dart';
import 'model/specialty.dart';
import 'services/apiService.dart';
import 'package:intl/intl.dart';


final ApiService apiService = ApiService();

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = apiService.getStudents();
  }

  void _refreshStudents() {
    setState(() {
      _studentsFuture = apiService.getStudents();
    });
  }

  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete student: $name?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await apiService.deleteStudent(id);
                  _refreshStudents();
                  _showSnackBar('Student deleted successfully!', Colors.green);
                } catch (e) {
                  _showSnackBar('Failed to delete student: $e', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}. Make sure Django server is running and accessible.',
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No students found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final student = snapshot.data![index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.person, color: Colors.indigo),
                    title: Text(
                      '${student.firstName} ${student.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${student.studentId}'),
                        Text('Email: ${student.email}'),
                        if (student.specialityName != null)
                          Text('Specialty: ${student.specialityName}'),
                        if (student.departmentName != null)
                          Text('Department: ${student.departmentName}'),
                        if (student.dateOfBirth != null)
                          Text(
                            'DOB: ${DateFormat.yMMMd().format(student.dateOfBirth!)}',
                          ),
                        if (student.enrollmentDate != null)
                          Text(
                            'Enrolled: ${DateFormat.yMMMd().format(student.enrollmentDate!)}',
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StudentFormPage(student: student),
                              ),
                            );
                            _refreshStudents();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmation(
                              student.id,
                              '${student.firstName} ${student.lastName}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentFormPage()),
          );
          _refreshStudents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


class StudentFormPage extends StatefulWidget {
  final Student? student;

  const StudentFormPage({super.key, this.student});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _studentIdController;
  late TextEditingController _emailController;
  DateTime? _selectedDateOfBirth;
  Specialty? _selectedSpecialty;
  List<Specialty> _specialties = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.student?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.student?.lastName ?? '',
    );
    _studentIdController = TextEditingController(
      text: widget.student?.studentId ?? '',
    );
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _selectedDateOfBirth = widget.student?.dateOfBirth;

    _fetchSpecialties();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchSpecialties() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _specialties = await apiService.getSpecialties();
      if (widget.student != null) {
        _selectedSpecialty = _specialties.firstWhere(
          (spec) => spec.uuid == widget.student!.speciality,
          orElse: () => _specialties.first,
        );
      } else if (_specialties.isNotEmpty) {
        _selectedSpecialty = _specialties.first;
      }
    } catch (e) {
      _showSnackBar('Failed to load specialties: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSpecialty == null) {
        _showSnackBar('Please select a specialty.', Colors.red);
        return;
      }
      setState(() {
        _isLoading = true;
      });

      try {
        final newStudent = Student(
          id: widget.student?.id ?? '',
          speciality: _selectedSpecialty!.uuid,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          studentId: _studentIdController.text,
          email: _emailController.text,
          dateOfBirth: _selectedDateOfBirth,
        );

        if (widget.student == null) {
          await apiService.createStudent(newStudent);
          _showSnackBar('Student created successfully!', Colors.green);
        } else {
          await apiService.updateStudent(newStudent);
          _showSnackBar('Student updated successfully!', Colors.green);
        }
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Failed to save student: $e', Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonFormField<Specialty>(
                      value: _selectedSpecialty,
                      decoration: const InputDecoration(
                        labelText: 'Specialty',
                        border: OutlineInputBorder(),
                        filled: true,
                        // fillColor: Colors.grey[200],
                      ),
                      hint: const Text('Select a specialty'),
                      items: _specialties.map((Specialty specialty) {
                        return DropdownMenuItem<Specialty>(
                          value: specialty,
                          child: Text(specialty.name),
                        );
                      }).toList(),
                      onChanged: (Specialty? newValue) {
                        setState(() {
                          _selectedSpecialty = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a specialty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        hintText: 'e.g., John',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'e.g., Doe',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        hintText: 'e.g., S001',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter student ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'e.g., john.doe@example.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDateOfBirth(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: _selectedDateOfBirth == null
                                ? 'Date of Birth (Optional)'
                                : 'Date of Birth',
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDateOfBirth == null
                                ? ''
                                : DateFormat.yMMMd().format(
                                    _selectedDateOfBirth!,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          widget.student == null
                              ? 'Add Student'
                              : 'Update Student',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
