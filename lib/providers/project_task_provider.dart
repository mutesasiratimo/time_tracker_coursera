import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectTaskProvider with ChangeNotifier {
  Box<Project>? _projects;
  Box<Task>? _tasks;
  bool _isInitialized = false;

  Future<void> init() async {
    try {
      _projects = await Hive.openBox<Project>('projects');
      _tasks = await Hive.openBox<Task>('tasks');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing ProjectTaskProvider: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // Projects CRUD
  List<Project> get projects {
    if (!_isInitialized || _projects == null) return [];
    return _projects!.values.toList();
  }

  Future<void> addProject(String name) async {
    if (!_isInitialized || _projects == null || _tasks == null) {
      throw Exception('Provider not initialized');
    }

    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    await _projects!.put(project.id, project);
    notifyListeners();
  }

  Future<void> updateProject(Project project) async {
    if (!_isInitialized || _projects == null) {
      throw Exception('Provider not initialized');
    }
    await _projects!.put(project.id, project);
    notifyListeners();
  }

  Future<void> deleteProject(String projectId) async {
    if (!_isInitialized || _projects == null || _tasks == null) {
      throw Exception('Provider not initialized');
    }

    // First delete all tasks associated with this project
    final tasksToDelete =
        _tasks!.values
            .where((task) => task.projectId == projectId)
            .map((task) => task.id)
            .toList();

    for (var taskId in tasksToDelete) {
      await _tasks!.delete(taskId);
    }

    await _projects!.delete(projectId);
    notifyListeners();
  }

  // Tasks CRUD
  List<Task> get tasks {
    if (!_isInitialized || _tasks == null) return [];
    return _tasks!.values.toList();
  }

  List<Task> getTasksByProject(String projectId) {
    if (!_isInitialized || _tasks == null) return [];
    return _tasks!.values.where((task) => task.projectId != '').toList();
    // return _tasks!.values.where((task) => task.projectId == projectId).toList();
  }

  Future<void> addTask(String projectId, String name) async {
    if (!_isInitialized || _tasks == null) {
      throw Exception('Provider not initialized');
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      name: name,
      createdAt: DateTime.now(),
    );
    await _tasks!.put(task.id, task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    if (!_isInitialized || _tasks == null) {
      throw Exception('Provider not initialized');
    }
    await _tasks!.put(task.id, task);
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    if (!_isInitialized || _tasks == null) {
      throw Exception('Provider not initialized');
    }
    await _tasks!.delete(taskId);
    notifyListeners();
  }

  // Helper methods
  Future<String?> getProjectName(String projectId) async {
    if (!_isInitialized || _projects == null) return null;
    return _projects!.get(projectId)?.name;
  }

  Future<List<Task>> getAllTasks() async {
    if (!_isInitialized || _tasks == null) return [];
    return _tasks!.values.toList();
  }

  Future<String?> getTaskName(String taskId) async {
    if (!_isInitialized || _tasks == null) return null;
    final task = _tasks!.get(taskId);
    return task?.name;
  }
}
