// lib/features/chat/presentation/screens/chat_home_screen.dart

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
import '../providers/individual_chat_provider.dart';

// Screens & Widgets
import '../widgets/chat_list_content_widget.dart';
import 'individual_chat_screen.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  void _navigateToChat(
      BuildContext context, String roomId, ChatUserEntity chatPartner) {
    AppLogger.info(
        "ChatHomeScreen: Navigating to chat room $roomId with partner ${chatPartner.name}");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) => ChangeNotifierProvider<IndividualChatProvider>(
          create: (providerContext) => IndividualChatProvider(
            roomId: roomId,
            chatPartner: chatPartner,
            getMessagesStreamUseCase:
            providerContext.read<GetMessagesStreamUseCase>(),
            sendMessageUseCase: providerContext.read<SendMessageUseCase>(),
            markMessageAsReadUseCase:
            providerContext.read<MarkMessageAsReadUseCase>(),
            uploadChatImageUseCase:
            providerContext.read<UploadChatImageUseCase>(),
            watchChatRoomUseCase:
            providerContext.read<WatchChatRoomByIdUseCase>(),
            hideChatUseCase: providerContext.read<HideChatUseCase>(),
            setChatClearedTimestampUseCase:
            providerContext.read<SetChatClearedTimestampUseCase>(),
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

  @override
  Widget build(BuildContext context) {
    // Gibt jetzt nur noch die Inhalts-Liste zurück
    return ChatListContentWidget(
      onChatRoomTap: (tappedRoomId, tappedChatPartner) {
        _navigateToChat(context, tappedRoomId, tappedChatPartner);
      },
    );
  }
}