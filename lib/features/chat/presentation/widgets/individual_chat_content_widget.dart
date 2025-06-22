import 'dart:io'; // Für File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Für Bildauswahl
import 'package:provider/provider.dart'; // Für Provider-Zugriff

// Provider
import '../providers/individual_chat_provider.dart';

// Kleinere UI-Komponenten-Widgets
import 'message_list_widget.dart';
import 'image_preview_widget.dart';
import 'message_input_widget.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class IndividualChatContentWidget extends StatefulWidget {
  const IndividualChatContentWidget({super.key});

  @override
  State<IndividualChatContentWidget> createState() => _IndividualChatContentWidgetState();
}

class _IndividualChatContentWidgetState extends State<IndividualChatContentWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageInputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    AppLogger.debug("IndividualChatContentWidget: initState");
    // Die meiste Logik hier ist jetzt überflüssig.
  }

  // Wir verwenden didUpdateWidget, um auf Änderungen der Nachrichtenliste zu reagieren.
  @override
  void didUpdateWidget(covariant IndividualChatContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dieser Check ist nicht perfekt, aber er fängt das Hinzufügen einer neuen Nachricht gut ab.
    // Ein komplexerer Vergleich wäre hier möglich, wenn nötig.
    final provider = context.read<IndividualChatProvider>();
    if (provider.messages.isNotEmpty) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    AppLogger.debug("IndividualChatContentWidget: dispose");
    _messageController.dispose();
    _scrollController.dispose();
    _messageInputFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    // Verwende context.read für Aktionen, um unnötige Rebuilds zu vermeiden.
    final provider = context.read<IndividualChatProvider>();
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      AppLogger.debug("IndividualChatContentWidget: Sending text message: '$text'");
      provider.sendTextMessage(text);
      _messageController.clear();
      _messageInputFocusNode.requestFocus();
    } else if (provider.imagePreview != null) {
      AppLogger.debug("IndividualChatContentWidget: Sending selected image.");
      provider.sendSelectedImage();
    }
  }

  Future<void> _pickImage() async {
    final provider = context.read<IndividualChatProvider>();
    AppLogger.debug("IndividualChatContentWidget: Pick image called.");
    _messageInputFocusNode.unfocus();
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        provider.setImageForPreview(File(image.path));
      } else {
        provider.setImageForPreview(null);
      }
    } catch (e, stackTrace) {
      AppLogger.error("IndividualChatContentWidget: ImagePicker Error", e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fehler beim Auswählen des Bildes."), backgroundColor: Colors.red),
        );
      }
      provider.setImageForPreview(null);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    // Verzögerung mit addPostFrameCallback, um sicherzustellen, dass die Liste gezeichnet wurde.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // In einer umgekehrten Liste ist 0 der untere Rand.
          duration: Duration(milliseconds: animated ? 300 : 1),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // context.watch sorgt dafür, dass das Widget neu gebaut wird, wenn sich der Provider-Zustand ändert.
    final chatProvider = context.watch<IndividualChatProvider>();
    final theme = Theme.of(context);
    AppLogger.debug("IndividualChatContentWidget: Building. Messages: ${chatProvider.messages.length}, Loading: ${chatProvider.isLoading}, Sending: ${chatProvider.isSendingMessage}, Error: ${chatProvider.error}");

    return Column(
      children: [
        Expanded(
          child: MessageListWidget(
            messages: chatProvider.messages,
            // --- KORRIGIERTE PROPERTY-NAMEN ---
            isLoading: chatProvider.isLoading && chatProvider.messages.isEmpty,
            listError: chatProvider.error,
            scrollController: _scrollController,
            isGroupChat: false,
          ),
        ),
        // Zeige den Fehler nur an, wenn wir nicht gerade senden (vermeidet doppelte Anzeigen)
        if (chatProvider.error != null && !chatProvider.isSendingMessage)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              chatProvider.error!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        if (chatProvider.imagePreview != null)
          ImagePreviewWidget(
              imageFile: chatProvider.imagePreview!,
              onCancel: () {
                AppLogger.debug("IndividualChatContentWidget: Cancel image preview.");
                context.read<IndividualChatProvider>().setImageForPreview(null);
              }
          ),
        MessageInputWidget(
          controller: _messageController,
          isSending: chatProvider.isSendingMessage,
          onSendPressed: _sendMessage,
          onPickImagePressed: _pickImage,
          focusNode: _messageInputFocusNode,
        ),
      ],
    );
  }
}