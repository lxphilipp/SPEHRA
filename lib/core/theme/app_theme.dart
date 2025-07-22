// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'sdg_color_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        elevation: 0,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        SdgColorTheme(
          goal1: goal1,
          goal2: goal2,
          goal3: goal3,
          goal4: goal4,
          goal5: goal5,
          goal6: goal6,
          goal7: goal7,
          goal8: goal8,
          goal9: goal9,
          goal10: goal10,
          goal11: goal11,
          goal12: goal12,
          goal13: goal13,
          goal14: goal14,
          goal15: goal15,
          goal16: goal16,
          goal17: goal17,
          defaultGoalColor: defaultGoalColor,
        ),
      ],
    );
  }

  // Optional: A light theme for the future
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      extensions: const <ThemeExtension<dynamic>>[
        SdgColorTheme(
          goal1: goal1,
          goal2: goal2,
          goal3: goal3,
          goal4: goal4,
          goal5: goal5,
          goal6: goal6,
          goal7: goal7,
          goal8: goal8,
          goal9: goal9,
          goal10: goal10,
          goal11: goal11,
          goal12: goal12,
          goal13: goal13,
          goal14: goal14,
          goal15: goal15,
          goal16: goal16,
          goal17: goal17,
          defaultGoalColor: defaultGoalColor,
        ),
      ],
    );
  }
}