import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../presentation/pages/today_page.dart';

/// App shell. Sits below the `ProviderScope` created in `main.dart`.
class HealthTickApp extends StatelessWidget {
  const HealthTickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tick',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // The design is phone-first; on tablets and the web keep it at a
      // phone-like width instead of stretching it across the screen.
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFE4E4E4),
        child: Center(
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: child),
        ),
      ),
      home: const TodayPage(),
    );
  }
}
