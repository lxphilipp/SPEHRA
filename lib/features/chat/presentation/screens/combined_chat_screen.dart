// lib/features/chat/presentation/screens/combined_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/chat_home_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/create_group_screen.dart';
import 'package:flutter_sdg/features/chat/presentation/screens/user_search_screen.dart';
import 'package:flutter_sdg/features/chat/presentation/widgets/chat_list_content_widget.dart';
import 'package:flutter_sdg/features/chat/presentation/widgets/group_chat_list_content_widget.dart';
import '../../../../core/widgets/custom_main_app_bar.dart';

class CombinedChatScreen extends StatefulWidget {
  const CombinedChatScreen({super.key});

  @override
  State<CombinedChatScreen> createState() => _CombinedChatScreenState();
}

class _CombinedChatScreenState extends State<CombinedChatScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFabPressed() {
    if (_tabController.index == 0) {
      // Neuer privater Chat
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserSearchScreen()));
    } else {
      // Neue Gruppe
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateGroupScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomMainAppBar(
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal_1),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserSearchScreen()));
            },
            tooltip: 'Search Users',
          )
        ],
      ),
      body: Column(
        children: [
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
              children: [
                // HINWEIS: Du musst `ChatHomeScreen` und `GroupChatListScreen` so anpassen,
                // dass sie KEIN Scaffold/AppBar mehr zurückgeben, sondern nur noch den Body-Content.
                // Für den Moment nehmen wir die Content-Widgets direkt.
                ChatHomeScreen(),
                const GroupChatListContentWidget(),
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
    );
  }
}