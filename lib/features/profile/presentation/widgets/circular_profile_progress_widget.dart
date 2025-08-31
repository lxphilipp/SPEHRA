import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A utility class that dynamically generates color gradients for each level.
class LevelColor {
  /// Returns a list of two colors for a gradient based on the given [level].
  ///
  /// The hue of the colors is determined by the level, ensuring a unique
  /// gradient for different levels. Saturation and lightness are kept constant.
  static List<Color> getGradientForLevel(int level) {
    final double hue = (level * 41) % 360.0;
    const double saturation = 0.85;
    const double lightness = 0.6;
    final Color startColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
    final Color endColor = HSLColor.fromAHSL(1.0, (hue + 35) % 360.0, saturation, lightness).toColor();
    return [startColor, endColor];
  }
}

/// A custom widget that draws a circular progress indicator with a gradient.
class CircularGradientProgressIndicator extends StatelessWidget {
  /// The current progress value, between 0.0 and 1.0.
  final double progress;
  /// The width of the progress indicator's stroke.
  final double strokeWidth;
  /// The list of colors to use for the gradient.
  final List<Color> gradientColors;
  /// The background color of the progress indicator track.
  final Color backgroundColor;

  /// Creates a [CircularGradientProgressIndicator].
  ///
  /// Requires [progress], [gradientColors], and [backgroundColor].
  /// [strokeWidth] defaults to 4.0.
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

/// A [CustomPainter] that draws the circular gradient progress.
class _GradientCircularPainter extends CustomPainter {
  /// The current progress value, between 0.0 and 1.0.
  final double progress;
  /// The width of the progress indicator's stroke.
  final double strokeWidth;
  /// The list of colors to use for the gradient.
  final List<Color> gradientColors;
  /// The background color of the progress indicator track.
  final Color backgroundColor;

  /// Creates a [_GradientCircularPainter].
  ///
  /// Requires [progress], [strokeWidth], [gradientColors], and [backgroundColor].
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

    // Draw the background track
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the foreground progress arc with a gradient
    final foregroundPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -pi / 2,
        endAngle: (pi * 2), // Ensure the gradient covers the full circle for smooth animation
        transform: const GradientRotation(-pi / 2), // Start gradient from the top
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start angle (top of the circle)
      2 * pi * progress, // Sweep angle based on progress
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint whenever properties change to reflect updates.
    return true;
  }
}

/// A widget that displays a circular progress indicator around a profile image or initial,
/// along with a level badge.
class CircularProfileProgressWidget extends StatelessWidget {
  /// The URL of the profile image to display. If null or empty, initials are shown.
  final String? imageUrl;
  /// The current level of the user.
  final int level;
  /// The progress towards the next level, between 0.0 and 1.0.
  final double progress;
  /// The size (width and height) of the widget. Defaults to 40.0.
  final double size;
  /// The name of the user, used to display initials if [imageUrl] is not provided.
  final String? userName;

  /// Creates a [CircularProfileProgressWidget].
  ///
  /// Requires [level] and [progress].
  /// [imageUrl], [size], and [userName] are optional.
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
          // 1. The outer progress ring with the dynamic gradient
          CircularGradientProgressIndicator(
            progress: progress,
            strokeWidth: 3.5,
            gradientColors: gradientColors,
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),

          // 2. The profile picture in the center, now with CachedNetworkImage
          Padding(
            padding: const EdgeInsets.all(3.0), // Padding to avoid overlap with the progress ring
            child: CircleAvatar(
              backgroundColor: theme.scaffoldBackgroundColor, // Background color for the avatar circle itself
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl ?? '',
                  fit: BoxFit.cover,
                  width: size, // Ensure image fills the avatar
                  height: size, // Ensure image fills the avatar
                  placeholder: (context, url) => CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest, // Placeholder background
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer, // Background for initials
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: size * 0.4, // Scale font size with widget size
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. The level badge at the bottom right
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors), // Use the same gradient as the progress ring
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.scaffoldBackgroundColor, // Border to make it pop from the background
                  width: 1.5,
                ),
              ),
              child: Text(
                level.toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.3, // Scale font size with widget size
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5), // Text shadow for better readability
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
