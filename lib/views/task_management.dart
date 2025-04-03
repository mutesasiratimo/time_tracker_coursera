// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_task_provider.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Manage Tasks'),
        backgroundColor: Color(0xff6a59b6),
        foregroundColor: Colors.white,

        actions: [
          // Consumer<ProjectTaskProvider>(
          //   builder: (context, provider, _) {
          //     return Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //       child: DropdownButton<String>(
          //         value: _selectedProjectId,
          //         hint: const Text('Filter'),
          //         underline: const SizedBox(),
          //         items: [
          //           const DropdownMenuItem(
          //             value: null,
          //             child: Text('All Projects'),
          //           ),
          //           ...provider.projects.map((project) {
          //             return DropdownMenuItem(
          //               value: project.id,
          //               child: Text(project.name),
          //             );
          //           }).toList(),
          //         ],
          //         onChanged: (value) {
          //           setState(() {
          //             _selectedProjectId = value;
          //           });
          //         },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: Consumer<ProjectTaskProvider>(
        builder: (context, provider, _) {
          final filteredTasks =
              _selectedProjectId == null
                  ? provider.tasks
                  : provider.tasks
                      .where((t) => t.projectId == _selectedProjectId)
                      .toList();

          if (filteredTasks.isEmpty) {
            return Center(
              child: Text(
                _selectedProjectId == null
                    ? 'No tasks available'
                    : 'No tasks for selected project',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return FutureBuilder(
                future: provider.getProjectName(task.projectId),
                builder: (context, snapshot) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(task.name),
                      // subtitle: Text(snapshot.data ?? 'No project'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(context, task.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskNameController = TextEditingController();
    String? selectedProjectId;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ProjectTaskProvider>(
          builder: (context, provider, _) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Add Task'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // DropdownButtonFormField<String>(
                      //   value: selectedProjectId,
                      //   decoration: const InputDecoration(
                      //     labelText: 'Project',
                      //     border: OutlineInputBorder(),
                      //   ),
                      //   items:
                      //       provider.projects.map((project) {
                      //         return DropdownMenuItem(
                      //           value: project.id,
                      //           child: Text(project.name),
                      //         );
                      //       }).toList(),
                      //   onChanged: (value) {
                      //     setState(() {
                      //       selectedProjectId = value;
                      //     });
                      //   },
                      //   validator:
                      //       (value) =>
                      //           value == null
                      //               ? 'Please select a project'
                      //               : null,
                      // ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: taskNameController,
                        decoration: const InputDecoration(
                          labelText: 'Task Name',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (taskNameController.text.isNotEmpty &&
                            selectedProjectId != null) {
                          provider.addTask(
                            selectedProjectId!,
                            taskNameController.text,
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select a project and enter task name',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).then((_) {
      taskNameController.dispose();
    });
  }

  Future<void> _deleteTask(BuildContext context, String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task?'),
            content: const Text(
              'This will also delete any time entries associated with this task.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<ProjectTaskProvider>(
          context,
          listen: false,
        ).deleteTask(taskId);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
      }
    }
  }
}
