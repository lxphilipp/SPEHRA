import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Entities
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_user_entity.dart'; // Für ChatUserEntity

// Widgets
import 'chat_message_item_widget.dart'; // Das Widget für einzelne Nachrichten

// Provider (um currentUserId und Partner/Mitglieder-Details zu bekommen)
import '../providers/individual_chat_provider.dart';
import '../providers/group_chat_provider.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class MessageListWidget extends StatelessWidget {
  final List<MessageEntity> messages;
  final bool isLoading; // Zeigt an, ob die Nachrichtenliste initial geladen wird
  final String? listError; // Spezifischer Fehler für das Laden der Liste
  final ScrollController scrollController;
  final bool isGroupChat; // Unterscheidet, ob es ein Gruppenchat oder 1-zu-1 Chat ist

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
    AppLogger.debug("MessageListWidget: Building. Message count: ${messages.length}, isLoading: $isLoading, isGroupChat: $isGroupChat, Error: $listError");

    if (isLoading && messages.isEmpty) {
      AppLogger.debug("MessageListWidget: Showing initial loading indicator.");
      return const Center(child: CircularProgressIndicator());
    }

    if (listError != null && messages.isEmpty) {
      AppLogger.error("MessageListWidget: Displaying list error: $listError");
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Fehler beim Laden der Nachrichten:\n$listError",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent)),
        ),
      );
    }

    if (messages.isEmpty) {
      AppLogger.debug("MessageListWidget: No messages to display.");
      return const Center(
        child: Text(
          "Sende eine Nachricht, um die Unterhaltung zu beginnen!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
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
      // Fallback oder Fehleranzeige, wenn currentUserId nicht verfügbar ist
      return const Center(child: Text("Fehler: Benutzer-ID nicht verfügbar.", style: TextStyle(color: Colors.redAccent)));
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true, // Wichtig für Chat-Layout (neueste Nachrichten unten)
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
            // In 1-zu-1 ist der Absender (wenn nicht ich) der Chat-Partner
            if (chatPartnerForIndividualChat != null && message.fromId == chatPartnerForIndividualChat.id) {
              senderDetails = chatPartnerForIndividualChat;
            } else if (chatPartnerForIndividualChat == null) {
              AppLogger.warning("MessageListWidget: chatPartnerForIndividualChat is null for message ${message.id} from ${message.fromId}");
            } else if (message.fromId != chatPartnerForIndividualChat.id) {
              AppLogger.warning("MessageListWidget: Message ${message.id} fromId ${message.fromId} does not match partnerId ${chatPartnerForIndividualChat.id}");
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