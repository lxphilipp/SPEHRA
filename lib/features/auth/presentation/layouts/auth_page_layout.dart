// lib/features/auth/presentation/layouts/auth_page_layout.dart
import 'package:flutter/material.dart';

class AuthPageLayout extends StatelessWidget {
  final Widget body;
  final String? appBarTitleText; // Optional: Text für den AppBar-Titel
  final bool showBackButton;    // Steuert, ob der Back-Button angezeigt wird (Standard: false)
  final Widget? appBarLeading; // Optional: Ein benutzerdefiniertes Leading-Widget für die AppBar

  const AuthPageLayout({
    super.key,
    required this.body,
    this.appBarTitleText,
    this.showBackButton = false,
    this.appBarLeading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040324), // Deine Standard-Hintergrundfarbe
      appBar: _buildAppBar(context),
      body: SafeArea( // SafeArea ist oft gut für den Body-Inhalt
        child: Center( // Zentriert den Body oft gut, je nach Design
          child: SingleChildScrollView( // Ermöglicht Scrollen, wenn Inhalt zu groß
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0), // Etwas Padding
            child: body,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    Widget? titleWidget;
    Widget? leadingWidget = appBarLeading; // Benutze das übergebene Leading-Widget

    if (appBarTitleText != null && appBarTitleText!.isNotEmpty) {
      // Wenn ein Titeltext gegeben ist, verwende ihn
      titleWidget = Text(
        appBarTitleText!,
        style: const TextStyle(color: Colors.white, fontFamily: 'OswaldLight', fontSize: 20), // Beispiel-Styling
      );
    } else {
      // Standard: Logo als Titel, wenn kein appBarTitleText gegeben ist
      // (Kann auch als Fallback dienen, wenn appBarTitleText leer ist)
      double logoHeight = AppBar().preferredSize.height - 20.0; // Etwas kleinerer Rand
      titleWidget = SizedBox(
        height: logoHeight,
        // width: MediaQuery.of(context).size.width, // Nimmt nicht mehr die volle Breite, wenn zentriert
        child: Image.asset(
          'assets/logo/sphera_logo.png', // Stelle sicher, dass der Pfad stimmt!
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      );
    }

    if (leadingWidget == null && showBackButton && Navigator.canPop(context)) {
      // Wenn kein benutzerdefiniertes Leading da ist, aber showBackButton true ist UND man zurück navigieren kann
      leadingWidget = BackButton(
        color: Colors.white,
        onPressed: () => Navigator.maybePop(context),
      );
    }

    return AppBar(
      leading: leadingWidget, // Verwende das bestimmte Leading-Widget
      automaticallyImplyLeading: leadingWidget != null || showBackButton, // True wenn Leading da ist oder BackButton explizit an sein soll
      title: titleWidget,
      backgroundColor: const Color(0xff040324), // Deine AppBar-Hintergrundfarbe
      elevation: 0, // Keine Schatten
      centerTitle: true, // Zentriere den Titel (Logo oder Text)
    );
  }
}