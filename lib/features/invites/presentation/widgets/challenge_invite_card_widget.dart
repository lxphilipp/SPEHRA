import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../challenges/presentation/providers/challenge_provider.dart';
import '../../domain/entities/invite_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/group_chat_provider.dart'; // Für die Avatare

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

    double maxBonusFactor = 0.0;
    if (balanceConfig != null && balanceConfig.groupChallengeMilestones.isNotEmpty) {
      maxBonusFactor = balanceConfig.groupChallengeMilestones.values.reduce((a, b) => a > b ? a : b);
    }

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
              "NEUE GRUPPEN-CHALLENGE",
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              invite.targetTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.star_1, color: theme.colorScheme.onSecondaryContainer, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    // Zeigt den Bonus an, sobald alle Daten geladen sind
                    (challengeDetails != null && balanceConfig != null)
                        ? "Team Bonus: Up to ${(challengeDetails.calculatePoints(balanceConfig) * maxBonusFactor).round()} extra points each!"
                        : "Calculating team bonus...", // Fallback-Text
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Teilnehmer-Liste ---
            _buildRecipientsList(context, groupProvider),
            const SizedBox(height: 20),

            // --- Aktions-Buttons ---
            if (!hasResponded) // Zeige Buttons nur an, wenn der Nutzer noch nicht reagiert hat
              _buildActionButtons(context),
            if (hasResponded) // Zeige den eigenen Status an, nachdem reagiert wurde
              Center(
                child: Chip(
                  avatar: myStatus == InviteStatus.accepted
                      ? const Icon(Iconsax.tick_circle, color: Colors.green)
                      : const Icon(Iconsax.close_circle, color: Colors.red),
                  label: Text(myStatus == InviteStatus.accepted ? 'Du machst mit!' : 'Du hast abgelehnt'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Baut die Liste der Avatare der Teilnehmer
  Widget _buildRecipientsList(BuildContext context, GroupChatProvider provider) {
    final acceptedUsers = invite.recipients.entries
        .where((entry) => entry.value == InviteStatus.accepted)
        .map((entry) => entry.key)
        .toList();

    if (acceptedUsers.isEmpty) {
      return const Text("Sei der Erste, der mitmacht!");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Dabei sind (${acceptedUsers.length}):"),
        const SizedBox(height: 8),
        Wrap(
          spacing: -8.0, // Lässt die Avatare überlappen
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
            label: const Text("Mitmachen!"),
            onPressed: () {
              provider.acceptChallengeInvite(invite);
            },
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          child: const Text("Ablehnen"),
          onPressed: () {
            provider.declineChallengeInvite(invite);
          },
        ),
      ],
    );
  }
}