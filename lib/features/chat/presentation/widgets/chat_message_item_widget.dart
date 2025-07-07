import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/entities/message_entity.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String formattedTime = '';
    if (message.createdAt != null) {
      final now = DateTime.now();
      final msgDate = message.createdAt!;
      if (now.year == msgDate.year && now.month == msgDate.month && now.day == msgDate.day) {
        formattedTime = DateFormat('HH:mm').format(msgDate);
      } else {
        formattedTime = DateFormat('dd.MM HH:mm').format(msgDate);
      }
    }

    Widget readStatusIcon = const SizedBox.shrink();
    if (isMe) {
      if (message.readAt != null) {
        readStatusIcon = Icon(Icons.done_all, size: 16, color: colorScheme.primary);
      } else if (message.createdAt != null) {
        readStatusIcon = Icon(Icons.done, size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.6));
      }
    }

    final messageTextStyle = theme.textTheme.bodyLarge?.copyWith(
      color: isMe ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
    );
    final timeTextStyle = theme.textTheme.bodySmall?.copyWith(
      color: (isMe ? colorScheme.onPrimaryContainer : colorScheme.onSurface).withOpacity(0.8),
    );

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
          boxShadow: [
            BoxShadow(
              // OPTIMIERT: Verwendet die Schattenfarbe aus dem Theme
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ],
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
                    color: colorScheme.secondary, // Beispiel für eine Akzentfarbe
                  ),
                ),
              ),
            if (message.type == 'text')
              Text(message.msg, style: messageTextStyle),
            if (message.type == 'image' && message.msg.isNotEmpty)
              _buildImageContent(context, message.msg),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(formattedTime, style: timeTextStyle),
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
        // Vollbildansicht-Logik
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
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                    Icon(Icons.broken_image, color: theme.colorScheme.onSurfaceVariant, size: 40),
                    const SizedBox(height: 8),
                    Text("Image error", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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