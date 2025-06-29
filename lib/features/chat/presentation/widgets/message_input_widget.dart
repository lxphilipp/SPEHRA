import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';

class MessageInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSendPressed;
  final VoidCallback onPickImagePressed;
  final FocusNode? focusNode;

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
        // OPTIMIERT: Verwendet eine semantische Container-Farbe aus dem Theme.
        color: theme.colorScheme.surfaceContainer,
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              // OPTIMIERT: Die Farbe wird jetzt vom IconTheme geerbt. Kein Fallback nötig.
              icon: const Icon(Icons.photo_camera_outlined),
              onPressed: isSending ? null : onPickImagePressed,
              tooltip: "Select Image",
            ),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                // OPTIMIERT: Der Text-Stil wird vom globalen Theme geerbt.
                decoration: InputDecoration(
                  hintText: "Write Messages...",
                  // OPTIMIERT: Der hintStyle erbt ebenfalls vom globalen Theme.
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
                ),
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: isSending ? null : (_) => onSendPressed(),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onTapOutside: (_) {
                  final currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
              ),
            ),
            isSending
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
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