import 'package:go_router/go_router.dart';
import 'package:flutter_ladder/ui/screens/shell_screen.dart';
import 'package:flutter_ladder/ui/screens/home_screen.dart';
import 'package:flutter_ladder/ui/screens/about_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    ),
  ],
);
