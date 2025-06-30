
import 'package:flutter/material.dart';
import 'model/specialty.dart';
import 'model/department.dart';
import 'services/apiService.dart';
import 'package:intl/intl.dart';

final ApiService apiService = ApiService();

class SpecialtyListPage extends StatefulWidget {
  const SpecialtyListPage({super.key});

  @override
  State<SpecialtyListPage> createState() => _SpecialtyListPageState();
}

class _SpecialtyListPageState extends State<SpecialtyListPage> {
  late Future<List<Specialty>> _specialtiesFuture;

  @override
  void initState() {
    super.initState();
    _specialtiesFuture = apiService.getSpecialties();
  }

  void _refreshSpecialties() {
    setState(() {
      _specialtiesFuture = apiService.getSpecialties();
    });
  }

  void _showDeleteConfirmation(String uuid, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete specialty: $name?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await apiService.deleteSpecialty(uuid);
                  _refreshSpecialties();
                  _showSnackBar(
                    'Specialty deleted successfully!',
                    Colors.green,
                  );
                } catch (e) {
                  _showSnackBar('Failed to delete specialty: $e', Colors.red);
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
      appBar: AppBar(title: const Text('Specialties')),
      body: FutureBuilder<List<Specialty>>(
        future: _specialtiesFuture,
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
            return const Center(child: Text('No specialties found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final specialty = snapshot.data![index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.school, color: Colors.indigo),
                    title: Text(
                      specialty.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Code: ${specialty.code}'),
                        if (specialty.departmentName != null)
                          Text('Department: ${specialty.departmentName}'),
                        Text('Duration: ${specialty.durationYears} years'),
                        Text('Active: ${specialty.isActive ? 'Yes' : 'No'}'),
                        if (specialty.studentsNames != null &&
                            specialty.studentsNames!.isNotEmpty)
                          Text(
                            'Students: ${specialty.studentsNames!.join(', ')}',
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
                                    SpecialtyFormPage(specialty: specialty),
                              ),
                            );
                            _refreshSpecialties();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmation(
                              specialty.uuid,
                              specialty.name,
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
            MaterialPageRoute(builder: (context) => SpecialtyFormPage()),
          );
          _refreshSpecialties();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SpecialtyFormPage extends StatefulWidget {
  final Specialty? specialty;

  const SpecialtyFormPage({super.key, this.specialty});

  @override
  State<SpecialtyFormPage> createState() => _SpecialtyFormPageState();
}

class _SpecialtyFormPageState extends State<SpecialtyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _durationController;
  bool _isActive = true;
  Department? _selectedDepartment;
  List<Department> _departments = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.specialty?.name ?? '',
    );
    _codeController = TextEditingController(
      text: widget.specialty?.code ?? '',
    );
    _durationController = TextEditingController(
      text: widget.specialty?.durationYears.toString() ?? '3',
    );
    _isActive = widget.specialty?.isActive ?? true;

    _fetchDepartments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _departments = await apiService.getDepartments();
      if (widget.specialty != null) {
        _selectedDepartment = _departments.firstWhere(
          (dept) => dept.uuid == widget.specialty!.department,
          orElse: () => _departments.first,
        );
      } else if (_departments.isNotEmpty) {
        _selectedDepartment = _departments.first;
      }
    } catch (e) {
      _showSnackBar('Failed to load departments: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDepartment == null) {
        _showSnackBar('Please select a department.', Colors.red);
        return;
      }
      setState(() {
        _isLoading = true;
      });

      try {
        final newSpecialty = Specialty(
          uuid: widget.specialty?.uuid ?? '',
          department: _selectedDepartment!.uuid,
          name: _nameController.text,
          code: _codeController.text,
          durationYears: int.parse(_durationController.text),
          isActive: _isActive,
        );

        if (widget.specialty == null) {
          await apiService.createSpecialty(newSpecialty);
          _showSnackBar('Specialty created successfully!', Colors.green);
        } else {
          await apiService.updateSpecialty(newSpecialty);
          _showSnackBar('Specialty updated successfully!', Colors.green);
        }
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Failed to save specialty: $e', Colors.red);
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
        title: Text(
          widget.specialty == null ? 'Add Specialty' : 'Edit Specialty',
        ),
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
                    DropdownButtonFormField<Department>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                        filled: true,
                        // fillColor: Colors.grey[200],
                      ),
                      hint: const Text('Select a department'),
                      items: _departments.map((Department department) {
                        return DropdownMenuItem<Department>(
                          value: department,
                          child: Text(department.name),
                        );
                      }).toList(),
                      onChanged: (Department? newValue) {
                        setState(() {
                          _selectedDepartment = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Specialty Name',
                        hintText: 'e.g., Software Engineering',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a specialty name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Specialty Code',
                        hintText: 'e.g., SE',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a specialty code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (Years)',
                        hintText: 'e.g., 3',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Is Active'),
                      value: _isActive,
                      onChanged: (bool value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: Colors.indigoAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          widget.specialty == null
                              ? 'Add Specialty'
                              : 'Update Specialty',
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
