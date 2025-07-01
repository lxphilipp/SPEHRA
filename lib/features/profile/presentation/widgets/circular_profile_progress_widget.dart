// lib/features/profile/presentation/widgets/circular_profile_progress_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';

/// Eine Hilfsklasse, die dynamisch Farbverläufe für jedes Level generiert.
class LevelColor {
  /// Erzeugt einen einzigartigen Farbverlauf basierend auf der Level-Nummer.
  ///
  /// Diese Funktion nutzt das HSL-Farbmodell, um sicherzustellen, dass jedes Level
  /// einen visuell ansprechenden und einzigartigen Farbverlauf erhält, ohne dass
  /// wir Farben manuell definieren müssen.
  static List<Color> getGradientForLevel(int level) {
    // Der "Hue" (Farbton) wird basierend auf dem Level berechnet.
    // Die Multiplikation mit einer Primzahl (hier 41) sorgt für eine schöne
    // und nicht-repetitive Verteilung der Farben über den Farbkreis (360 Grad).
    final double hue = (level * 41) % 360.0;

    // Wir halten Sättigung und Helligkeit konstant, um einen konsistenten Stil zu gewährleisten.
    const double saturation = 0.85; // Kräftige Sättigung
    const double lightness = 0.6;   // Angenehme Helligkeit

    // Erzeugen der Start- und Endfarben für den Verlauf.
    final Color startColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
    // Die Endfarbe hat einen leicht verschobenen Farbton für einen sanften Übergang.
    final Color endColor = HSLColor.fromAHSL(1.0, (hue + 35) % 360.0, saturation, lightness).toColor();

    return [startColor, endColor];
  }
}

/// Ein benutzerdefiniertes Widget, das den Fortschrittsanzeiger mit einem Farbverlauf zeichnet.
class CircularGradientProgressIndicator extends StatelessWidget {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  const CircularGradientProgressIndicator({
    super.key,
    required this.progress,
    required this.gradientColors,
    required this.backgroundColor,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientCircularPainter(
        progress: progress,
        strokeWidth: strokeWidth,
        gradientColors: gradientColors,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _GradientCircularPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _GradientCircularPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Hintergrundkreis
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Vordergrundkreis mit Farbverlauf
    final foregroundPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -pi / 2,
        endAngle: (pi * 2), // Der Verlauf deckt immer den ganzen Kreis ab
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class CircularProfileProgressWidget extends StatelessWidget {
  final String? imageUrl;
  final int level;
  final double progress;
  final double size;

  const CircularProfileProgressWidget({
    super.key,
    required this.imageUrl,
    required this.level,
    required this.progress,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Hole den dynamisch generierten Farbverlauf für das aktuelle Level.
    final gradientColors = LevelColor.getGradientForLevel(level);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Der äußere Fortschrittsring mit dem neuen dynamischen Farbverlauf
          CircularGradientProgressIndicator(
            progress: progress,
            strokeWidth: 3.5,
            gradientColors: gradientColors,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          // 2. Das Profilbild in der Mitte
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: CircleAvatar(
              backgroundColor: theme.scaffoldBackgroundColor,
              backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? NetworkImage(imageUrl!)
                  : null,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? Icon(
                Icons.person,
                size: size * 0.5,
                color: theme.colorScheme.onSurfaceVariant,
              )
                  : null,
            ),
          ),
          // 3. Das Level-Badge unten rechts
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors), // Badge nutzt denselben Verlauf
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                level.toString(),
                style: TextStyle(
                  // Eine Farbe, die auf den meisten Verläufen gut lesbar ist.
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.28,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 1,
                      )
                    ]
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}