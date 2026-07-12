import 'package:flutter/material.dart';
import 'tokens/colors.dart';

/// Wires design tokens into Flutter's ThemeData. See docs/07_Design_System.md.
class LifeOSTheme {
  const LifeOSTheme._();

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LifeOSColors.background,
      colorScheme: const ColorScheme.dark(
        primary: LifeOSColors.primary,
        surface: LifeOSColors.card,
        error: LifeOSColors.danger,
      ),
      cardColor: LifeOSColors.card,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: LifeOSColors.textPrimary),
        bodyMedium: TextStyle(color: LifeOSColors.textSecondary),
      ),
    );
  }
}
