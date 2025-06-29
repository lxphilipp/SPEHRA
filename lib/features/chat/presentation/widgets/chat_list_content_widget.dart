import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Provider & Entities
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_room_list_provider.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/chat_user_entity.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class ChatListContentWidget extends StatelessWidget {
  final void Function(String roomId, ChatUserEntity chatPartner) onChatRoomTap;

  const ChatListContentWidget({
    super.key,
    required this.onChatRoomTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Theme am Anfang holen
    final provider = context.watch<ChatRoomListProvider>();
    final currentUserId = context.watch<AuthenticationProvider>().currentUserId;
    final partnerDetailsMap = provider.partnerDetailsMap;

    // --- Ladezustand ---
    if (provider.isLoading && provider.chatRooms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // --- Fehlerzustand ---
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fehler: ${provider.error}',
                textAlign: TextAlign.center,
                // OPTIMIERT: Fehlertext-Stil aus dem Theme
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => context.read<ChatRoomListProvider>().forceReloadChatRooms(),
                child: const Text("Erneut versuchen"),
              )
            ],
          ),
        ),
      );
    }

    // --- Leerer Zustand ---
    if (provider.chatRooms.isEmpty) {
      return Center(
        child: Text(
          'Noch keine Chats vorhanden.\nStarte einen neuen Chat!',
          textAlign: TextAlign.center,
          // OPTIMIERT: Text-Stil aus dem Theme
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    // --- Erfolgszustand: Liste anzeigen ---
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: provider.chatRooms.length,
      itemBuilder: (context, index) {
        final room = provider.chatRooms[index];
        final partnerId = room.members.firstWhere((id) => id != currentUserId, orElse: () => '');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPartnerLoaded = chatPartner != null;

    final Widget leading;
    final String title;

    if (isPartnerLoaded) {
      title = chatPartner!.name;
      leading = CircleAvatar(
        backgroundImage: (chatPartner!.imageUrl != null && chatPartner!.imageUrl!.isNotEmpty)
            ? NetworkImage(chatPartner!.imageUrl!)
            : null,
        // OPTIMIERT: Hintergrundfarbe aus dem Theme
        backgroundColor: theme.colorScheme.surfaceVariant,
        child: (chatPartner!.imageUrl == null || chatPartner!.imageUrl!.isEmpty)
            ? Text(title.isNotEmpty ? title[0].toUpperCase() : "?")
            : null,
      );
    } else {
      title = 'Lade...';
      leading = CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceVariant,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final subtitle = room.lastMessage ?? 'Tippe, um zu chatten';

    // OPTIMIERT: Das ListTile ist jetzt in einer thematisierten Card verpackt
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: leading,
        title: Text(
          title,
          style: theme.textTheme.titleMedium, // OPTIMIERT: Stil aus Theme
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant, // OPTIMIERT
          ),
        ),
        trailing: room.lastMessageTime != null
            ? Text(
          DateFormat('HH:mm').format(room.lastMessageTime!),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant, // OPTIMIERT
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