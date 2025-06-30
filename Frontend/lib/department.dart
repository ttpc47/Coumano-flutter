import 'package:flutter/material.dart';
import 'model/department.dart';
import 'services/apiService.dart';
import 'package:intl/intl.dart';

final ApiService apiService = ApiService();

class DepartmentListPage extends StatefulWidget {
  const DepartmentListPage({super.key});

  @override
  State<DepartmentListPage> createState() => _DepartmentListPageState();
}

class _DepartmentListPageState extends State<DepartmentListPage> {
  late Future<List<Department>> _departmentsFuture;

  @override
  void initState() {
    super.initState();
    _departmentsFuture = apiService.getDepartments();
  }

  void _refreshDepartments() {
    setState(() {
      _departmentsFuture = apiService.getDepartments();
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
          content: Text('Are you sure you want to delete department: $name?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await apiService.deleteDepartment(uuid);
                  _refreshDepartments();
                  _showSnackBar(
                    'Department deleted successfully!',
                    Colors.green,
                  );
                } catch (e) {
                  _showSnackBar('Failed to delete department: $e', Colors.red);
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
      appBar: AppBar(title: const Text('Departments')),
      body: FutureBuilder<List<Department>>(
        future: _departmentsFuture,
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
            return const Center(child: Text('No departments found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final department = snapshot.data![index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.business, color: Colors.indigo),
                    title: Text(
                      department.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Code: ${department.code}'),
                        if (department.description != null &&
                            department.description!.isNotEmpty)
                          Text('Description: ${department.description}'),
                        if (department.establishedDate != null)
                          Text(
                            'Established: ${DateFormat.yMMMd().format(department.establishedDate!)}',
                          ),
                        if (department.specialtiesNames != null &&
                            department.specialtiesNames!.isNotEmpty)
                          Text(
                            'Specialties: ${department.specialtiesNames!.join(', ')}',
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
                                    DepartmentFormPage(department: department),
                              ),
                            );
                            _refreshDepartments();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmation(
                              department.uuid,
                              department.name,
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
            MaterialPageRoute(builder: (context) => DepartmentFormPage()),
          );
          _refreshDepartments();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


class DepartmentFormPage extends StatefulWidget {
  final Department? department;

  const DepartmentFormPage({super.key, this.department});

  @override
  State<DepartmentFormPage> createState() => _DepartmentFormPageState();
}

class _DepartmentFormPageState extends State<DepartmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.department?.name ?? '',
    );
    _codeController = TextEditingController(
      text: widget.department?.code ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.department?.description ?? '',
    );
    _selectedDate = widget.department?.establishedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newDepartment = Department(
          uuid: widget.department?.uuid ?? '', // UUID will be ignored on create
          name: _nameController.text,
          code: _codeController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          establishedDate: _selectedDate,
        );

        if (widget.department == null) {
          await apiService.createDepartment(newDepartment);
          _showSnackBar('Department created successfully!', Colors.green);
        } else {
          await apiService.updateDepartment(newDepartment);
          _showSnackBar('Department updated successfully!', Colors.green);
        }
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Failed to save department: $e', Colors.red);
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
          widget.department == null ? 'Add Department' : 'Edit Department',
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Department Name',
                        hintText: 'e.g., Computer Science',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a department name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Department Code',
                        hintText: 'e.g., CS',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a department code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText:
                            'e.g., Study of algorithms and data structures',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: _selectedDate == null
                                ? 'Established Date (Optional)'
                                : 'Established Date',
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : DateFormat.yMMMd().format(_selectedDate!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          widget.department == null
                              ? 'Add Department'
                              : 'Update Department',
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