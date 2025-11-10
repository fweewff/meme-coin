import 'package:flutter/material.dart';

import 'app.dart';
import 'dependency_injection/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  runApp(const AiTunerApp());
}
