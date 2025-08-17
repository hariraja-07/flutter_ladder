import 'package:hive/hive.dart';
import 'package:flutter_ladder/storage/workspace_data.dart';

class WorkspaceDataAdapter extends TypeAdapter<WorkspaceData> {
  @override
  final int typeId = 0;

  @override
  WorkspaceData read(BinaryReader reader) {
    return WorkspaceData(
      moduleIndex: reader.read(),
      workspaceIndex: reader.read(),
      code: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkspaceData obj) {
    writer.write(obj.moduleIndex);
    writer.write(obj.workspaceIndex);
    writer.write(obj.code);
  }
}
