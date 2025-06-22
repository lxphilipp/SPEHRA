import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/hide_chat_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/set_chat_cleared_timestamp_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/watch_chat_room_by_id_usecase.dart';
import 'package:provider/provider.dart';

// Provider
import '../providers/chat_room_list_provider.dart'; // Für startNewChat
// Widgets
import '../widgets/chat_list_content_widget.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../../../core/utils/app_logger.dart';

import 'user_search_screen.dart';
import 'individual_chat_screen.dart';
import '../providers/individual_chat_provider.dart';
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_message_as_read_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  // Zentrale Navigationsmethode zum IndividualChatScreen
  void _navigateToChat(BuildContext context, String roomId, ChatUserEntity chatPartner) {
    AppLogger.info("ChatHomeScreen: Navigating to chat room $roomId with partner ${chatPartner.name}");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) => ChangeNotifierProvider<IndividualChatProvider>(
          create: (providerContext) => IndividualChatProvider(
            roomId: roomId,                            // Wird an den Provider übergeben
            chatPartner: chatPartner,                  // Wird an den Provider übergeben
            getMessagesStreamUseCase: providerContext.read<GetMessagesStreamUseCase>(),
            sendMessageUseCase: providerContext.read<SendMessageUseCase>(),
            markMessageAsReadUseCase: providerContext.read<MarkMessageAsReadUseCase>(),
            uploadChatImageUseCase: providerContext.read<UploadChatImageUseCase>(),
            authProvider: providerContext.read<AuthenticationProvider>(),
            watchChatRoomUseCase: providerContext.read<WatchChatRoomByIdUseCase>(),
            hideChatUseCase: providerContext.read<HideChatUseCase>(),
            setChatClearedTimestampUseCase: providerContext.read<SetChatClearedTimestampUseCase>(),
          ),
          child: IndividualChatScreen(
            roomId: roomId,
            chatPartner: chatPartner,
          ),
        ),
      ),
    );
  }

  // ... (Rest der _startNewChatFlow und build Methoden wie zuvor) ...
  void _startNewChatFlow(BuildContext context) async {
    AppLogger.debug("ChatHomeScreen: _startNewChatFlow initiated. Navigating to UserSearchScreen.");

    final ChatUserEntity? selectedPartner = await Navigator.of(context).push<ChatUserEntity>(
      MaterialPageRoute(
        builder: (context) => const UserSearchScreen(),
      ),
    );

    if (selectedPartner == null) {
      AppLogger.debug("ChatHomeScreen: No partner selected from UserSearchScreen.");
      return;
    }
    if (!context.mounted) return;

    AppLogger.debug("ChatHomeScreen: Partner selected: ${selectedPartner.name} (ID: ${selectedPartner.id}). Attempting to start chat.");
    final chatRoomListProvider = context.read<ChatRoomListProvider>();

    final String? roomId = await chatRoomListProvider.startNewChat(
        selectedPartner.id,
        initialTextMessage: "Hallo ${selectedPartner.name}!"
    );

    if (!context.mounted) return;

    if (roomId != null) {
      AppLogger.info("ChatHomeScreen: New chat room created/found: $roomId. Navigating.");
      _navigateToChat(context, roomId, selectedPartner);
    } else if (chatRoomListProvider.error != null) {
      AppLogger.error("ChatHomeScreen: Error starting new chat: ${chatRoomListProvider.error}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Starten des Chats: ${chatRoomListProvider.error}"), backgroundColor: Colors.red),
      );
    } else {
      AppLogger.warning("ChatHomeScreen: startNewChat returned null roomId without a provider error.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chat konnte nicht gestartet werden. Unbekannter Fehler."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug("ChatHomeScreen: Build method called.");
    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        backgroundColor: const Color(0xff040324),
        title: const Text('Meine Chats', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
            onPressed: () => _startNewChatFlow(context),
            tooltip: "Neuer Chat",
          )
        ],
      ),
      body: ChatListContentWidget(
        onChatRoomTap: (tappedRoomId, tappedChatPartner) {
          _navigateToChat(context, tappedRoomId, tappedChatPartner);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.bug_report),
        onPressed: () {
          // Rufe die Test-Methode im Provider auf
          context.read<ChatRoomListProvider>().testRemoveFirstChat();
        },
      ),
    );
  }
}