import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/add_members_to_group_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/delete_group_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/remove_member_from_group_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/update_group_chat_details_usecase.dart';
import 'package:provider/provider.dart';

// Domain Entities (werden indirekt über den Provider genutzt)
// import '../../domain/entities/group_chat_entity.dart';

// UseCases (werden für die Provider-Erstellung im `create` benötigt)
import '../../domain/usecases/watch_group_chat_by_id_usecase.dart';
import '../../domain/usecases/get_group_messages_stream_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart';
// import '../../domain/usecases/update_group_chat_details_usecase.dart'; // Für spätere Bearbeitungsfunktionen

// Provider
import '../providers/group_chat_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Widgets
import '../widgets/group_chat_content_widget.dart';

// Core
import '../../../../core/utils/app_logger.dart';
import 'group_settings_screen.dart';
// import 'group_settings_screen.dart'; // Beispiel für späteren Navigationsziel

class GroupChatScreen extends StatelessWidget {
  final String groupId;
  final String initialGroupName; // Für die AppBar, während Details laden

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.initialGroupName,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.info("GroupChatScreen: Building for groupId: $groupId, initialName: $initialGroupName");
    final theme = Theme.of(context);

    return ChangeNotifierProvider<GroupChatProvider>(
      create: (context) => GroupChatProvider(
        groupId: groupId,
        watchGroupChatByIdUseCase: context.read<WatchGroupChatByIdUseCase>(),
        getGroupMessagesStreamUseCase: context.read<GetGroupMessagesStreamUseCase>(),
        sendMessageUseCase: context.read<SendMessageUseCase>(),
        uploadChatImageUseCase: context.read<UploadChatImageUseCase>(),
        getChatUsersStreamByIdsUseCase: context.read<GetChatUsersStreamByIdsUseCase>(),
        authProvider: context.read<AuthenticationProvider>(),
        updateGroupChatDetailsUseCase: context.read<UpdateGroupChatDetailsUseCase>(),
        addMembersToGroupUseCase: context.read<AddMembersToGroupUseCase>(),
        removeMemberFromGroupUseCase: context.read<RemoveMemberFromGroupUseCase>(),
        deleteGroupUseCase: context.read<DeleteGroupUseCase>(),

      ),
      child: Consumer<GroupChatProvider>(
        builder: (context, provider, _) {
          final String appBarTitle = provider.groupDetails?.name ?? initialGroupName;
          final bool canDisplayContent = provider.groupDetails != null || provider.isLoadingInitialData;
          final bool displayErrorState = !provider.isLoadingInitialData && provider.groupDetails == null && provider.error != null;

          AppLogger.debug("GroupChatScreen Consumer: AppBar Title: $appBarTitle, CanDisplay: $canDisplayContent, ErrorState: $displayErrorState, ProviderError: ${provider.error}");

          return Scaffold(
            backgroundColor: const Color(0xff040324), // Dein Chat-Hintergrund
            appBar: AppBar(
              title: Text(
                appBarTitle,
                style: theme.appBarTheme.titleTextStyle?.copyWith(color: Colors.white) ??
                    const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: const Color(0xff040324), // Dein AppBar-Hintergrund
              iconTheme: theme.appBarTheme.iconTheme?.copyWith(color: Colors.white) ??
                  const IconThemeData(color: Colors.white),
              elevation: 0,
              actions: [
                if (canDisplayContent && !displayErrorState && provider.groupDetails != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded),
                    tooltip: "Gruppeninformationen",
                    onPressed: () {
                      AppLogger.info("Group Info Tapped for groupId: ${provider.groupId}, name: ${provider.groupDetails!.name}");

                      // Wir übergeben den Provider nicht direkt, der Screen holt ihn sich aus dem Kontext.
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: provider,
                          child: const GroupSettingsScreen(),
                        ),
                      ));
                    },
                  ),
              ],
            ),
            body: displayErrorState
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.error ?? "Gruppe konnte nicht geladen werden.",
                        textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => provider.forceReloadData(), // Methode im Provider aufrufen
                      child: const Text("Erneut versuchen"),
                    )
                  ],
                ),
              ),
            )
                : const GroupChatContentWidget(),
          );
        },
      ),
    );
  }
}