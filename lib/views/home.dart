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
            indicatorColor: Colors.amber,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: 'All Entries'), Tab(text: 'Grouped by Projects')],
          ),
          backgroundColor: Color(0xff2e9589),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xff2e9589)),
                padding: EdgeInsets.symmetric(vertical: 0.0),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.folder),
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
                leading: Icon(Icons.list),
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
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.hourglass_empty_outlined,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    'No time entries yet!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Tap the + button to add your first entry.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  return FutureBuilder(
                                    // future: projectProvider.getTaskName(
                                    //   entry.taskId,
                                    // ),
                                    future: Future.wait([
                                      projectProvider.getProjectName(
                                        entry.projectId,
                                      ),
                                      projectProvider.getTaskName(entry.taskId),
                                    ]),
                                    builder: (context, snapshot) {
                                      final projectName =
                                          snapshot.data?[0] ??
                                          'Unknown Project';
                                      final taskName =
                                          snapshot.data?[1] ?? 'Unknown Task';
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListTile(
                                            title: Text(
                                              '$projectName - $taskName',
                                              style: TextStyle(
                                                color: Colors.teal,
                                                // fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total Time: ${entry.hours} hours',
                                                ),
                                                Text(
                                                  'Date: ${entry.date.toLocal().toString().split(' ')[0]}',
                                                ),
                                                Text(
                                                  'Note: ${entry.notes ?? 'No notes'}',
                                                ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                timeProvider.deleteEntry(
                                                  entry.id,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                        // Second Tab: Grouped by Projects
                        projectEntries.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.hourglass_empty_outlined,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    'No time entries yet!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Tap the + button to add your first entry.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView(
                                children: [
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
                                    // final projectHours = entry.value.fold(
                                    //   0.0,
                                    //   (sum, e) => sum + e.hours,
                                    // );

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
                                                  color: Colors.teal,
                                                ),
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
                                                  return Row(
                                                    children: [
                                                      Text(
                                                        '- ${taskSnapshot.data ?? 'Unknown Task'}: ${timeEntry.hours} hours (${timeEntry.date.toLocal().toString().split(' ')[0]})',
                                                      ),
                                                    ],
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
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
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
