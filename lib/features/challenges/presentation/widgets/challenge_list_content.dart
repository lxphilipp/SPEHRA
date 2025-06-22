import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/utils/app_logger.dart';
import '/core/widgets/expandable_text_widget.dart';
// Für Theme-Zugriff
import '/core/theme/sdg_color_theme.dart';
import '/features/auth/presentation/providers/auth_provider.dart'; // Für isLoggedIn Check
import '/features/profile/presentation/providers/user_profile_provider.dart';
import '../providers/challenge_provider.dart';
import '../../domain/entities/challenge_entity.dart';
import 'challenge_card_widget.dart'; // Das neue Widget für eine Kachel

class ChallengeListContent extends StatefulWidget {
  final int? initialTabIndex;
  const ChallengeListContent({super.key, this.initialTabIndex});

  @override
  State<ChallengeListContent> createState() => _ChallengeListContentState();
}

class _ChallengeListContentState extends State<ChallengeListContent> {
  int _selectedTab = 0;
  final List<int> _selectedCategoryIndices = []; // Indizes der ausgewählten SDG-Icons

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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Mehr Padding
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              width: 3, // Etwas dicker für bessere Sichtbarkeit
            ),
          ),
        ),
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith( // Angepasster Textstil
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
    final sdgTheme = theme.extension<SdgColorTheme>();

    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false); // listen:false, wenn nur für Aktionen
    final userProfileProvider = Provider.of<UserProfileProvider>(context); // listen:true für Task-Listen
    final challengeProvider = Provider.of<ChallengeProvider>(context); // listen:true für Challenge-Stream

    if (!authProvider.isLoggedIn || userProfileProvider.userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Widget> sdgFilterIcons = List.generate(_categoryImagePaths.length, (index) =>
        _buildCategoryFilterIcon(index, _categoryImagePaths[index], theme)
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('Challenges', style: theme.appBarTheme.titleTextStyle),
          backgroundColor: theme.appBarTheme.backgroundColor,
          iconTheme: theme.appBarTheme.iconTheme,
          pinned: true,
          elevation: 0,
          expandedHeight: MediaQuery.of(context).size.height / 3, // Höhe anpassbar
          flexibleSpace: FlexibleSpaceBar(
            // Dein Header-Design hier
            background: Container(color: theme.scaffoldBackgroundColor), // Fallback
            // ... (Gradienten, Bilder etc. wie in deinem alten Design)
            titlePadding: const EdgeInsets.only(left: 20, bottom: 60), // Titel weiter unten
            title: Column( // Verwende Column für Titel und ExpandableText
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Challenges',
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                const SizedBox(width: 250, child: ExpandableTextWidget()), // Max Breite für Text
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            minHeight: 70.0, // Höhe für die SDG Icons
            maxHeight: 70.0,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical:10),
                children: sdgFilterIcons,
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            minHeight: 50.0, // Höhe für Tabs
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
        StreamBuilder<List<ChallengeEntity>?>(
          stream: challengeProvider.allChallengesStream,
          builder: (context, snapshot) {
            AppLogger.info("ChallengeList: StreamBuilder called - ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, Error: ${snapshot.error}");
            
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              AppLogger.info("ChallengeList: Showing loading indicator");
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              AppLogger.error("ChallengeList: Error in stream: ${snapshot.error}");
              return SliverFillRemaining(child: Center(child: Text('Error loading challenges: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error))));
            }
            final allChallenges = snapshot.data ?? [];
            AppLogger.info("ChallengeList: Received ${allChallenges.length} challenges from stream");
            
            if (allChallenges.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
              AppLogger.warning("ChallengeList: No challenges found and not waiting for data");
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No challenges available yet.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant), // KORRIGIERT
                  ),
                ),
              );
            }


            List<ChallengeEntity> challengesToShow = [];
            final ongoingTaskIds = userProfileProvider.userProfile?.ongoingTasks ?? [];
            final completedTaskIds = userProfileProvider.userProfile?.completedTasks ?? [];
            
            AppLogger.debug("ChallengeList: User has ${ongoingTaskIds.length} ongoing tasks and ${completedTaskIds.length} completed tasks");
            AppLogger.debug("ChallengeList: Selected tab: $_selectedTab, Category filters: $_selectedCategoryIndices");

            if (_selectedTab == 0) { // Discover
              challengesToShow = allChallenges.where((challenge) =>
              !ongoingTaskIds.contains(challenge.id) &&
                  !completedTaskIds.contains(challenge.id)).toList();
              AppLogger.info("ChallengeList: Discover tab - Filtered to ${challengesToShow.length} challenges");
            } else if (_selectedTab == 1) { // Ongoing
              challengesToShow = allChallenges.where((challenge) =>
                  ongoingTaskIds.contains(challenge.id)).toList();
              AppLogger.info("ChallengeList: Ongoing tab - Filtered to ${challengesToShow.length} challenges");
            } else if (_selectedTab == 2) { // Completed
              challengesToShow = allChallenges.where((challenge) =>
                  completedTaskIds.contains(challenge.id)).toList();
              AppLogger.info("ChallengeList: Completed tab - Filtered to ${challengesToShow.length} challenges");
            }

            if (_selectedCategoryIndices.isNotEmpty) {
              List<String> selectedSdgKeys = _selectedCategoryIndices.map((index) => _categoryKeys[index]).toList();
              int beforeCategoryFilter = challengesToShow.length;
              challengesToShow = challengesToShow.where((challenge) =>
                  challenge.categories.any((catKey) => selectedSdgKeys.contains(catKey))).toList();
              AppLogger.debug("ChallengeList: Category filter applied - $beforeCategoryFilter -> ${challengesToShow.length} challenges");
            }

            AppLogger.info("ChallengeList: Final display - Showing ${challengesToShow.length} challenges");
            if (challengesToShow.isNotEmpty) {
              AppLogger.debug("ChallengeList: Challenge titles to display: ${challengesToShow.map((c) => c.title).join(', ')}");
            }
            
            return SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final challenge = challengesToShow[index];
                    return ChallengeCardWidget(challenge: challenge, sdgTheme: sdgTheme);
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

// Hilfsklasse für SliverPersistentHeader (unverändert)
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