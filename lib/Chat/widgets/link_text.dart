import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class LinkText extends StatelessWidget {
  final String url;
  const LinkText(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    final Uri? uri = Uri.tryParse(url);

    if (uri == null) {
      return const Text(
        'Invalid URL',
        style: TextStyle(color: Colors.red),
      );
    }

    return Link(
      uri: uri,
      target: LinkTarget.blank,
      builder: (BuildContext ctx, FollowLink? openLink) {
        return TextButton(
          onPressed: openLink,
          child: Text(
            '• $url',
            style: const TextStyle(
              fontFamily: 'OswaldLight',
              color: Colors.lightBlueAccent,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}
