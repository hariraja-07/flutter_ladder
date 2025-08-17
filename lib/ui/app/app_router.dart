import 'package:go_router/go_router.dart';
import 'package:flutter_ladder/ui/screens/shell_screen.dart';
import 'package:flutter_ladder/ui/screens/home_screen.dart';
import 'package:flutter_ladder/ui/screens/about_screen.dart';

import 'package:flutter_ladder/ui/modules/1_hello_flutter.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // ===================================
    // SHELL ROUTE (Home, About)
    // ===================================
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

    // ===================================
    // MODULE ROUTES
    // ===================================
    GoRoute(
      path: '/modules/hello_flutter',
      builder: (context, state) => const HelloFlutter(),
    ),
  ],
);
