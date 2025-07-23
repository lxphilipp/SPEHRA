import 'package:flutter/material.dart';

class AuthPageLayout extends StatelessWidget {
  final Widget body;
  final String? appBarTitleText;
  final bool showBackButton;
  final Widget? appBarLeading;

  const AuthPageLayout({
    super.key,
    required this.body,
    this.appBarTitleText,
    this.showBackButton = false,
    this.appBarLeading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: body,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    Widget? titleWidget;
    Widget? leadingWidget = appBarLeading;

    if (appBarTitleText != null && appBarTitleText!.isNotEmpty) {
      titleWidget = Text(appBarTitleText!);
    } else {
      double logoHeight = AppBar().preferredSize.height - 20.0;
      titleWidget = SizedBox(
        height: logoHeight,
        child: Image.asset(
          'assets/logo/sphera_logo.png',
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      );
    }

    if (leadingWidget == null && showBackButton && Navigator.canPop(context)) {
      leadingWidget = BackButton(
        onPressed: () => Navigator.maybePop(context),
      );
    }

    return AppBar(
      leading: leadingWidget,
      automaticallyImplyLeading: leadingWidget != null || showBackButton,
      title: titleWidget,
      centerTitle: true,
    );
  }
}