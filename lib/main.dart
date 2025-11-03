import 'package:ai_trip_planner/features/trip/presentation/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:ai_trip_planner/core/theme/app_theme.dart';
import 'package:ai_trip_planner/injection_container.dart' as di;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

void main() {
  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  di.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Trip Planner',
      theme: AppTheme.lightTheme,
      home: const LandingScreen(),
    );
  }
}
