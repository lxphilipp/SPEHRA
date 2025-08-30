import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Domain Entities
import '../../domain/entities/chat_user_entity.dart';

// UseCases
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/hide_chat_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_message_as_read_usecase.dart';
import '../../domain/usecases/set_chat_cleared_timestamp_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../domain/usecases/watch_chat_room_by_id_usecase.dart';

// Provider
import '../providers/individual_chat_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Widgets & Screens
import '../widgets/individual_chat_content_widget.dart';
import 'individual_chat_info_screen.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class IndividualChatScreen extends StatelessWidget {
  final String roomId;
  final ChatUserEntity chatPartner;

  const IndividualChatScreen({
    super.key,
    required this.roomId,
    required this.chatPartner,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.info("IndividualChatScreen: Building for roomId: $roomId, partner: ${chatPartner.name} (ID: ${chatPartner.id})");
    final theme = Theme.of(context);

    return ChangeNotifierProvider<IndividualChatProvider>(
      create: (context) => IndividualChatProvider(
        roomId: roomId,
        chatPartner: chatPartner,
        getMessagesStreamUseCase: context.read<GetMessagesStreamUseCase>(),
        sendMessageUseCase: context.read<SendMessageUseCase>(),
        markMessageAsReadUseCase: context.read<MarkMessageAsReadUseCase>(),
        uploadChatImageUseCase: context.read<UploadChatImageUseCase>(),
        authProvider: context.read<AuthenticationProvider>(),
        watchChatRoomUseCase: context.read<WatchChatRoomByIdUseCase>(),
        hideChatUseCase: context.read<HideChatUseCase>(),
        setChatClearedTimestampUseCase: context.read<SetChatClearedTimestampUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(chatPartner.name),
          actions: [
            Consumer<IndividualChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: "Chat Info",
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: provider,
                        child: const IndividualChatInfoScreen(),
                      ),
                    ));
                  },
                );
              },
            ),
          ],
        ),
        body: const IndividualChatContentWidget(),
      ),
    );
  }
}