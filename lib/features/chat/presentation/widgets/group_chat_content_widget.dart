import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Providers
import '../../../challenges/domain/entities/group_challenge_progress_entity.dart';
import '../../../challenges/presentation/widgets/group_challenge_status_card.dart';
import '../providers/group_chat_provider.dart';

// Widgets
import 'image_preview_widget.dart';
import 'message_input_widget.dart';
import 'chat_message_item_widget.dart'; // We will still use this for individual messages
import '../../../invites/presentation/widgets/challenge_invite_card_widget.dart'; // Our new invite card

// Entities
import '../../domain/entities/message_entity.dart';
import '../../../invites/domain/entities/invite_entity.dart';

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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageInputFocusNode.dispose();
    super.dispose();
  }

  // Helper methods for sending messages and picking images remain the same
  void _sendMessage(GroupChatProvider provider) {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      provider.sendTextMessage(text);
      _messageController.clear();
      _messageInputFocusNode.requestFocus();
    } else if (provider.imagePreview != null) {
      provider.sendSelectedImage();
    }
  }

  Future<void> _pickImage(GroupChatProvider provider) async {
    _messageInputFocusNode.unfocus();
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      provider.setImageForPreview(image != null ? File(image.path) : null);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    // We use .watch() here to listen for all changes
    final chatProvider = context.watch<GroupChatProvider>();
    final theme = Theme.of(context);

    if (chatProvider.isLoadingInitialData && chatProvider.groupDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get the final, sorted list from the provider
    final List<dynamic> chatItems = chatProvider.chatItems;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true, // Crucial for chat UIs
            padding: const EdgeInsets.all(8.0),
            itemCount: chatItems.length,
            itemBuilder: (context, index) {
              final item = chatItems[index];

              if (item is MessageEntity) {
                final senderDetails = chatProvider.getMemberDetail(item.fromId);
                return ChatMessageItemWidget(
                  message: item,
                  senderDetails: senderDetails,
                  isMe: item.fromId == chatProvider.currentUserId,
                );
              } else if (item is InviteEntity) {
                return ChallengeInviteCardWidget(
                  invite: item,
                );
              } else if (item is GroupChallengeProgressEntity) {
                return GroupChallengeStatusCard(groupProgress: item);
              }

              // Fallback for any other type
              return const SizedBox.shrink();
            },
          ),
        ),

        // The rest of your UI remains the same
        if (chatProvider.error != null)
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
          onSendPressed: () => _sendMessage(chatProvider),
          onPickImagePressed: () => _pickImage(chatProvider),
          focusNode: _messageInputFocusNode,
        ),
      ],
    );
  }
}