import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_task_provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _hoursController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedProjectId;
  String? _selectedTaskId;

  @override
  Widget build(BuildContext context) {
    final projects = Provider.of<ProjectTaskProvider>(context).projects;
    final tasks =
        _selectedProjectId != null
            ? Provider.of<ProjectTaskProvider>(
              context,
            ).getTasksByProject(_selectedProjectId!)
            : [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Time Entry',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff2e9589),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedProjectId,
                decoration: const InputDecoration(labelText: 'Project'),
                items:
                    projects.map((project) {
                      return DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                    _selectedTaskId = null;
                  });
                },
                validator: (value) => value == null ? 'Select a project' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Object>(
                value: _selectedTaskId,
                decoration: const InputDecoration(labelText: 'Task'),
                items:
                    tasks.map((task) {
                      return DropdownMenuItem(
                        value: task.id,
                        child: Text(task.name),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTaskId = value.toString();
                  });
                },
                validator: (value) => value == null ? 'Select a task' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'Total Time (in hours)',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Enter time' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // ElevatedButton(
                  //   onPressed: () => Navigator.pop(context),
                  //   child: const Text('Cancel'),
                  // ),
                  ElevatedButton(
                    onPressed: _saveEntry,
                    child: const Text(
                      'Save Entry',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate() &&
        _selectedProjectId != null &&
        _selectedTaskId != null) {
      final entry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: _selectedProjectId!,
        taskId: _selectedTaskId!,
        hours: double.parse(_hoursController.text),
        date: _selectedDate,
        notes: _notesController.text,
      );

      Provider.of<TimeEntryProvider>(
        context,
        listen: false,
      ).addEntry(entry).then((_) => Navigator.pop(context));
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _hoursController.dispose();
    super.dispose();
  }
}
