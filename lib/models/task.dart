import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final DateTime createdAt;

  Task({
    required this.id,
    required this.projectId,
    required this.name,
    required this.createdAt,
  });
}
