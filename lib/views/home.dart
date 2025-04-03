import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/time_entry.dart';
import '../providers/project_task_provider.dart';
import '../providers/time_entry_provider.dart';
import 'add_time_entry.dart';
import 'project_management.dart';
import 'task_management.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, bool> _expandedProjects = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load data from Hive through providers
    Provider.of<ProjectTaskProvider>(context, listen: false).projects;
    await Provider.of<ProjectTaskProvider>(
      context,
      listen: false,
    ).getAllTasks();
    final entries =
        Provider.of<TimeEntryProvider>(context, listen: false).entries;
    ;
    _printTimeEntries(entries);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _printTimeEntries(List<TimeEntry> entries) {
    debugPrint('====== TIME ENTRIES ======');
    debugPrint('Total entries: ${entries.length}');

    for (var entry in entries) {
      debugPrint('\nEntry ID: ${entry.id}');
      debugPrint('Project ID: ${entry.projectId}');
      debugPrint('Task ID: ${entry.taskId}');
      debugPrint('Hours: ${entry.hours}');
      debugPrint('Date: ${entry.date.toLocal()}');
      debugPrint('Notes: ${entry.notes ?? "No notes"}');
    }
    debugPrint('=========================');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Time Tracking',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: 'All Entries'), Tab(text: 'Grouped by Projects')],
          ),
          backgroundColor: Colors.blue.shade900,
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Menu')),
              ListTile(
                title: const Text('Projects'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProjectManagement(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer2<TimeEntryProvider, ProjectTaskProvider>(
                  builder: (context, timeProvider, projectProvider, _) {
                    final entries = timeProvider.entries;
                    final projects = projectProvider.projects;
                    final projectEntries = _groupEntriesByProject(
                      entries,
                      projects,
                    );

                    return TabBarView(
                      children: [
                        // First Tab: All Entries
                        entries.isEmpty
                            ? const Center(
                              child: Text(
                                'No time entries yet!\nTap the + button to add your first entry.',
                                textAlign: TextAlign.center,
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  return FutureBuilder(
                                    future: projectProvider.getTaskName(
                                      entry.taskId,
                                    ),
                                    builder: (context, taskSnapshot) {
                                      return ListTile(
                                        title: Text(entry.notes ?? 'No notes'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Task: ${taskSnapshot.data ?? 'Unknown Task'}',
                                            ),
                                            Text(
                                              '${entry.hours} hours on ${entry.date.toLocal().toString().split(' ')[0]}',
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            timeProvider.deleteEntry(entry.id);
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                        // Second Tab: Grouped by Projects
                        projectEntries.isEmpty
                            ? const Center(
                              child: Text(
                                'No time entries yet!\nTap the + button to add your first entry.',
                                textAlign: TextAlign.center,
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Grouped by Projects',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.headlineSmall,
                                    ),
                                  ),
                                  ...projectEntries.entries.map((entry) {
                                    final projectId = entry.key;
                                    final project = projects.firstWhere(
                                      (p) => p.id == projectId,
                                      orElse:
                                          () => Project(
                                            id: '',
                                            name: 'Unknown Project',
                                            createdAt: DateTime.now(),
                                          ),
                                    );
                                    final projectHours = entry.value.fold(
                                      0.0,
                                      (sum, e) => sum + e.hours,
                                    );

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: ExpansionTile(
                                        key: Key(projectId),
                                        initiallyExpanded:
                                            _expandedProjects[projectId] ??
                                            false,
                                        onExpansionChanged: (expanded) {
                                          setState(() {
                                            _expandedProjects[projectId] =
                                                expanded;
                                          });
                                        },
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                project.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${projectHours.toStringAsFixed(1)}h',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        children:
                                            entry.value.map((timeEntry) {
                                              return FutureBuilder(
                                                future: projectProvider
                                                    .getTaskName(
                                                      timeEntry.taskId,
                                                    ),
                                                builder: (
                                                  context,
                                                  taskSnapshot,
                                                ) {
                                                  return ListTile(
                                                    title: Text(
                                                      timeEntry.notes ??
                                                          'No notes',
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Task: ${taskSnapshot.data ?? 'Unknown Task'}',
                                                        ),
                                                        Text(
                                                          '${timeEntry.hours} hours on ${timeEntry.date.toLocal().toString().split(' ')[0]}',
                                                        ),
                                                      ],
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                      ),
                                                      onPressed: () {
                                                        timeProvider
                                                            .deleteEntry(
                                                              timeEntry.id,
                                                            );
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            }).toList(),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                      ],
                    );
                  },
                ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTimeEntryScreen(),
              ),
            ).then((_) => _loadData());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Map<String, List<TimeEntry>> _groupEntriesByProject(
    List<TimeEntry> entries,
    List<Project> projects,
  ) {
    final Map<String, List<TimeEntry>> grouped = {};

    // Initialize with all projects (including those with no entries)
    for (final project in projects) {
      grouped[project.id] = [];
    }

    // Add entries to their projects
    for (final entry in entries) {
      if (!grouped.containsKey(entry.projectId)) {
        grouped[entry.projectId] = [];
      }
      grouped[entry.projectId]!.add(entry);
    }

    // Sort by project name
    final sorted = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) {
        final projectA = projects.firstWhere(
          (p) => p.id == a.key,
          orElse: () => Project(id: '', name: 'ZZZ', createdAt: DateTime.now()),
        );
        final projectB = projects.firstWhere(
          (p) => p.id == b.key,
          orElse: () => Project(id: '', name: 'ZZZ', createdAt: DateTime.now()),
        );
        return projectA.name.compareTo(projectB.name);
      }),
    );

    return sorted;
  }
}
