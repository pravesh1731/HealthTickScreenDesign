import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/theme/app_colors.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      _installErrorHandlers();

      runApp(const ProviderScope(child: HealthTickApp()));
    },
    (error, stackTrace) =>
        developer.log('Uncaught async error', name: 'app', error: error, stackTrace: stackTrace),
  );
}

void _installErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      'Flutter error',
      name: 'app',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  ErrorWidget.builder = (details) {
    const isRelease = bool.fromEnvironment('dart.vm.product');
    if (!isRelease) return ErrorWidget(details.exception);
    return const Material(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Something went wrong displaying this part.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      ),
    );
  };
}
