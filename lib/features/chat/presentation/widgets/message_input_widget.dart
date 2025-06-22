import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';

class MessageInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSendPressed;
  final VoidCallback onPickImagePressed;
  final FocusNode? focusNode; // Optional, für besseres Fokusmanagement

  const MessageInputWidget({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSendPressed,
    required this.onPickImagePressed,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppLogger.debug("MessageInputWidget: Building. isSending: $isSending");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.bottomAppBarTheme.color ?? const Color(0xff0a0930),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Für mehrzeilige Eingabe
          children: [
            IconButton(
              icon: Icon(Icons.photo_camera_outlined, color: theme.iconTheme.color ?? Colors.grey[400]),
              onPressed: isSending ? null : onPickImagePressed,
              tooltip: "Select Image",
            ),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color ?? Colors.white),
                decoration: InputDecoration(
                  hintText: "Write Messages...",
                  hintStyle: TextStyle(color: (theme.textTheme.bodyLarge?.color ?? Colors.white).withOpacity(0.5)),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0), // Padding anpassen
                ),
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: isSending ? null : (_) => onSendPressed(), // Senden bei Enter
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onTapOutside: (_) { // Tastatur schließen bei Klick außerhalb
                  AppLogger.debug("MessageInputWidget: Tap outside detected.");
                  if(focusNode?.hasFocus ?? false) { // Nur wenn Fokus vorhanden
                    focusNode?.unfocus();
                  } else {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
            isSending
                ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
            )
                : IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.primary),
              onPressed: onSendPressed,
              tooltip: "Send",
            ),
          ],
        ),
      ),
    );
  }
}