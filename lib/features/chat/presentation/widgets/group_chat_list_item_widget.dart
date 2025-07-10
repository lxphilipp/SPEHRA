// lib/features/chat/presentation/widgets/group_chat_list_item_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/group_chat_entity.dart';
import '../../../../core/utils/app_logger.dart';

class GroupChatListItemWidget extends StatelessWidget {
  final GroupChatEntity group;
  final VoidCallback onTap;

  const GroupChatListItemWidget({
    super.key,
    required this.group,
    required this.onTap,
  });

  // NEUE HELFER-FUNKTION FÜR DAS DATUM
  String _formatLastMessageTime(BuildContext context, DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return DateFormat('HH:mm').format(date); // Nur die Zeit für heute
    } else if (dateToCompare == yesterday) {
      return 'Gestern';
    } else {
      // Für ältere Daten nur das Datum
      return DateFormat('dd.MM.yy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppLogger.debug(
        "GroupChatListItemWidget: Building for group ${group.name} (ID: ${group.id})");

    final Widget leadingAvatar;
    if (group.imageUrl != null && group.imageUrl!.isNotEmpty) {
      leadingAvatar = CircleAvatar(
        backgroundImage: NetworkImage(group.imageUrl!),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        radius: 24,
      );
    } else {
      leadingAvatar = CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        radius: 24,
        child: Text(
          group.name.isNotEmpty ? group.name[0].toUpperCase() : "G",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        onTap: onTap,
        leading: leadingAvatar,
        title: Text(
          group.name,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          group.lastMessage ?? "Tippe, um zu chatten...",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        // HIER WIRD DIE NEUE FUNKTION VERWENDET
        trailing: group.lastMessageTime != null
            ? Text(
          _formatLastMessageTime(context, group.lastMessageTime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        )
            : null,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),
    );
  }
}