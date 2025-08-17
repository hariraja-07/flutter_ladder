import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_ladder/ui/app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_ladder/storage/workspace_adapter.dart';
import 'package:flutter_ladder/storage/workspace_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WorkspaceDataAdapter());
  await Hive.openBox<WorkspaceData>('workspaces');

  usePathUrlStrategy();
  runApp(const App());
}
