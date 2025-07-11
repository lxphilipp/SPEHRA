import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/utils/app_logger.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';
import '../providers/challenge_provider.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/challenge_filter_state.dart';
import 'challenge_card_widget.dart';
import 'challenge_filter_content.dart';

class ChallengeListContent extends StatefulWidget {
  final int? initialTabIndex;
  const ChallengeListContent({super.key, this.initialTabIndex});

  @override
  State<ChallengeListContent> createState() => _ChallengeListContentState();
}

class _ChallengeListContentState extends State<ChallengeListContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.initialTabIndex ?? 0,
      length: 3,
      vsync: this,
    );
    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  void _showAdaptiveFilterDialog(ChallengeProvider provider) async {
    final isMobile = MediaQuery.of(context).size.width < 600;
    ChallengeFilterState? newFilterState;

    if (isMobile) {
      newFilterState = await Navigator.of(context).push<ChallengeFilterState>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => _FilterScreen(initialState: provider.filterState),
        ),
      );
    } else {
      ChallengeFilterState dialogFilterState = provider.filterState;
      newFilterState = await showDialog<ChallengeFilterState>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Challenges filtern"),
          content: SizedBox(
            width: 400,
            child: ChallengeFilterContent(
              initialState: provider.filterState,
              onStateChanged: (newState) => dialogFilterState = newState,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, const ChallengeFilterState()), child: const Text("Zurücksetzen")),
            TextButton(onPressed: () => Navigator.pop(context, dialogFilterState), child: const Text("Anwenden")),
          ],
        ),
      );
    }

    if (newFilterState != null) {
      provider.updateFilter(newFilterState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challengeProvider = context.read<ChallengeProvider>();
    final authProvider = context.read<AuthenticationProvider>();

    if (!authProvider.isLoggedIn) {
      return const Center(child: Text("Bitte einloggen, um Challenges zu sehen."));
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Challenges",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.filter),
                    tooltip: "Filtern",
                    onPressed: () => _showAdaptiveFilterDialog(challengeProvider),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Iconsax.sort),
                    tooltip: "Sortieren nach...",
                    onSelected: (String value) {
                      final parts = value.split('_');
                      final criteria = parts[0];
                      final direction = parts[1];
                      challengeProvider.setSortCriteria(criteria);
                      bool shouldBeAscending = direction == 'asc';
                      if (challengeProvider.isSortAscending != shouldBeAscending) {
                        challengeProvider.setSortCriteria(value);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'createdAt_desc',
                        child: Text('Neueste zuerst'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'createdAt_asc',
                        child: Text('Älteste zuerst'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'points_desc',
                        child: Text('Meiste Punkte'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'points_asc',
                        child: Text('Wenigste Punkte'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'difficulty_asc',
                        child: Text('Einfachste zuerst'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'difficulty_desc',
                        child: Text('Schwerste zuerst'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Discover"),
            Tab(text: "Ongoing"),
            Tab(text: "Completed"),
          ],
        ),

        Expanded(
          child: Consumer<ChallengeProvider>(
            builder: (context, provider, child) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(provider.discoverChallenges, "Keine neuen Challenges gefunden."),
                  _buildListView(provider.ongoingChallenges, "Du hast keine laufenden Challenges."),
                  _buildListView(provider.completedChallenges, "Du hast noch keine Challenges abgeschlossen."),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListView(List<ChallengeEntity> challenges, String emptyMessage) {
    AppLogger.info("Building ListView for ${challenges.length} challenges.");
    if (challenges.isEmpty) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(emptyMessage, textAlign: TextAlign.center),
          ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ChallengeCardWidget(challenge: challenge);
      },
    );
  }
}

class _FilterScreen extends StatefulWidget {
  final ChallengeFilterState initialState;
  const _FilterScreen({required this.initialState});

  @override
  State<_FilterScreen> createState() => __FilterScreenState();
}

class __FilterScreenState extends State<_FilterScreen> {
  late ChallengeFilterState _currentFilterState;

  @override
  void initState() {
    super.initState();
    _currentFilterState = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter & Sort'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_currentFilterState);
            },
            child: const Text('Anwenden'),
          ),
        ],
      ),
      body: ChallengeFilterContent(
        initialState: _currentFilterState,
        onStateChanged: (newState) {
          setState(() {
            _currentFilterState = newState;
          });
        },
      ),
    );
  }
}