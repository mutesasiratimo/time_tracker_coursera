import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class TimeEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String taskId;

  @HiveField(3)
  final double hours;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? notes;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.hours,
    required this.date,
    this.notes,
  });
}
