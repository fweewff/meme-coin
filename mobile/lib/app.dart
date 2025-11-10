import 'package:flutter/material.dart';

import 'routes/app_router.dart';

class AiTunerApp extends StatelessWidget {
  const AiTunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter().router;

    return MaterialApp.router(
      title: 'AI-Tuner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
