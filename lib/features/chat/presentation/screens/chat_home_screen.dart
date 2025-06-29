import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Domain & Entities
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/hide_chat_usecase.dart';
import '../../domain/usecases/mark_message_as_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/set_chat_cleared_timestamp_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../domain/usecases/watch_chat_room_by_id_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Providers
import '../providers/chat_room_list_provider.dart';
import '../providers/individual_chat_provider.dart';

// Screens & Widgets
import '../widgets/chat_list_content_widget.dart';
import 'individual_chat_screen.dart';
import 'user_search_screen.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  void _navigateToChat(BuildContext context, String roomId, ChatUserEntity chatPartner) {
    AppLogger.info("ChatHomeScreen: Navigating to chat room $roomId with partner ${chatPartner.name}");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) => ChangeNotifierProvider<IndividualChatProvider>(
          create: (providerContext) => IndividualChatProvider(
            roomId: roomId,
            chatPartner: chatPartner,
            getMessagesStreamUseCase: providerContext.read<GetMessagesStreamUseCase>(),
            sendMessageUseCase: providerContext.read<SendMessageUseCase>(),
            markMessageAsReadUseCase: providerContext.read<MarkMessageAsReadUseCase>(),
            uploadChatImageUseCase: providerContext.read<UploadChatImageUseCase>(),
            watchChatRoomUseCase: providerContext.read<WatchChatRoomByIdUseCase>(),
            hideChatUseCase: providerContext.read<HideChatUseCase>(),
            setChatClearedTimestampUseCase: providerContext.read<SetChatClearedTimestampUseCase>(),
            authProvider: providerContext.read<AuthenticationProvider>(),
          ),
          child: IndividualChatScreen(
            roomId: roomId,
            chatPartner: chatPartner,
          ),
        ),
      ),
    );
  }

  void _startNewChatFlow(BuildContext context) async {
    AppLogger.debug("ChatHomeScreen: _startNewChatFlow initiated. Navigating to UserSearchScreen.");

    final ChatUserEntity? selectedPartner = await Navigator.of(context).push<ChatUserEntity>(
      MaterialPageRoute(
        builder: (context) => const UserSearchScreen(),
      ),
    );

    if (selectedPartner == null || !context.mounted) {
      AppLogger.debug("ChatHomeScreen: No partner selected or context is no longer mounted.");
      return;
    }

    final chatRoomListProvider = context.read<ChatRoomListProvider>();
    final theme = Theme.of(context); // Holen des Themes für die Snackbar-Farbe

    final String? roomId = await chatRoomListProvider.startNewChat(
      selectedPartner.id,
      initialTextMessage: "Hallo ${selectedPartner.name}!",
    );

    if (!context.mounted) return;

    if (roomId != null) {
      AppLogger.info("ChatHomeScreen: New chat room created/found: $roomId. Navigating.");
      _navigateToChat(context, roomId, selectedPartner);
    } else {
      final errorMsg = chatRoomListProvider.error ?? "Could not start chat. Unknown error.";
      AppLogger.error("ChatHomeScreen: Error starting new chat: $errorMsg");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          // OPTIMIERT: Verwendet die Fehlerfarbe aus dem zentralen Theme
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChatListContentWidget(
      onChatRoomTap: (tappedRoomId, tappedChatPartner) {
        _navigateToChat(context, tappedRoomId, tappedChatPartner);
      },
    );
  }
}