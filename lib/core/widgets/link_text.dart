import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class LinkTextWidget extends StatelessWidget {
  final String url;
  final String? displayText;
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
        style: TextStyle(color: theme.colorScheme.error)
      );
    }
    final TextStyle linkStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
      fontFamily: 'OswaldLight',
    ) ??
        const TextStyle(
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
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: openLink,
          child: Text(
            displayText ?? url,
            style: linkStyle,
          ),
        );
      },
    );
  }
}