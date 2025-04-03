import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Project {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  Project({required this.id, required this.name, required this.createdAt});
}
