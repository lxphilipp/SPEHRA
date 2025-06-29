import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
// Importiere dein AppTheme, wenn du spezifische Link-Textstile definieren willst
// import 'package:dein_projekt_name/core/theme/app_theme.dart';

class LinkTextWidget extends StatelessWidget { // Umbenannt für Klarheit
  final String url;
  final String? displayText; // Optional, um einen anderen Text als die URL anzuzeigen
  const LinkTextWidget({
    super.key,
    required this.url,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(url);
    final ThemeData theme = Theme.of(context);

    if (uri == null) {
      return Text(
        'Invalid URL',
        style: TextStyle(color: theme.colorScheme.error), // Fehlerfarbe aus Theme
      );
    }
    final TextStyle linkStyle = theme.textTheme.bodyMedium?.copyWith( // Basisstil
      color: theme.colorScheme.primary, // Typische Link-Farbe (oft primär oder eine Akzentfarbe)
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary, // Unterstreichung in gleicher Farbe
      fontFamily: 'OswaldLight', // Behalte deine Schriftart bei, wenn gewünscht
    ) ??
        const TextStyle( // Fallback, falls bodyMedium null ist
          color: Colors.blue,
          decoration: TextDecoration.underline,
          fontFamily: 'OswaldLight',
        );

    return Link(
      uri: uri,
      target: LinkTarget.blank,
      builder: (BuildContext ctx, FollowLink? openLink) {
        return TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Entferne Standard-Padding vom TextButton
            minimumSize: Size.zero,   // Entferne Mindestgröße
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Mache Klickbereich kleiner
          ),
          onPressed: openLink,
          child: Text(
            displayText ?? url, // Zeige displayText oder die URL
            style: linkStyle,
          ),
        );
      },
    );
  }
}