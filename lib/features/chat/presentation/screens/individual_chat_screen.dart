import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Domain Entities
import '../../domain/entities/chat_user_entity.dart';

// UseCases (werden für die Provider-Erstellung im `create` benötigt)
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/hide_chat_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_message_as_read_usecase.dart';
import '../../domain/usecases/set_chat_cleared_timestamp_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
// import '../../domain/usecases/delete_message_usecase.dart'; // Optional

// Provider
import '../../domain/usecases/watch_chat_room_by_id_usecase.dart';
import '../providers/individual_chat_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // Für die `currentUserId`

// Widgets
import '../widgets/individual_chat_content_widget.dart';

// Core
import '../../../../core/utils/app_logger.dart';
import 'individual_chat_info_screen.dart';

class IndividualChatScreen extends StatelessWidget {
  final String roomId; // Wird von der Chatliste übergeben
  final ChatUserEntity chatPartner; // Wird von der Chatliste übergeben

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
        // UseCases und andere Abhängigkeiten werden hier aus dem übergeordneten Kontext geholt
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
        backgroundColor: const Color(0xff040324), // Dein Chat-Hintergrund
        appBar: AppBar(
          title: Text(
            chatPartner.name,
            style: theme.appBarTheme.titleTextStyle?.copyWith(color: Colors.white) ??
                const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xff040324), // Dein AppBar-Hintergrund
          iconTheme: theme.appBarTheme.iconTheme?.copyWith(color: Colors.white) ??
              const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            Consumer<IndividualChatProvider>(
              builder: (context, provider, child) {
                // Zeige den Button nur, wenn der Provider nicht im Ladezustand ist
                if (provider.isLoading) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: "Chat Info",
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        // Wichtig: .value, um dieselbe Provider-Instanz weiterzugeben
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
        // Der Body ist jetzt das separate Content-Widget.
        // Es braucht keine expliziten Parameter mehr, da es den IndividualChatProvider
        // über context.watch/read innerhalb seiner eigenen Build-Methode erhält.
        body: const IndividualChatContentWidget(),
      ),
    );
  }
}