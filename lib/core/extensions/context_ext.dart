import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  // ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isSmallScreen => screenWidth < 380;

  void showAppSnackbar(String message, {SnackbarType type = SnackbarType.info}) {
    final cs = theme.colorScheme;
    final color = switch (type) {
      SnackbarType.success => cs.secondary,
      SnackbarType.error => cs.error,
      SnackbarType.warning => cs.tertiary,
      SnackbarType.info => cs.primary,
    };
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: textTheme.bodyMedium?.copyWith(color: cs.onPrimary)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
