import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/utils/app_logger.dart';
import '../screens/challenge_details_screen.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '../providers/challenge_provider.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/challenge_filter_state.dart';
import 'challenge_card_widget.dart';
import 'challenge_filter_content.dart';

class ChallengeListContent extends StatefulWidget {
  final int? initialTabIndex;
  final bool isSelectionMode;

  const ChallengeListContent({
    super.key, this.initialTabIndex,
    this.isSelectionMode = false,
  });

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
          title: const Text("Filter Challenges"),
          content: SizedBox(
            width: 400,
            child: ChallengeFilterContent(
              initialState: provider.filterState,
              onStateChanged: (newState) => dialogFilterState = newState,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, const ChallengeFilterState()), child: const Text("Reset")),
            TextButton(onPressed: () => Navigator.pop(context, dialogFilterState), child: const Text("Apply")),
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
      return const Center(child: Text("Please log in to see challenges."));
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
                    tooltip: "Filter",
                    onPressed: () => _showAdaptiveFilterDialog(challengeProvider),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Iconsax.sort),
                    tooltip: "Sort by...",
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
                        child: Text('Newest first'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'createdAt_asc',
                        child: Text('Oldest first'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'points_desc',
                        child: Text('Most points'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'points_asc',
                        child: Text('Fewest points'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'difficulty_asc',
                        child: Text('Easiest first'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'difficulty_desc',
                        child: Text('Hardest first'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        if (!widget.isSelectionMode)
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
              if (widget.isSelectionMode) {
                return _buildListView(provider.discoverChallenges, "No challenges found for selection.");
              }
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(provider.discoverChallenges, "No new challenges found."),
                  _buildListView(provider.ongoingChallenges, "You have no ongoing challenges."),
                  _buildListView(provider.completedChallenges, "You have not completed any challenges yet."),
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
        return ChallengeCardWidget(
          challenge: challenge,
          onTap: () {
            if (widget.isSelectionMode) {
              Navigator.of(context).pop(challenge.id);
            } else {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ChallengeDetailsScreen(challengeId: challenge.id),
              ));
            }
          },
        );
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
            child: const Text('Apply'),
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