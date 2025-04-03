import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_task_provider.dart';

class ProjectManagement extends StatefulWidget {
  const ProjectManagement({super.key});

  @override
  State<ProjectManagement> createState() => _ProjectManagementState();
}

class _ProjectManagementState extends State<ProjectManagement> {
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context);
    final projects = projectProvider.projects;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Manage Projects'),
        backgroundColor: Color(0xff6a59b6),
        foregroundColor: Colors.white,
      ),
      body:
          projects.isEmpty
              ? const Center(child: Text('No projects yet. Tap + to add one.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(project.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProject(context, project.id),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedProjectId = project.id;
                          });
                        },
                        selected: _selectedProjectId == project.id,
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        onPressed: () => _showAddProjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final projectNameController = TextEditingController();
    final projectProvider = Provider.of<ProjectTaskProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Project'),
          content: TextField(
            controller: projectNameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Project Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (projectNameController.text.isNotEmpty) {
                  projectProvider
                      .addProject(projectNameController.text)
                      .then((_) {
                        Navigator.pop(context);
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error adding project: $error'),
                          ),
                        );
                      });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((_) {
      projectNameController.dispose();
    });
  }

  Future<void> _deleteProject(BuildContext context, String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Project?'),
            content: const Text(
              'This will also delete all tasks under this project. Continue?',
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
        ).deleteProject(projectId);
        if (_selectedProjectId == projectId) {
          setState(() {
            _selectedProjectId = null;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting project: $e')));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
