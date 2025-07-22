// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

// The SDG colors are kept as fixed constants.
// This is the ONLY place where these specific color values are defined.
const Color goal1 = Color(0xFFE5243B);
const Color goal2 = Color(0xFFDDA63A);
const Color goal3 = Color(0xFF4C9F38);
const Color goal4 = Color(0xFFC5192D);
const Color goal5 = Color(0xFFFF3A21);
const Color goal6 = Color(0xFF26BDE2);
const Color goal7 = Color(0xFFFFC30B);
const Color goal8 = Color(0xFFA21942);
const Color goal9 = Color(0xFFFD6925);
const Color goal10 = Color(0xFFDD1367);
const Color goal11 = Color(0xFFFD9D24);
const Color goal12 = Color(0xFFBF8B2E);
const Color goal13 = Color(0xFF3F7E44);
const Color goal14 = Color(0xFF0A97D9);
const Color goal15 = Color(0xFF56C02B);
const Color goal16 = Color(0xFF00689D);
const Color goal17 = Color(0xFF19486A);
const Color defaultGoalColor = Colors.grey;

/// Creates the ColorScheme for the dark theme.
/// All colors are derived from a single "seedColor",
/// to ensure a harmonious and Material 3-compliant palette.
final darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF040324), // Our "Sphera" green as a base
  brightness: Brightness.dark,
);

/// Creates the ColorScheme for the light theme (optional, for later).
final lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF040324),
  brightness: Brightness.light,
  // Optional: Adjust specific colors for the light theme.
);