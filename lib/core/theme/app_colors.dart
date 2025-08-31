// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

// The SDG colors are kept as fixed constants.
// This is the ONLY place where these specific color values are defined.

/// Color for SDG Goal 1: No Poverty
const Color goal1 = Color(0xFFE5243B);

/// Color for SDG Goal 2: Zero Hunger
const Color goal2 = Color(0xFFDDA63A);

/// Color for SDG Goal 3: Good Health and Well-being
const Color goal3 = Color(0xFF4C9F38);

/// Color for SDG Goal 4: Quality Education
const Color goal4 = Color(0xFFC5192D);

/// Color for SDG Goal 5: Gender Equality
const Color goal5 = Color(0xFFFF3A21);

/// Color for SDG Goal 6: Clean Water and Sanitation
const Color goal6 = Color(0xFF26BDE2);

/// Color for SDG Goal 7: Affordable and Clean Energy
const Color goal7 = Color(0xFFFFC30B);

/// Color for SDG Goal 8: Decent Work and Economic Growth
const Color goal8 = Color(0xFFA21942);

/// Color for SDG Goal 9: Industry, Innovation and Infrastructure
const Color goal9 = Color(0xFFFD6925);

/// Color for SDG Goal 10: Reduced Inequality
const Color goal10 = Color(0xFFDD1367);

/// Color for SDG Goal 11: Sustainable Cities and Communities
const Color goal11 = Color(0xFFFD9D24);

/// Color for SDG Goal 12: Responsible Consumption and Production
const Color goal12 = Color(0xFFBF8B2E);

/// Color for SDG Goal 13: Climate Action
const Color goal13 = Color(0xFF3F7E44);

/// Color for SDG Goal 14: Life Below Water
const Color goal14 = Color(0xFF0A97D9);

/// Color for SDG Goal 15: Life on Land
const Color goal15 = Color(0xFF56C02B);

/// Color for SDG Goal 16: Peace and Justice Strong Institutions
const Color goal16 = Color(0xFF00689D);

/// Color for SDG Goal 17: Partnerships to achieve the Goal
const Color goal17 = Color(0xFF19486A);

/// Default color for SDGs
const Color defaultGoalColor = Colors.grey;

/// Creates the ColorScheme for the dark theme.
/// All colors are derived from a single "seedColor",
/// to ensure a harmonious and Material 3-compliant palette.
final darkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF040324),
  brightness: Brightness.dark,
);

/// Creates the ColorScheme for the light theme (optional, for later).
final lightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF040324),
  brightness: Brightness.light,
);