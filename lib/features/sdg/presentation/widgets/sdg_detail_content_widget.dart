import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importiere dein LinkTextWidget (stelle sicher, dass der Pfad korrekt ist)
import '/core/widgets/link_text.dart';
import '../providers/sdg_detail_provider.dart';
import '../../domain/entities/sdg_detail_entity.dart';
// Für Theme-Zugriff
import '/core/theme/app_colors.dart'; // Für Fallback-Farben

class SdgDetailContentWidget extends StatefulWidget {
  final String sdgId;
  const SdgDetailContentWidget({super.key, required this.sdgId});

  @override
  State<SdgDetailContentWidget> createState() => _SdgDetailContentWidgetState();
}

class _SdgDetailContentWidgetState extends State<SdgDetailContentWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SdgDetailProvider>(context, listen: false);
      if (provider.currentSdgDetail?.id != widget.sdgId || provider.currentSdgDetail == null) {
        provider.fetchSdgDetails(widget.sdgId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SdgDetailContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sdgId != oldWidget.sdgId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SdgDetailProvider>(context, listen: false).fetchSdgDetails(widget.sdgId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verwende Consumer, um auf Änderungen im Provider zu reagieren und die UI neu zu bauen
    return Consumer<SdgDetailProvider>(
      builder: (context, provider, child) {
        final SdgDetailEntity? sdg = provider.currentSdgDetail;
        final theme = Theme.of(context);

        if (provider.isLoading && sdg?.id != widget.sdgId) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && sdg?.id != widget.sdgId) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${provider.error}',
                  style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
            ),
          );
        }

        if (sdg == null || sdg.id != widget.sdgId) {
          // Dieser Fall tritt ein, wenn noch keine Daten geladen wurden oder die ID nicht übereinstimmt
          // und kein Fehler/Ladezustand aktiv ist.
          return const Center(child: Text('Select an SDG to see details.', style: TextStyle(color: AppColors.primaryText)));
        }

        // Ab hier wissen wir, dass 'sdg' nicht null ist und zur widget.sdgId passt.
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sdg.title,
                style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              if (sdg.imageAssetPath.isNotEmpty)
                Center(
                  child: Image.asset(
                    sdg.imageAssetPath,
                    height: 200, // Höhe anpassen nach Bedarf
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 100, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                "Key Points:", // Oder "Description:"
                style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              ...sdg.descriptionPoints.map((point) => Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ", style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(point, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface))),
                    ]),
              )),
              const SizedBox(height: 24),
              if (sdg.mainTextContent != null && sdg.mainTextContent!.isNotEmpty) ...[
                Text(
                  "Further Information:",
                  style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  sdg.mainTextContent!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 24),
              ],
              if (sdg.externalLinks.isNotEmpty) ...[
                Text(
                  "Learn More:",
                  style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                ...sdg.externalLinks.map((link) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  // Annahme: LinkTextWidget ist in core/widgets und gestyled
                  child: LinkTextWidget(url: link),
                )),
              ]
            ],
          ),
        );
      },
    );
  }
}