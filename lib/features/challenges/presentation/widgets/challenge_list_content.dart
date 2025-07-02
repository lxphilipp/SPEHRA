import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/utils/app_logger.dart';
import '/core/widgets/expandable_text_widget.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/profile/presentation/providers/user_profile_provider.dart';
import '../providers/challenge_provider.dart';
import '../../domain/entities/challenge_entity.dart';
import 'challenge_card_widget.dart';

class ChallengeListContent extends StatefulWidget {
  final int? initialTabIndex;
  const ChallengeListContent({super.key, this.initialTabIndex});

  @override
  State<ChallengeListContent> createState() => _ChallengeListContentState();
}

class _ChallengeListContentState extends State<ChallengeListContent> {
  int _selectedTab = 0;
  final List<int> _selectedCategoryIndices = [];

  final List<String> _categoryKeys = List.generate(17, (i) => 'goal${i + 1}');
  final List<String> _categoryImagePaths = List.generate(17, (i) => 'assets/icons/17_SDG_Icons/${i + 1}.png');

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex ?? 0;
  }

  Widget _buildCategoryFilterIcon(int index, String imagePath, ThemeData theme) {
    bool isSelected = _selectedCategoryIndices.contains(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategoryIndices.remove(index);
          } else {
            _selectedCategoryIndices.add(index);
          }
        });
      },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildTabOption(BuildContext context, String title, int index, ThemeData theme) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.read<AuthenticationProvider>();
    final userProfileProvider = context.watch<UserProfileProvider>();
    final challengeProvider = context.watch<ChallengeProvider>();

    if (!authProvider.isLoggedIn || userProfileProvider.userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Widget> sdgFilterIcons = List.generate(
      _categoryImagePaths.length,
          (index) => _buildCategoryFilterIcon(index, _categoryImagePaths[index], theme),
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('Challenges', style: theme.appBarTheme.titleTextStyle),
          pinned: true,
          elevation: 0,
          expandedHeight: MediaQuery.of(context).size.height / 3,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(color: theme.scaffoldBackgroundColor),
            titlePadding: const EdgeInsets.only(left: 20, bottom: 60),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore Challenges', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                const SizedBox(width: 250, child: ExpandableTextWidget()),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            minHeight: 70.0,
            maxHeight: 70.0,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: sdgFilterIcons,
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            minHeight: 50.0,
            maxHeight: 50.0,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _buildTabOption(context, "Discover", 0, theme)),
                  Expanded(child: _buildTabOption(context, "Ongoing", 1, theme)),
                  Expanded(child: _buildTabOption(context, "Completed", 2, theme)),
                ],
              ),
            ),
          ),
        ),
        StreamBuilder<List<ChallengeEntity>>(
          // Wir erwarten jetzt eine non-nullable Liste, der Stream im Provider wurde angepasst
          stream: challengeProvider.allChallengesStream,
          builder: (context, snapshot) {
            // 1. Ladezustand explizit prüfen
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            }

            // 2. Fehlerzustand explizit prüfen
            if (snapshot.hasError) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              );
            }

            // 3. Daten-Zustand prüfen (inklusive, ob die Liste leer ist)
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No challenges available yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }

            // 4. Erfolgsfall: Wir wissen, dass snapshot.data nicht null ist.
            final allChallenges = snapshot.data!;

            // --- Die Filterlogik beginnt hier und hat sicheren Zugriff ---
            final ongoingTaskIds = userProfileProvider.userProfile?.ongoingTasks ?? [];
            final completedTaskIds = userProfileProvider.userProfile?.completedTasks ?? [];
            List<ChallengeEntity> challengesToShow;

            if (_selectedTab == 0) { // Discover
              challengesToShow = allChallenges.where((challenge) =>
              !ongoingTaskIds.contains(challenge.id) && !completedTaskIds.contains(challenge.id)
              ).toList();
            } else if (_selectedTab == 1) { // Ongoing
              challengesToShow = allChallenges.where((challenge) => ongoingTaskIds.contains(challenge.id)).toList();
            } else { // Completed
              challengesToShow = allChallenges.where((challenge) => completedTaskIds.contains(challenge.id)).toList();
            }

            if (_selectedCategoryIndices.isNotEmpty) {
              final selectedSdgKeys = _selectedCategoryIndices.map((index) => _categoryKeys[index]).toList();
              challengesToShow = challengesToShow.where((challenge) =>
                  challenge.categories.any((catKey) => selectedSdgKeys.contains(catKey))
              ).toList();
            }

            if (challengesToShow.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No challenges in this category.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final challenge = challengesToShow[index];
                    return ChallengeCardWidget(challenge: challenge);
                  },
                  childCount: challengesToShow.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({ required this.minHeight, required this.maxHeight, required this.child });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: child);
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
}