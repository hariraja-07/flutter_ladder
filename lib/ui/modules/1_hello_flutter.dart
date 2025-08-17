import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:highlight/languages/dart.dart';
import 'package:hive/hive.dart';
import 'package:flutter_ladder/storage/workspace_data.dart';
import 'package:flutter_ladder/compilation/mock_interpreter.dart';

const int moduleId = 0;

String runDartCode(String code) {
  final interpreter = MockInterpreter();
  interpreter.getInput(code);
  interpreter.process();
  return interpreter.output();
}

class HelloFlutter extends StatefulWidget {
  const HelloFlutter({super.key});

  @override
  State<HelloFlutter> createState() => _HelloFlutterState();
}

class _HelloFlutterState extends State<HelloFlutter> {
  static final workspaces = [
    Workspace(
      key: GlobalKey<_WorkspaceState>(),
      code: "void main() {\n  print('Hello Flutter 1');\n}",
    ),
    Workspace(
      key: GlobalKey<_WorkspaceState>(),
      code: "void main() {\n  print('Hello Flutter 2');\n}",
    ),
    Workspace(
      key: GlobalKey<_WorkspaceState>(),
      code: "void main() {\n  print('Hello Flutter 3');\n}",
    ),
  ];

  var workspaceIndex = 0;
  bool _runButtonHovering = false;

  @override
  void initState() {
    super.initState();
    // Load initial workspace data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWorkspace();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello Flutter", style: TextStyle(color: Colors.blue)),
      ),
      body: Stack(
        children: [
          IndexedStack(index: workspaceIndex, children: workspaces),

          Align(
            alignment: Alignment.bottomRight,
            child: SafeArea(
              minimum: const EdgeInsets.only(right: 10, bottom: 90),
              child: GestureDetector(
                onTap: () {
                  print("button pressed");
                  runCode();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _runButtonHovering = true),
                  onExit: (_) => setState(() => _runButtonHovering = false),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: _runButtonHovering
                          ? Colors.green[600]
                          : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(size: 30, Icons.play_arrow),
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: workspaceIndex > 0
                          ? () => _navigateToWorkspace(workspaceIndex - 1)
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 30.0,
                    ),
                    Text(
                      "${workspaceIndex + 1} / ${workspaces.length}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: workspaceIndex < workspaces.length - 1
                          ? () => _navigateToWorkspace(workspaceIndex + 1)
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      iconSize: 30.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWorkspace(int newIndex) {
    // Save current workspace before switching
    pushWorkspace();

    setState(() {
      workspaceIndex = newIndex;
    });

    // Load the new workspace data after the state has been updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWorkspace();
    });
  }

  void pushWorkspace() {
    final box = Hive.box<WorkspaceData>('workspaces');
    final key = workspaces[workspaceIndex].key as GlobalKey<_WorkspaceState>;

    // Check if the workspace state is available
    if (key.currentState != null) {
      final code = key.currentState!.getCode();
      final keyTerm = '$moduleId-$workspaceIndex';

      box.put(
        keyTerm,
        WorkspaceData(
          moduleIndex: moduleId,
          workspaceIndex: workspaceIndex,
          code: code,
        ),
      );

      print("Saved workspace $workspaceIndex with code length: ${code.length}");
    }
  }

  void getWorkspace() {
    final box = Hive.box<WorkspaceData>('workspaces');
    final keyTerm = '$moduleId-$workspaceIndex';
    final key = workspaces[workspaceIndex].key as GlobalKey<_WorkspaceState>;

    if (key.currentState != null) {
      final workspaceData = box.get(keyTerm);
      if (workspaceData != null) {
        key.currentState!.updateCode(workspaceData.code);
        print("Loaded workspace $workspaceIndex with saved code");
      } else {
        // If no saved data, use the default code
        key.currentState!.updateCode(workspaces[workspaceIndex].code);
        print("Loaded workspace $workspaceIndex with default code");
      }
    }
  }

  void runCode() async {
    final key = workspaces[workspaceIndex].key as GlobalKey<_WorkspaceState>;
    if (key.currentState != null) {
      final code = key.currentState!.getCode();
      final output = runDartCode(code);
      key.currentState!.setOutput(output);
    }
  }
}

class Workspace extends StatefulWidget {
  final String code;
  const Workspace({super.key, required this.code});

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> with TickerProviderStateMixin {
  late final TabController _leftTabs;
  late final TabController _rightTabs;
  double _dividerPosition = 0.5;

  late CodeController controller;

  String getCode() {
    return controller.text;
  }

  String output = "";

  void setOutput(String output) {
    setState(() {
      this.output = output;
    });
  }

  // Add this method to properly update the code
  void updateCode(String newCode) {
    setState(() {
      controller.text = newCode;
      // Force the controller to notify listeners
      controller.selection = TextSelection.collapsed(offset: newCode.length);
    });
  }

  @override
  void initState() {
    super.initState();
    _leftTabs = TabController(length: 2, vsync: this);
    _rightTabs = TabController(length: 2, vsync: this);
    controller = CodeController(text: widget.code, language: dart);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * _dividerPosition,
          child: Column(
            children: [
              _buildTabBar(_leftTabs, ["Instructions", "Editor"]),
              Expanded(
                child: TabBarView(
                  controller: _leftTabs,
                  children: [
                    _buildInstructions(),
                    EditorScreen(
                      key: ValueKey(
                        "${widget.code}-${controller.text}",
                      ), // Better key for rebuilding
                      codeController: controller,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dividerPosition += details.delta.dx / context.size!.width;
                _dividerPosition = _dividerPosition.clamp(0.3, 0.7);
              });
            },
            child: Container(width: 6, color: Colors.grey[900]),
          ),
        ),

        Expanded(
          child: Column(
            children: [
              _buildTabBar(_rightTabs, ["Preview", "Output"]),
              Expanded(
                child: TabBarView(
                  controller: _rightTabs,
                  children: [_buildPreview(), _buildOutput()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(TabController controller, List<String> titles) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: Border(bottom: BorderSide(color: Colors.grey[900]!)),
      ),
      child: TabBar(
        controller: controller,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: Colors.white),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: "Roboto",
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        tabs: titles
            .map(
              (title) => Tab(
                child: Container(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: Text(title),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInstructions() => Container(
    color: Colors.grey[750],
    padding: const EdgeInsets.all(16),
    child: Text(
      "Instructions for workspace ${widget.code}",
      style: TextStyle(color: Colors.white),
    ),
  );

  Widget _buildPreview() => Container(
    color: Colors.grey[850],
    padding: const EdgeInsets.all(16),
    child: Text("Preview area", style: TextStyle(color: Colors.white)),
  );

  Widget _buildOutput() => Container(
    color: Colors.grey[900],
    padding: const EdgeInsets.all(16),
    child: Text(output, style: TextStyle(color: Colors.white)),
  );

  @override
  void dispose() {
    _leftTabs.dispose();
    _rightTabs.dispose();
    controller.dispose();
    super.dispose();
  }
}

class EditorScreen extends StatefulWidget {
  final CodeController codeController;
  const EditorScreen({super.key, required this.codeController});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    return CodeTheme(
      data: CodeThemeData(styles: atomOneDarkTheme),
      child: CodeField(
        controller: widget.codeController,
        readOnly: false,
        expands: true,
      ),
    );
  }
}
