import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für Datumsformatierung
import '../../domain/entities/chat_user_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../../../core/utils/app_logger.dart'; // Dein Logger

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

    // Zeitformatierung
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

    // Gelesen-Status
    Widget readStatusIcon = const SizedBox.shrink();
    if (isMe) {
      if (message.readAt != null) {
        readStatusIcon = Icon(Icons.done_all, size: 16);
      } else if (message.createdAt != null) {
        readStatusIcon = Icon(Icons.done, size: 16, color: Colors.grey[500]);
      }
    }

    final messageTextStyle = TextStyle(
      color: isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
      fontSize: 15,
    );
    final timeTextStyle = TextStyle(
      fontSize: 11,
      color: (isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant)?.withOpacity(0.7),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
            color: isMe ? theme.colorScheme.primaryContainer.withOpacity(0.9) : theme.colorScheme.surfaceVariant.withOpacity(0.9),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0,1),) ]
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zeige Absendername, wenn es nicht "ich" bin UND senderDetails vorhanden sind
            if (!isMe && senderDetails != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Text(
                  senderDetails!.name, // Wir wissen, dass es nicht null ist wegen der Bedingung
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary, // Beispiel-Farbe
                  ),
                ),
              ),

            if (message.type == 'text')
              Text(message.msg, style: messageTextStyle),
            if (message.type == 'image' && message.msg.isNotEmpty)
              _buildImageContent(context, message.msg), // isMe wird hier nicht mehr benötigt

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
    return GestureDetector(
      onTap: () {
        AppLogger.debug("ChatMessageItemWidget: Tapped on image: $imageUrl");
        // TODO: Implementiere Vollbild-Bildanzeige
        // z.B. mit Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageUrl: imageUrl)));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vollbildansicht für Bilder ist noch nicht implementiert.")));
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6, // Begrenze die Breite des Bildes
          maxHeight: 300, // Maximale Höhe
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // Abgerundete Ecken für das Bild
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover, // Oder BoxFit.contain, je nach gewünschtem Verhalten
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container( // Platzhalter während des Ladens
                height: 150, // Beispielhöhe
                width: 150,  // Beispielbreite
                color: Colors.grey[800],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white70))),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              AppLogger.error("ChatMessageItemWidget: Error loading image $imageUrl", error, stackTrace);
              return Container(
                height: 150, width: 150,
                color: Colors.grey[800],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white54, size: 40),
                    SizedBox(height: 8),
                    Text("Bildfehler", style: TextStyle(color: Colors.white54, fontSize: 10)),
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