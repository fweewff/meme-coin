import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/connection/presentation/connection_screen.dart';
import '../features/flashing/presentation/flashing_screen.dart';
import '../features/home/presentation/home_screen.dart';

class AppRouter {
  AppRouter();

  final router = GoRouter(
    initialLocation: HomeScreen.routePath,
    routes: [
      GoRoute(
        path: HomeScreen.routePath,
        name: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: ConnectionScreen.routePath,
        name: ConnectionScreen.routeName,
        builder: (context, state) => const ConnectionScreen(),
      ),
      GoRoute(
        path: FlashingScreen.routePath,
        name: FlashingScreen.routeName,
        builder: (context, state) => const FlashingScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Navigation error: ${state.error}',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
