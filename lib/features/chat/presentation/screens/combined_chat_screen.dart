import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/chat_home_screen.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/create_group_screen.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/user_search_screen.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/individual_chat_screen.dart';
import 'package:flutter_sdg/features/chat/presentation/widgets/group_chat_list_content_widget.dart';

// Entities und Provider für die Logik
import '../../../../core/widgets/feature_screen_header.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../providers/chat_room_list_provider.dart';
import '../providers/group_chat_list_provider.dart';
import '../providers/individual_chat_provider.dart';
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/hide_chat_usecase.dart';
import '../../domain/usecases/mark_message_as_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/set_chat_cleared_timestamp_usecase.dart';
import '../../domain/usecases/upload_chat_image_usecase.dart';
import '../../domain/usecases/watch_chat_room_by_id_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';

class CombinedChatScreen extends StatefulWidget {
  const CombinedChatScreen({super.key});

  @override
  State<CombinedChatScreen> createState() => _CombinedChatScreenState();
}

class _CombinedChatScreenState extends State<CombinedChatScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToChat(
      BuildContext context, String roomId, ChatUserEntity chatPartner) {
    AppLogger.info(
        "CombinedChatScreen: Navigating to chat room $roomId with partner ${chatPartner.name}");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (pageContext) =>
            ChangeNotifierProvider<IndividualChatProvider>(
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

  void _onFabPressed() async {
    if (_tabController.index == 0) {
      AppLogger.debug("CombinedChatScreen: FAB pressed for new private chat.");
      final ChatUserEntity? selectedPartner =
      await Navigator.of(context).push<ChatUserEntity>(
        MaterialPageRoute(
          builder: (context) => const UserSearchScreen(),
        ),
      );

      if (selectedPartner == null || !mounted) {
        AppLogger.debug(
            "CombinedChatScreen: No partner selected or context is no longer mounted.");
        return;
      }

      final chatRoomListProvider = context.read<ChatRoomListProvider>();
      final String? roomId =
      await chatRoomListProvider.startNewChat(selectedPartner.id);

      if (!mounted) return;

      if (roomId != null) {
        AppLogger.info(
            "CombinedChatScreen: New chat room created/found: $roomId. Navigating.");
        _navigateToChat(context, roomId, selectedPartner);
      } else {
        final errorMsg = chatRoomListProvider.error ?? "Could not start chat.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      // Neue Gruppe
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CreateGroupScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
        child:
        Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            FeatureScreenHeader(
              title: "Chats",
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Iconsax.sort),
                  tooltip: "Sort by...",
                  onSelected: (String value) {
                    if (_tabController.index == 0) {
                      context.read<ChatRoomListProvider>().setSortCriteria(value);
                    } else {
                      context.read<GroupChatListProvider>().setSortCriteria(value);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'lastMessageTime_desc',
                      child: Text('Newest first'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'lastMessageTime_asc',
                      child: Text('Oldest first'),
                    ),
                  ],
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Private'),
                Tab(text: 'Groups'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ChatHomeScreen(),
                  GroupChatListContentWidget(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onFabPressed,
          tooltip: _tabController.index == 0 ? 'New Chat' : 'New Group',
          child: const Icon(Iconsax.add),
        ),
      )
    );
  }
}