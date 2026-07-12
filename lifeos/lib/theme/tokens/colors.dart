import 'package:flutter/material.dart';

/// Design tokens as code — see docs/07_Design_System.md.
/// No widget may hardcode a color; every color reference goes through
/// this file (CLAUDE.md §10 Design Rules).
class LifeOSColors {
  const LifeOSColors._();

  static const Color background = Color(0xFF0E0E11);
  static const Color card = Color(0xFF23252C);
  static const Color primary = Color(0xFF6E2233); // Burgundy
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB8BCC6);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
}
