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

// --- Haupt-Widget für den Inhalt der Chat-Liste ---
class ChatListContentWidget extends StatelessWidget {
  final void Function(String roomId, ChatUserEntity chatPartner) onChatRoomTap;

  const ChatListContentWidget({
    super.key,
    required this.onChatRoomTap,
  });

  @override
  Widget build(BuildContext context) {
    // context.watch() sorgt dafür, dass das Widget bei jeder Änderung im Provider neu gebaut wird.
    final provider = context.watch<ChatRoomListProvider>();
    final currentUserId = context.watch<AuthenticationProvider>().currentUserId;

    // Wir holen auch die Map mit den Partner-Details vom Provider.
    final partnerDetailsMap = provider.partnerDetailsMap;

    // --- Ladezustand ---
    if (provider.isLoading && provider.chatRooms.isEmpty) {
      AppLogger.debug("ChatListContentWidget: Showing initial loading indicator.");
      return const Center(child: CircularProgressIndicator());
    }

    // --- Fehlerzustand ---
    if (provider.error != null) {
      AppLogger.error("ChatListContentWidget: Displaying error: ${provider.error}");
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fehler: ${provider.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  AppLogger.info("ChatListContentWidget: 'Erneut versuchen' tapped.");
                  context.read<ChatRoomListProvider>().forceReloadChatRooms();
                },
                child: const Text("Erneut versuchen"),
              )
            ],
          ),
        ),
      );
    }

    // --- Leerer Zustand ---
    if (provider.chatRooms.isEmpty) {
      AppLogger.debug("ChatListContentWidget: No chat rooms to display.");
      return const Center(
        child: Text(
          'Noch keine Chats vorhanden.\nStarte einen neuen Chat!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // --- Erfolgszustand: Liste anzeigen ---
    AppLogger.debug("ChatListContentWidget: Displaying ${provider.chatRooms.length} chat rooms.");
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: provider.chatRooms.length,
      itemBuilder: (context, index) {
        final room = provider.chatRooms[index];

        // Finde die ID des Partners in diesem Raum.
        final partnerId = room.members.firstWhere(
              (id) => id != currentUserId,
          orElse: () => '',
        );

        // Hole die bereits geladenen Partner-Details direkt aus der Map.
        final partnerDetails = partnerDetailsMap[partnerId];

        return ChatRoomListItemWidget(
          key: ValueKey(room.id), // Wichtig für effiziente Updates der Liste
          room: room,
          chatPartner: partnerDetails, // Übergib die (möglicherweise noch null) Details
          onTap: (loadedPartner) { // Callback erhält die vollen Partner-Details
            onChatRoomTap(room.id, loadedPartner);
          },
        );
      },
    );
  }
}

// --- Widget für einen einzelnen Chatraum-Eintrag ---
// Dieses Widget ist jetzt viel einfacher und enthält keine eigene Lade-Logik mehr.
class ChatRoomListItemWidget extends StatelessWidget {
  final ChatRoomEntity room;
  final ChatUserEntity? chatPartner; // Wird von oben übergeben, kann null sein
  final void Function(ChatUserEntity) onTap;

  const ChatRoomListItemWidget({
    super.key,
    required this.room,
    required this.chatPartner,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    Widget leading;
    final bool isPartnerLoaded = chatPartner != null;

    if (isPartnerLoaded) {
      title = chatPartner!.name;
      if (chatPartner!.imageUrl != null && chatPartner!.imageUrl!.isNotEmpty) {
        leading = CircleAvatar(backgroundImage: NetworkImage(chatPartner!.imageUrl!));
      } else {
        leading = CircleAvatar(
          backgroundColor: Colors.grey[700],
          child: Text(title.isNotEmpty ? title[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white)),
        );
      }
    } else {
      // Fallback-UI, während die Partner-Details noch im Provider laden
      title = 'Lade...';
      leading = const CircleAvatar(
        backgroundColor: Colors.white24,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }

    String subtitle = room.lastMessage ?? 'Tippe, um zu chatten';

    return Card(
      color: Colors.grey[850]?.withOpacity(0.8),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: leading,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: room.lastMessageTime != null
            ? Text(
          DateFormat('HH:mm').format(room.lastMessageTime!),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
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