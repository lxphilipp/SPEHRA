import 'package:flutter/material.dart';

// Widgets
import '../widgets/group_chat_list_content_widget.dart';

// Screens (für Navigation)
import 'create_group_screen.dart';
// Core
import '../../../../core/utils/app_logger.dart';

class GroupChatListScreen extends StatelessWidget {


  const GroupChatListScreen({super.key});

  void _startCreateGroupFlow(BuildContext context) {
    AppLogger.info("GroupChatListScreen: Navigating to CreateGroupScreen.");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateGroupScreen(),
      ),
    );
  }

    @override
    Widget build(BuildContext context) {
      return GroupChatListContentWidget();
    }
  }
