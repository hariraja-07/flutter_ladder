import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Ladder'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,

        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: currentLocation == '/'
                  ? Color.fromRGBO(255, 255, 255, 0.2)
                  : Colors.transparent,
            ),
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () => context.go('/about'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: currentLocation == '/about'
                  ? Color.fromRGBO(255, 255, 255, 0.2)
                  : Colors.transparent,
            ),
            child: const Text('About'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: child,
    );
  }
}
