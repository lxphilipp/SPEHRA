import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Provider & Entities
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_room_list_provider.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_user_entity.dart';

// Core

class ChatListContentWidget extends StatelessWidget {
  final void Function(String roomId, ChatUserEntity chatPartner) onChatRoomTap;

  const ChatListContentWidget({
    super.key,
    required this.onChatRoomTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ChatRoomListProvider>();
    final currentUserId = context.watch<AuthenticationProvider>().currentUserId;
    final chatRooms = provider.sortedChatRooms;
    final partnerDetailsMap = provider.partnerDetailsMap;

    if (provider.isLoading && chatRooms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: ${provider.error}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () =>
                    context.read<ChatRoomListProvider>().forceReloadChatRooms(),
                child: const Text("Try again"),
              )
            ],
          ),
        ),
      );
    }

    if (chatRooms.isEmpty) {
      return Center(
        child: Text(
          'No chat started yet.\nStart a new chat!',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: chatRooms.length,
      itemBuilder: (context, index) {
        final room = chatRooms[index];
        final partnerId =
        room.members.firstWhere((id) => id != currentUserId, orElse: () => '');
        final partnerDetails = partnerDetailsMap[partnerId];

        return ChatRoomListItemWidget(
          key: ValueKey(room.id),
          room: room,
          chatPartner: partnerDetails,
          onTap: (loadedPartner) {
            onChatRoomTap(room.id, loadedPartner);
          },
        );
      },
    );
  }
}

class ChatRoomListItemWidget extends StatelessWidget {
  final ChatRoomEntity room;
  final ChatUserEntity? chatPartner;
  final void Function(ChatUserEntity) onTap;

  const ChatRoomListItemWidget({
    super.key,
    required this.room,
    required this.chatPartner,
    required this.onTap,
  });

  // NEUE HELFER-FUNKTION FÜR DAS DATUM
  String _formatLastMessageTime(BuildContext context, DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return DateFormat('HH:mm').format(date); // Nur die Zeit für heute
    } else if (dateToCompare == yesterday) {
      return 'Yesterday';
    } else {
      // Für ältere Daten nur das Datum
      return DateFormat('dd.MM.yy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPartnerLoaded = chatPartner != null;

    final Widget leading;
    final String title;

    if (isPartnerLoaded) {
      title = chatPartner!.name;
      leading = CircleAvatar(
        backgroundImage: (chatPartner!.imageUrl != null &&
            chatPartner!.imageUrl!.isNotEmpty)
            ? NetworkImage(chatPartner!.imageUrl!)
            : null,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: (chatPartner!.imageUrl == null || chatPartner!.imageUrl!.isEmpty)
            ? Text(title.isNotEmpty ? title[0].toUpperCase() : "?")
            : null,
      );
    } else {
      title = 'Loading...';
      leading = CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final subtitle = room.lastMessage ?? 'Click to start chat';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: leading,
        title: Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: room.lastMessageTime != null
            ? Text(
          _formatLastMessageTime(context, room.lastMessageTime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        )
            : null,
        onTap: () {
          if (isPartnerLoaded) {
            onTap(chatPartner!);
          }
        },
      ),
    );
  }
}