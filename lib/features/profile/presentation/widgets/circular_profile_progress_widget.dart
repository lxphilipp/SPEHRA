import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Eine Hilfsklasse, die dynamisch Farbverläufe für jedes Level generiert.
class LevelColor {
  static List<Color> getGradientForLevel(int level) {
    final double hue = (level * 41) % 360.0;
    const double saturation = 0.85;
    const double lightness = 0.6;
    final Color startColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
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

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    final foregroundPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -pi / 2,
        endAngle: (pi * 2),
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
  final String? userName;

  const CircularProfileProgressWidget({
    super.key,
    this.imageUrl,
    required this.level,
    required this.progress,
    this.size = 40.0,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = LevelColor.getGradientForLevel(level);
    final String initial = userName != null && userName!.isNotEmpty ? userName![0].toUpperCase() : '';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Der äußere Fortschrittsring mit dem dynamischen Farbverlauf
          CircularGradientProgressIndicator(
            progress: progress,
            strokeWidth: 3.5,
            gradientColors: gradientColors,
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),

          // 2. Das Profilbild in der Mitte, jetzt mit CachedNetworkImage
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: CircleAvatar(
              backgroundColor: theme.scaffoldBackgroundColor,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl ?? '',
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  placeholder: (context, url) => CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Das Level-Badge unten rechts
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                level.toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 3,
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