import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/add_members_to_group_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/delete_group_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/remove_member_from_group_usecase.dart';
import 'package:flutter_sdg/features/chat/domain/usecases/update_group_chat_details_usecase.dart';
import 'package:provider/provider.dart';

// UseCases
import '../../domain/usecases/watch_group_chat_by_id_usecase.dart';
import '../../domain/usecases/get_group_messages_stream_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../domain/usecases/get_chat_users_stream_by_ids_usecase.dart';

// Provider
import '../providers/group_chat_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Widgets & Screens
import '../widgets/group_chat_content_widget.dart';
import 'group_settings_screen.dart';

// Core
import '../../../../core/utils/app_logger.dart';

class GroupChatScreen extends StatelessWidget {
  final String groupId;
  final String initialGroupName;

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
          final appBarTitle = provider.groupDetails?.name ?? initialGroupName;
          final canDisplayContent = provider.groupDetails != null || provider.isLoadingInitialData;
          final displayErrorState = !provider.isLoadingInitialData && provider.groupDetails == null && provider.error != null;

          return Scaffold(
            // OPTIMIERT: Hintergrundfarbe aus dem Theme
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              // OPTIMIERT: Alle Stile (Farbe, Text, Icons) werden vom AppBarTheme geerbt
              title: Text(
                appBarTitle,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (canDisplayContent && !displayErrorState && provider.groupDetails != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded),
                    tooltip: "Gruppeninformationen",
                    onPressed: () {
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
                    Text(
                      provider.error ?? "Gruppe konnte nicht geladen werden.",
                      textAlign: TextAlign.center,
                      // OPTIMIERT: Verwendet Text- und Farbstil aus dem Theme
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.forceReloadData(),
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