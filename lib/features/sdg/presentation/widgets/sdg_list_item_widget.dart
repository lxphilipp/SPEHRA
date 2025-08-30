// lib/features/sdg/presentation/widgets/sdg_list_item_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/sdg_list_item_entity.dart';

class SdgListItemWidget extends StatelessWidget {
  final SdgListItemEntity sdgItem;
  final VoidCallback onTap;

  const SdgListItemWidget({
    super.key,
    required this.sdgItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use the CardTheme from the global theme for consistency.
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          // This ensures consistent vertical spacing within the card.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Constrained container for the icon.
            // This prevents the icon from being pushed around by the text below.
            SizedBox(
              height: 64, // Explicitly constrain the icon's vertical space.
              width: 64,  // Explicitly constrain the icon's horizontal space.
              child: Image.asset(
                sdgItem.listImageAssetPath,
                fit: BoxFit.contain, // 'contain' ensures the icon is never cropped.
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12), // Consistent spacing
            // 2. Text container with padding.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                sdgItem.title,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center, // Centered text looks cleaner here.
                maxLines: 2, // Allow up to two lines for longer titles.
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}