// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';       // Deine Basisfarben
import 'sdg_color_theme.dart'; // Deine SdgColorTheme Extension

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryBackground, // Deine Haupt-Akzentfarbe als Seed
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseColorScheme, // Das generierte ColorScheme verwenden


      scaffoldBackgroundColor: AppColors.primaryBackground, // Dein expliziter dunkler Hintergrund
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBackground, // Oder baseColorScheme.surface
        foregroundColor: baseColorScheme.onSurface,   // Für Titel und Icons
        elevation: 0,
        iconTheme: IconThemeData(color: baseColorScheme.primary), // Dein Akzentgrün für Icons
        titleTextStyle: TextStyle(
          color: baseColorScheme.onSurface, // Oder AppColors.primaryText
          fontFamily: 'OswaldRegular',      // Deine Schriftart
          fontSize: 20,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground, // Dein spezifischer Kartenhintergrund
        // Oder baseColorScheme.surfaceVariant
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColorScheme.primary,   // Button mit Primärfarbe (dein Grün)
          foregroundColor: baseColorScheme.onPrimary, // Text auf Button
          textStyle: const TextStyle(fontFamily: 'OswaldRegular', fontWeight: FontWeight.bold),
        ),
      ),
      // Du kannst hier ein einfaches TextTheme definieren oder es erstmal weglassen
      // und die Flutter-Standardtextstile nutzen, die sich an das ColorScheme anpassen.
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: baseColorScheme.onSurface, fontFamily: 'OswaldLight'),
        titleLarge: TextStyle(color: baseColorScheme.onSurface, fontFamily: 'OswaldRegular', fontWeight: FontWeight.bold),
        // Füge nur die Textstile hinzu, die du global überschreiben möchtest.
      ).apply(fontFamily: 'OswaldLight'), // Globale Fallback-Schriftart für alle nicht spezifizierten Stile

      extensions: const <ThemeExtension<dynamic>>[
        SdgColorTheme(
          goal1: AppColors.goal1,
          goal2: AppColors.goal2,
          goal3: AppColors.goal3,
          goal4: AppColors.goal4,
          goal5: AppColors.goal5,
          goal6: AppColors.goal6,
          goal7: AppColors.goal7,
          goal8: AppColors.goal8,
          goal9: AppColors.goal9,
          goal10: AppColors.goal10,
          goal11: AppColors.goal11,
          goal12: AppColors.goal12,
          goal13: AppColors.goal13,
          goal14: AppColors.goal14,
          goal15: AppColors.goal15,
          goal16: AppColors.goal16,
          goal17: AppColors.goal17,
          defaultGoalColor: AppColors.defaultGoalColor,
        ),
      ],
    );
  }

  // Optional: Light Theme, falls du es später brauchst
  static ThemeData get lightTheme {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accentGreen,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor:  AppColors.primaryBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: baseColorScheme.surface,
        foregroundColor: baseColorScheme.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: baseColorScheme.primary),
        titleTextStyle: TextStyle(
          color: baseColorScheme.onSurface,
          fontFamily: 'OswaldRegular',
          fontSize: 20,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: baseColorScheme.onSurface, fontFamily: 'OswaldLight'),
        titleLarge: TextStyle(color: baseColorScheme.onSurface, fontFamily: 'OswaldRegular', fontWeight: FontWeight.bold),
      ).apply(fontFamily: 'OswaldLight'),
      extensions: const <ThemeExtension<dynamic>>[
        SdgColorTheme( // SDG Farben bleiben gleich oder du definierst helle Varianten
          goal1: AppColors.goal1,
          goal2: AppColors.goal2,
          goal3: AppColors.goal3,
          goal4: AppColors.goal4,
          goal5: AppColors.goal5,
          goal6: AppColors.goal6,
          goal7: AppColors.goal7,
          goal8: AppColors.goal8,
          goal9: AppColors.goal9,
          goal10: AppColors.goal10,
          goal11: AppColors.goal11,
          goal12: AppColors.goal12,
          goal13: AppColors.goal13,
          goal14: AppColors.goal14,
          goal15: AppColors.goal15,
          goal16: AppColors.goal16,
          goal17: AppColors.goal17,
          defaultGoalColor: AppColors.defaultGoalColor,
        ),
      ],
    );
  }
}