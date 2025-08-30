import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/sdg/domain/entities/sdg_list_item_entity.dart';
import 'package:flutter_sdg/features/sdg/presentation/screens/sdg_detail_screen.dart';

class SdgPreviewCard extends StatelessWidget {
  final SdgListItemEntity sdgItem;

  const SdgPreviewCard({super.key, required this.sdgItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SdgDetailScreen(
              sdgId: sdgItem.id,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              sdgItem.listImageAssetPath.replaceAll('icons/17_SDG_Icons', 'icons/sdg_named').replaceAll('.png', '.jpg'),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(sdgItem.listImageAssetPath, fit: BoxFit.contain, alignment: Alignment.center),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                sdgItem.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.7))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}