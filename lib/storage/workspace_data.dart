import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class WorkspaceData {
  @HiveField(0)
  final int moduleIndex;
  @HiveField(1)
  final int workspaceIndex;
  @HiveField(2)
  final String code;

  WorkspaceData({
    required this.moduleIndex,
    required this.workspaceIndex,
    required this.code,
  });
}
