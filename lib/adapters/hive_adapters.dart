import 'package:hive/hive.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class HiveAdapters {
  static void registerAdapters() {
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TimeEntryAdapter());
  }
}

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    return Project(
      id: reader.read(),
      name: reader.read(),
      createdAt: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.createdAt);
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    return Task(
      id: reader.read(),
      name: reader.read(),
      createdAt: reader.read(),
      projectId: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.createdAt);
    writer.write(obj.projectId);
  }
}

class TimeEntryAdapter extends TypeAdapter<TimeEntry> {
  @override
  final int typeId = 2;

  @override
  TimeEntry read(BinaryReader reader) {
    return TimeEntry(
      id: reader.read(),
      hours: reader.read(),
      taskId: reader.read(),
      projectId: reader.read(),
      date: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, TimeEntry obj) {
    writer.write(obj.id);
    writer.write(obj.hours);
    writer.write(obj.taskId);
    writer.write(obj.projectId);
    writer.write(obj.date);
  }
}
