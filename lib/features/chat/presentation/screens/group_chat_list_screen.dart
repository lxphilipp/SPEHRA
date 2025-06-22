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
        // Hier wird deine gut vorbereitete CreateGroupScreen aufgerufen!
        builder: (_) => const CreateGroupScreen(),
      ),
    );
  }

    @override
    Widget build(BuildContext context) {
      AppLogger.debug("GroupChatListScreen: Building.");
      // Der GroupChatListProvider wird bereits in main.dart global bereitgestellt
      // oder im übergeordneten ChatMainTabsScreen, falls dieser existiert und Provider bereitstellt.
      // Für den Moment gehen wir davon aus, dass er im Kontext verfügbar ist.

      return Scaffold(
        backgroundColor: const Color(0xff040324),
        appBar: AppBar(
          backgroundColor: const Color(0xff040324),
          title: const Text(
              'Gruppenchats', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.group_add_outlined, color: Colors.white),
              onPressed: () => _startCreateGroupFlow(context),
              tooltip: "Neue Gruppe erstellen",
            ),
          ],
        ),
        body: const GroupChatListContentWidget(),
      );
    }
  }
