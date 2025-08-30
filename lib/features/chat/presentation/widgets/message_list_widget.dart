import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Entities
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_user_entity.dart';

// Widgets
import 'chat_message_item_widget.dart';

// Provider
import '../providers/individual_chat_provider.dart';
import '../providers/group_chat_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class MessageListWidget extends StatelessWidget {
  final List<MessageEntity> messages;
  final bool isLoading;
  final String? listError;
  final ScrollController scrollController;
  final bool isGroupChat;

  const MessageListWidget({
    super.key,
    required this.messages,
    required this.isLoading,
    this.listError,
    required this.scrollController,
    required this.isGroupChat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppLogger.debug("MessageListWidget: Building. Message count: ${messages.length}, isLoading: $isLoading, isGroupChat: $isGroupChat, Error: $listError");

    if (isLoading && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listError != null && messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Fehler beim Laden der Nachrichten:\n$listError",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Text(
          "Sende eine Nachricht, um die Unterhaltung zu beginnen!",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    String currentUserId = "";
    ChatUserEntity? chatPartnerForIndividualChat;
    Map<String, ChatUserEntity> memberDetailsMapForGroupChat = {};

    if (isGroupChat) {
      final groupProvider = context.watch<GroupChatProvider>();
      currentUserId = groupProvider.currentUserId;
      memberDetailsMapForGroupChat = groupProvider.memberDetailsMap;
    } else {
      final individualProvider = context.watch<IndividualChatProvider>();
      currentUserId = individualProvider.currentUserId;
      chatPartnerForIndividualChat = individualProvider.chatPartner;
    }

    if (currentUserId.isEmpty) {
      AppLogger.error("MessageListWidget: currentUserId is empty. Cannot determine message sender.");
      return Center(
        child: Text(
          "Fehler: Benutzer-ID nicht verfügbar.",
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final bool isMe = message.fromId == currentUserId;
        ChatUserEntity? senderDetails;

        if (!isMe) {
          if (isGroupChat) {
            senderDetails = memberDetailsMapForGroupChat[message.fromId];
            if (senderDetails == null) {
              AppLogger.warning("MessageListWidget: Sender details not found for group member ${message.fromId} in message ${message.id}");
            }
          } else {
            if (chatPartnerForIndividualChat?.id == message.fromId) {
              senderDetails = chatPartnerForIndividualChat;
            }
          }
        }

        return ChatMessageItemWidget(
          message: message,
          isMe: isMe,
          senderDetails: senderDetails,
        );
      },
    );
  }
}