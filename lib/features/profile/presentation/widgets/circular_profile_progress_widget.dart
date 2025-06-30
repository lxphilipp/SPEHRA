// lib/features/profile/presentation/widgets/circular_profile_progress_widget.dart

import 'package:flutter/material.dart';

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
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Der äußere Fortschrittsring
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.5,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          // 2. Das Profilbild in der Mitte
          Padding(
            padding: const EdgeInsets.all(3.0), // Kleiner Abstand zum Ring
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
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
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                level.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.28,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}