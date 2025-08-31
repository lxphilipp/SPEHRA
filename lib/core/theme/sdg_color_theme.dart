import 'package:flutter/material.dart';
// Deine Basisfarben

// @immutable ist eine gute Praxis für ThemeExtensions, da sie unveränderlich sein sollten.
/// A [ThemeExtension] for the SDG colors.
///
/// This allows the SDG colors to be accessed from the theme.
@immutable
class SdgColorTheme extends ThemeExtension<SdgColorTheme> {
  /// The color for SDG Goal 1.
  final Color goal1;

  /// The color for SDG Goal 2.
  final Color goal2;

  /// The color for SDG Goal 3.
  final Color goal3;

  /// The color for SDG Goal 4.
  final Color goal4;

  /// The color for SDG Goal 5.
  final Color goal5;

  /// The color for SDG Goal 6.
  final Color goal6;

  /// The color for SDG Goal 7.
  final Color goal7;

  /// The color for SDG Goal 8.
  final Color goal8;

  /// The color for SDG Goal 9.
  final Color goal9;

  /// The color for SDG Goal 10.
  final Color goal10;

  /// The color for SDG Goal 11.
  final Color goal11;

  /// The color for SDG Goal 12.
  final Color goal12;

  /// The color for SDG Goal 13.
  final Color goal13;

  /// The color for SDG Goal 14.
  final Color goal14;

  /// The color for SDG Goal 15.
  final Color goal15;

  /// The color for SDG Goal 16.
  final Color goal16;

  /// The color for SDG Goal 17.
  final Color goal17;

  /// The default color for SDGs.
  final Color defaultGoalColor;

  /// Creates an [SdgColorTheme].
  const SdgColorTheme({
    required this.goal1,
    required this.goal2,
    required this.goal3,
    required this.goal4,
    required this.goal5,
    required this.goal6,
    required this.goal7,
    required this.goal8,
    required this.goal9,
    required this.goal10,
    required this.goal11,
    required this.goal12,
    required this.goal13,
    required this.goal14,
    required this.goal15,
    required this.goal16,
    required this.goal17,
    required this.defaultGoalColor,
  });

  /// Returns the color for the given SDG key.
  Color colorForSdgKey(String sdgKey) {
    switch (sdgKey.toLowerCase()) {
      case 'goal1':
        return goal1;
      case 'goal2':
        return goal2;
      case 'goal3':
        return goal3;
      case 'goal4':
        return goal4;
      case 'goal5':
        return goal5;
      case 'goal6':
        return goal6;
      case 'goal7':
        return goal7;
      case 'goal8':
        return goal8;
      case 'goal9':
        return goal9;
      case 'goal10':
        return goal10;
      case 'goal11':
        return goal11;
      case 'goal12':
        return goal12;
      case 'goal13':
        return goal13;
      case 'goal14':
        return goal14;
      case 'goal15':
        return goal15;
      case 'goal16':
        return goal16;
      case 'goal17':
        return goal17;
      default:
        return defaultGoalColor;
    }
  }

  @override
  SdgColorTheme copyWith({
    Color? goal1,
    Color? goal2,
    Color? goal3,
    Color? goal4,
    Color? goal5,
    Color? goal6,
    Color? goal7,
    Color? goal8,
    Color? goal9,
    Color? goal10,
    Color? goal11,
    Color? goal12,
    Color? goal13,
    Color? goal14,
    Color? goal15,
    Color? goal16,
    Color? goal17,
    Color? defaultGoalColor,
  }) {
    return SdgColorTheme(
      goal1: goal1 ?? this.goal1,
      goal2: goal2 ?? this.goal2,
      goal3: goal3 ?? this.goal3,
      goal4: goal4 ?? this.goal4,
      goal5: goal5 ?? this.goal5,
      goal6: goal6 ?? this.goal6,
      goal7: goal7 ?? this.goal7,
      goal8: goal8 ?? this.goal8,
      goal9: goal9 ?? this.goal9,
      goal10: goal10 ?? this.goal10,
      goal11: goal11 ?? this.goal11,
      goal12: goal12 ?? this.goal12,
      goal13: goal13 ?? this.goal13,
      goal14: goal14 ?? this.goal14,
      goal15: goal15 ?? this.goal15,
      goal16: goal16 ?? this.goal16,
      goal17: goal17 ?? this.goal17,
      defaultGoalColor: defaultGoalColor ?? this.defaultGoalColor,
    );
  }

  @override
  SdgColorTheme lerp(ThemeExtension<SdgColorTheme>? other, double t) {
    if (other is! SdgColorTheme) {
      return this;
    }
    return SdgColorTheme(
      goal1: Color.lerp(goal1, other.goal1, t)!,
      goal2: Color.lerp(goal2, other.goal2, t)!,
      goal3: Color.lerp(goal3, other.goal3, t)!,
      goal4: Color.lerp(goal4, other.goal4, t)!,
      goal5: Color.lerp(goal5, other.goal5, t)!,
      goal6: Color.lerp(goal6, other.goal6, t)!,
      goal7: Color.lerp(goal7, other.goal7, t)!,
      goal8: Color.lerp(goal8, other.goal8, t)!,
      goal9: Color.lerp(goal9, other.goal9, t)!,
      goal10: Color.lerp(goal10, other.goal10, t)!,
      goal11: Color.lerp(goal11, other.goal11, t)!,
      goal12: Color.lerp(goal12, other.goal12, t)!,
      goal13: Color.lerp(goal13, other.goal13, t)!,
      goal14: Color.lerp(goal14, other.goal14, t)!,
      goal15: Color.lerp(goal15, other.goal15, t)!,
      goal16: Color.lerp(goal16, other.goal16, t)!,
      goal17: Color.lerp(goal17, other.goal17, t)!,
      defaultGoalColor: Color.lerp(defaultGoalColor, other.defaultGoalColor, t)!,
    );
  }

  // Optional: Implementiere == und hashCode, wenn du Instanzen vergleichen möchtest.
  // Für ThemeExtensions ist das oft eine gute Praxis.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SdgColorTheme &&
              runtimeType == other.runtimeType &&
              goal1 == other.goal1 && goal2 == other.goal2 && goal3 == other.goal3 &&
              goal4 == other.goal4 && goal5 == other.goal5 && goal6 == other.goal6 &&
              goal7 == other.goal7 && goal8 == other.goal8 && goal9 == other.goal9 &&
              goal10 == other.goal10 && goal11 == other.goal11 && goal12 == other.goal12 &&
              goal13 == other.goal13 && goal14 == other.goal14 && goal15 == other.goal15 &&
              goal16 == other.goal16 && goal17 == other.goal17 && defaultGoalColor == other.defaultGoalColor;

  @override
  int get hashCode => Object.hashAll([
    goal1, goal2, goal3, goal4, goal5, goal6, goal7, goal8, goal9, goal10,
    goal11, goal12, goal13, goal14, goal15, goal16, goal17, defaultGoalColor
  ]);
}