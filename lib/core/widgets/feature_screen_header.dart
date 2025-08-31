import 'package:flutter/material.dart';

/// A header for the feature screens.
///
/// It displays a title and a list of actions.
class FeatureScreenHeader extends StatelessWidget {
  /// The title of the header.
  final String title;

  /// The actions of the header.
  final List<Widget> actions;

  /// Creates a [FeatureScreenHeader].
  const FeatureScreenHeader({
    super.key,
    required this.title,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions,
          ),
        ],
      ),
    );
  }
}