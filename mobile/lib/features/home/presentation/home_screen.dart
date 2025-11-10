import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../connection/presentation/connection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = 'home';
  static const String routePath = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Tuner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, tuner!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Connect to your vehicle to manage ECU files securely and leverage AI tuning capabilities.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.go(ConnectionScreen.routePath),
              icon: const Icon(Icons.settings_input_component),
              label: const Text('Connect Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
