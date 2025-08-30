import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../challenges/domain/entities/challenge_entity.dart';
import '../../../challenges/domain/entities/game_balance_entity.dart';
import '../../../challenges/presentation/providers/challenge_provider.dart';
import '../../domain/entities/invite_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/group_chat_provider.dart';

class ChallengeInviteCardWidget extends StatelessWidget {
  final InviteEntity invite;

  const ChallengeInviteCardWidget({
    super.key,
    required this.invite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = context.watch<AuthenticationProvider>().currentUserId;
    final groupProvider = context.watch<GroupChatProvider>();
    final challengeProvider = context.watch<ChallengeProvider>();
    final balanceConfig = challengeProvider.gameBalance;
    final myStatus = invite.recipients[currentUserId] ?? InviteStatus.pending;
    final bool hasResponded = myStatus != InviteStatus.pending;
    final challengeDetails = groupProvider.getChallengeDetailsForInvite(invite.targetId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Text(
              "NEW GROUP CHALLENGE",
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              invite.targetTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- NEW, IMPROVED BONUS SECTION ---
            if (challengeDetails != null && balanceConfig != null)
              _buildBonusSection(context, theme, challengeDetails, balanceConfig)
            else
              _buildBonusLoadingIndicator(context, theme),

            const SizedBox(height: 20),

            // --- Participant List ---
            _buildRecipientsList(context, groupProvider),
            const SizedBox(height: 20),

            // --- Action Buttons ---
            if (!hasResponded) // Only show buttons if the user has not responded yet
              _buildActionButtons(context),
            if (hasResponded) // Show the user's status after they have responded
              Center(
                child: Chip(
                  avatar: myStatus == InviteStatus.accepted
                      ? const Icon(Iconsax.tick_circle, color: Colors.green)
                      : const Icon(Iconsax.close_circle, color: Colors.red),
                  label: Text(myStatus == InviteStatus.accepted ? 'You are in!' : 'You declined'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- NEW HELPER WIDGETS ---

  /// Builds the new bonus section that clearly lists the milestones.
  Widget _buildBonusSection(BuildContext context, ThemeData theme, ChallengeEntity challenge, GameBalanceEntity balance) {
    final basePoints = challenge.calculatePoints(balance);
    // Sort milestones by percentage for a logical display
    final milestones = balance.groupChallengeMilestones.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TEAM BONUS",
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Reach milestones to unlock bonus points for everyone:",
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: milestones.map((milestone) {
              final percentage = milestone.key;
              final bonusFactor = milestone.value;
              final bonusPoints = (basePoints * bonusFactor).round();
              return Chip(
                avatar: Icon(Iconsax.award, color: Colors.amber.shade700, size: 16),
                label: Text(
                  "$percentage% = +$bonusPoints Pts",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: theme.colorScheme.surface,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Shows a loading indicator while the bonus info is being calculated.
  Widget _buildBonusLoadingIndicator(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(
            "Calculating team bonus...",
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }

  // Builds the list of participant avatars
  Widget _buildRecipientsList(BuildContext context, GroupChatProvider provider) {
    final acceptedUsers = invite.recipients.entries
        .where((entry) => entry.value == InviteStatus.accepted)
        .map((entry) => entry.key)
        .toList();

    if (acceptedUsers.isEmpty) {
      return const Text("Be the first to join!");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Joined (${acceptedUsers.length}):"),
        const SizedBox(height: 8),
        Wrap(
          spacing: -8.0, // Overlap the avatars
          children: acceptedUsers.map((userId) {
            final userDetails = provider.getMemberDetail(userId);
            return CircleAvatar(
              radius: 16,
              backgroundImage: userDetails?.imageUrl != null ? NetworkImage(userDetails!.imageUrl!) : null,
              child: userDetails?.imageUrl == null
                  ? Text(userDetails?.name.substring(0, 1) ?? "?")
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<GroupChatProvider>();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Iconsax.cup),
            label: const Text("Accept!"),
            onPressed: () {
              provider.acceptChallengeInvite(invite);
            },
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          child: const Text("Decline"),
          onPressed: () {
            provider.declineChallengeInvite(invite);
          },
        ),
      ],
    );
  }
}