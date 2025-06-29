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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppLogger.debug("GroupChatListItemWidget: Building for group ${group.name} (ID: ${group.id})");

    final Widget leadingAvatar;
    if (group.imageUrl != null && group.imageUrl!.isNotEmpty) {
      leadingAvatar = CircleAvatar(
        backgroundImage: NetworkImage(group.imageUrl!),
        backgroundColor: theme.colorScheme.surfaceVariant,
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

    // OPTIMIERT: Die Card nutzt jetzt das CardTheme und das Kind ist ein ListTile.
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        onTap: onTap,
        leading: leadingAvatar,
        title: Text(
          group.name,
          // OPTIMIERT: Textstil aus dem Theme
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          group.lastMessage ?? "Tippe, um zu chatten...",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // OPTIMIERT: Textstil mit semantischer Farbe aus dem Theme
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: group.lastMessageTime != null
            ? Text(
          DateFormat('HH:mm').format(group.lastMessageTime!),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),
    );
  }
}