import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für Datumsformatierung

import '../../domain/entities/group_chat_entity.dart';
import '../../../../core/utils/app_logger.dart';

class GroupChatListItemWidget extends StatelessWidget {
  final GroupChatEntity group;
  final VoidCallback onTap; // Callback, wenn auf das Item geklickt wird

  const GroupChatListItemWidget({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppLogger.debug("GroupChatListItemWidget: Building for group ${group.name} (ID: ${group.id})");

    Widget leadingAvatar;
    if (group.imageUrl != null && group.imageUrl!.isNotEmpty) {
      leadingAvatar = CircleAvatar(
        backgroundImage: NetworkImage(group.imageUrl!),
        backgroundColor: theme.colorScheme.surfaceVariant,
        radius: 24, // Etwas größer für Gruppen
        child: null,
      );
    } else {
      leadingAvatar = CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        radius: 24,
        child: Text(
          group.name.isNotEmpty ? group.name[0].toUpperCase() : "G",
          style: TextStyle(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }

    return Card(
      color: Colors.grey[850]?.withOpacity(0.85),
      elevation: 1, // Weniger Elevation für einen flacheren Look
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Angepasster Margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Etwas mehr abgerundet
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // Für den Ripple-Effekt
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Angepasstes Padding
          child: Row(
            children: [
              leadingAvatar,
              const SizedBox(width: 12), // Etwas weniger Abstand
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500, // Medium statt Bold
                        fontSize: 15, // Etwas kleiner
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3), // Weniger Abstand
                    Text(
                      group.lastMessage ?? "Tippe, um zu chatten...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (group.lastMessageTime != null)
                Text(
                  DateFormat('HH:mm').format(group.lastMessageTime!),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11), // Kleinere Zeit
                ),
            ],
          ),
        ),
      ),
    );
  }
}