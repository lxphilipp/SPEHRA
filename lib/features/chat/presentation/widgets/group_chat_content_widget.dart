import 'dart:io'; // Für File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Für Bildauswahl
import 'package:provider/provider.dart'; // Für Provider-Zugriff

// Provider
import '../providers/group_chat_provider.dart';

// Kleinere UI-Komponenten-Widgets
import 'message_list_widget.dart';
import 'image_preview_widget.dart';
import 'message_input_widget.dart';
// ChatMessageItemWidget wird innerhalb von MessageListWidget verwendet

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
  bool _isListenerAttached = false; // KORREKT: Nicht final deklarieren

  @override
  void initState() {
    super.initState();
    AppLogger.debug("GroupChatContentWidget: initState for GroupChatProvider");

    _chatProviderInstance = Provider.of<GroupChatProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _chatProviderInstance.messages.isNotEmpty) {
        _scrollToBottom(animated: false);
      }
      if (mounted && !_isListenerAttached) { // Listener nur einmal hinzufügen
        _chatProviderInstance.addListener(_onProviderUpdate);
        _isListenerAttached = true; // KORREKT: Wert kann jetzt geändert werden
        AppLogger.debug("GroupChatContentWidget: Provider listener attached.");
      }
    });
  }

  void _onProviderUpdate() {
    if (!mounted) return;
    AppLogger.debug("GroupChatContentWidget: _onProviderUpdate triggered.");

    if (_chatProviderInstance.messages.isNotEmpty) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    AppLogger.debug("GroupChatContentWidget: dispose for GroupChatProvider");
    if (_isListenerAttached) { // KORREKT: Überprüfe den aktuellen Wert
      try {
        _chatProviderInstance.removeListener(_onProviderUpdate);
        AppLogger.debug("GroupChatContentWidget: Provider listener removed.");
      } catch (e) {
        AppLogger.warning("GroupChatContentWidget: Fehler beim Entfernen des Listeners: $e");
      }
    }
    _messageController.dispose();
    _scrollController.dispose();
    _messageInputFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      AppLogger.debug("GroupChatContentWidget: Sending text message: '$text'");
      _chatProviderInstance.sendTextMessage(text);
      _messageController.clear();
      _messageInputFocusNode.requestFocus();
    } else if (_chatProviderInstance.imagePreview != null) {
      AppLogger.debug("GroupChatContentWidget: Sending selected image.");
      _chatProviderInstance.sendSelectedImage();
    }
  }

  Future<void> _pickImage() async {
    AppLogger.debug("GroupChatContentWidget: Pick image called.");
    _messageInputFocusNode.unfocus();
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        _chatProviderInstance.setImageForPreview(File(image.path));
      } else {
        _chatProviderInstance.setImageForPreview(null);
      }
    } catch (e, stackTrace) {
      AppLogger.error("GroupChatContentWidget: ImagePicker Error", e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fehler beim Auswählen des Bildes."), backgroundColor: Colors.red),
        );
      }
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
    AppLogger.debug("GroupChatContentWidget: Building. Group: ${chatProvider.groupDetails?.name}, Messages: ${chatProvider.messages.length}, LoadingInitial: ${chatProvider.isLoadingInitialData}, Sending: ${chatProvider.isSendingMessage}, Error: ${chatProvider.error}");

    if (chatProvider.isLoadingInitialData && chatProvider.groupDetails == null && chatProvider.error == null) {
      AppLogger.debug("GroupChatContentWidget: Showing main loading indicator (groupDetails null, no error yet).");
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
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        if (chatProvider.imagePreview != null)
          ImagePreviewWidget(
              imageFile: chatProvider.imagePreview!,
              onCancel: () {
                AppLogger.debug("GroupChatContentWidget: Cancel image preview.");
                chatProvider.setImageForPreview(null);
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