import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Provider
import '../providers/group_chat_provider.dart';

// Widgets
import 'message_list_widget.dart';
import 'image_preview_widget.dart';
import 'message_input_widget.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class GroupChatContentWidget extends StatefulWidget {
  const GroupChatContentWidget({super.key});

  @override
  State<GroupChatContentWidget> createState() => _GroupChatContentWidgetState();
}

class _GroupChatContentWidgetState extends State<GroupChatContentWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageInputFocusNode = FocusNode();

  late GroupChatProvider _chatProviderInstance;
  bool _isListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _chatProviderInstance = Provider.of<GroupChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (_chatProviderInstance.messages.isNotEmpty) {
          _scrollToBottom(animated: false);
        }
        if (!_isListenerAttached) {
          _chatProviderInstance.addListener(_onProviderUpdate);
          _isListenerAttached = true;
        }
      }
    });
  }

  void _onProviderUpdate() {
    if (!mounted) return;
    if (_chatProviderInstance.messages.isNotEmpty) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    if (_isListenerAttached) {
      _chatProviderInstance.removeListener(_onProviderUpdate);
    }
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
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _chatProviderInstance.sendTextMessage(text);
      _messageController.clear();
      _messageInputFocusNode.requestFocus();
    } else if (_chatProviderInstance.imagePreview != null) {
      _chatProviderInstance.sendSelectedImage();
    }
  }

  Future<void> _pickImage() async {
    _messageInputFocusNode.unfocus();
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      _chatProviderInstance.setImageForPreview(image != null ? File(image.path) : null);
    } catch (e, stackTrace) {
      AppLogger.error("GroupChatContentWidget: ImagePicker Error", e, stackTrace);
      // OPTIMIERT: Verwendet die neue Snackbar-Helper-Methode
      _showSnackbar("Fehler beim Auswählen des Bildes.", isError: true);
      _chatProviderInstance.setImageForPreview(null);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: animated ? 300 : 0),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<GroupChatProvider>();
    final theme = Theme.of(context);

    if (chatProvider.isLoadingInitialData && chatProvider.groupDetails == null && chatProvider.error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: MessageListWidget(
            messages: chatProvider.messages,
            isLoading: chatProvider.isLoadingInitialData && chatProvider.messages.isEmpty && chatProvider.error == null,
            listError: chatProvider.error,
            scrollController: _scrollController,
            isGroupChat: true,
          ),
        ),
        if (chatProvider.error != null && !chatProvider.isLoadingInitialData)
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
            onCancel: () => chatProvider.setImageForPreview(null),
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