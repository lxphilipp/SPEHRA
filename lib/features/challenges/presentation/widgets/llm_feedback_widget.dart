import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// A widget for displaying LLM-generated feedback.
/// It handles loading, success, and error states.
class LlmFeedbackWidget extends StatelessWidget {
  final bool isLoading;
  final String? feedback;
  final String? improvementSuggestion;
  final String? error;
  final VoidCallback? onRetry;

  const LlmFeedbackWidget({
    super.key,
    required this.isLoading,
    this.feedback,
    this.improvementSuggestion,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isLoading && feedback == null && error == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildContent(context, theme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    if (isLoading) {
      return _buildInfoContainer(
        theme,
        icon: Iconsax.magicpen,
        iconColor: theme.colorScheme.secondary,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text("Analyzing your input...", style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildInfoContainer(
        theme,
        icon: Iconsax.warning_2,
        iconColor: theme.colorScheme.error,
        child: Row(
          children: [
            Expanded(child: Text("Failed to load feedback.", style: theme.textTheme.bodyMedium)),
            if (onRetry != null)
              IconButton(onPressed: onRetry, icon: const Icon(Iconsax.refresh)),
          ],
        ),
      );
    }

    if (feedback != null) {
      return _buildInfoContainer(
        theme,
        icon: Iconsax.magicpen,
        iconColor: theme.colorScheme.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feedback!, style: theme.textTheme.bodyMedium),
            if (improvementSuggestion != null && improvementSuggestion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Tip: $improvementSuggestion",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoContainer(ThemeData theme, {required IconData icon, required Color iconColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}