import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../challenges/presentation/widgets/group_challenge_status_card.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../providers/group_chat_provider.dart';

class ChatMessageItemWidget extends StatelessWidget {
  final MessageEntity message;
  final ChatUserEntity? senderDetails;
  final bool isMe;

  const ChatMessageItemWidget({
    super.key,
    required this.message,
    required this.isMe,
    this.senderDetails,
  });

  // This helper method shows the detailed progress view in a bottom sheet.
  void _showChallengeProgress(BuildContext context) {
    final groupProvider = context.read<GroupChatProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: groupProvider,
          child: DraggableScrollableSheet(
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Consumer<GroupChatProvider>(
                  builder: (context, provider, child) {
                    final activeChallenges = provider.activeChallenges;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: activeChallenges.length,
                      itemBuilder: (ctx, index) {
                        final progress = activeChallenges[index];
                        final details = provider.getChallengeDetailsForActiveChallenge(progress.challengeId);
                        return GroupChallengeStatusCard(
                          groupProgress: progress,
                          challengeDetails: details,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Central switch for message type rendering ---
    // This is the cleanest way to handle different message types.
    switch (message.type) {
      case MessageType.text:
      case MessageType.image:
        return _buildUserMessageBubble(context);

      case MessageType.progressUpdate:
        return _buildProgressUpdateWidget(context);

      case MessageType.milestoneUnlocked:
        return _buildMilestoneWidget(context);
    }
  }

  // --- WIDGET BUILDERS FOR EACH MESSAGE TYPE ---

  /// Builds the celebratory widget for milestone events.
  Widget _buildMilestoneWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade600,
            Colors.orange.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.award, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.msg,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the small, informational widget for progress updates.
  Widget _buildProgressUpdateWidget(BuildContext context) {
    final theme = Theme.of(context);
    RegExp regExp = RegExp(r'\[(.*?)\]');
    Match? match = regExp.firstMatch(message.msg);
    String preText = message.msg;
    String linkText = '';

    if (match != null) {
      preText = message.msg.substring(0, match.start);
      linkText = match.group(0)!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      alignment: Alignment.center,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          children: [
            TextSpan(text: preText),
            if (match != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: InkWell(
                  onTap: () => _showChallengeProgress(context),
                  child: Text(
                    linkText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the standard message bubble for user-sent text and images.
  Widget _buildUserMessageBubble(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String formattedTime = '';
    if (message.createdAt != null) {
      formattedTime = DateFormat('HH:mm').format(message.createdAt!);
    }

    Widget readStatusIcon = const SizedBox.shrink();
    if (isMe) {
      if (message.readAt != null) {
        readStatusIcon = Icon(Icons.done_all, size: 16, color: colorScheme.primary);
      } else if (message.createdAt != null) {
        readStatusIcon = Icon(Icons.done, size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.6));
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe && senderDetails != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  senderDetails!.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            if (message.type == MessageType.text)
              Text(message.msg, style: theme.textTheme.bodyLarge?.copyWith(
                color: isMe ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
              )),
            if (message.type == MessageType.image && message.msg.isNotEmpty)
              _buildImageContent(context, message.msg),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formattedTime,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: (isMe ? colorScheme.onPrimaryContainer : colorScheme.onSurface).withOpacity(0.8),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 5),
                  readStatusIcon,
                ],
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context, String imageUrl) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        // Full screen view logic can be added here
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
          maxHeight: 300,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 150,
                width: 150,
                color: theme.colorScheme.surfaceContainer,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                width: 150,
                color: theme.colorScheme.surfaceContainer,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image,
                        color: theme.colorScheme.onSurfaceVariant, size: 40),
                    const SizedBox(height: 8),
                    Text("Image error",
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}