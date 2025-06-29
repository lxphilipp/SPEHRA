import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Provider
import '../providers/individual_chat_provider.dart';

// Widgets
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
  void didUpdateWidget(covariant IndividualChatContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = context.read<IndividualChatProvider>();
    if (provider.messages.isNotEmpty) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageInputFocusNode.dispose();
    super.dispose();
  }

  // OPTIMIERT: Helper-Methode für themenkonforme Snackbars
  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
    );
  }

  void _sendMessage() {
    final provider = context.read<IndividualChatProvider>();
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      provider.sendTextMessage(text);
      _messageController.clear();
      _messageInputFocusNode.requestFocus();
    } else if (provider.imagePreview != null) {
      provider.sendSelectedImage();
    }
  }

  Future<void> _pickImage() async {
    final provider = context.read<IndividualChatProvider>();
    _messageInputFocusNode.unfocus();
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      provider.setImageForPreview(image != null ? File(image.path) : null);
    } catch (e, stackTrace) {
      AppLogger.error("IndividualChatContentWidget: ImagePicker Error", e, stackTrace);
      // OPTIMIERT: Verwendet die neue Snackbar-Helper-Methode
      _showSnackbar("Fehler beim Auswählen des Bildes.", isError: true);
      provider.setImageForPreview(null);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: animated ? 300 : 1),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<IndividualChatProvider>();
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: MessageListWidget(
            messages: chatProvider.messages,
            isLoading: chatProvider.isLoading && chatProvider.messages.isEmpty,
            listError: chatProvider.error,
            scrollController: _scrollController,
            isGroupChat: false,
          ),
        ),
        if (chatProvider.error != null && !chatProvider.isSendingMessage)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              chatProvider.error!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        if (chatProvider.imagePreview != null)
          ImagePreviewWidget(
            imageFile: chatProvider.imagePreview!,
            onCancel: () => context.read<IndividualChatProvider>().setImageForPreview(null),
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