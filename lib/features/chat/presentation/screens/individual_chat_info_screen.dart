import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Provider & Entities
import '../providers/individual_chat_provider.dart';
import '../../domain/entities/chat_user_entity.dart';

class IndividualChatInfoScreen extends StatelessWidget {
  const IndividualChatInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IndividualChatProvider>();
    final theme = Theme.of(context);
    final ChatUserEntity partner = provider.chatPartner;

    return Scaffold(
      appBar: AppBar(
        title: Text(partner.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: (partner.imageUrl != null && partner.imageUrl!.isNotEmpty)
                    ? NetworkImage(partner.imageUrl!)
                    : null,
                child: partner.imageUrl == null
                    ? Text(
                  partner.name.isNotEmpty ? partner.name.substring(0, 1).toUpperCase() : '?',
                  style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                partner.name,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 30),
              const Divider(),

              // --- Aktionen ---
              ListTile(
                leading: Icon(Iconsax.message_remove, color: theme.colorScheme.tertiary),
                title: Text("Clear Chat History", style: TextStyle(color: theme.colorScheme.tertiary)),
                onTap: () => _showClearHistoryDialog(context, provider),
              ),
              ListTile(
                leading: Icon(Iconsax.trash, color: theme.colorScheme.error),
                title: Text("Delete Chat", style: TextStyle(color: theme.colorScheme.error)),
                onTap: () => _showDeleteChatDialog(context, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog für "Clear History"
  void _showClearHistoryDialog(BuildContext context, IndividualChatProvider provider) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Chat History"),
        content: const Text("This will remove all messages from your view. Your chat partner will not be affected. Are you sure?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            // OPTIMIERT: Verwendet Fehlerfarbe aus dem Theme
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text("Clear"),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await provider.clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chat history cleared."), duration: Duration(seconds: 2)));
              }
            },
          ),
        ],
      ),
    );
  }

  // Dialog für "Delete Chat"
  void _showDeleteChatDialog(BuildContext context, IndividualChatProvider provider) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Chat"),
        content: const Text("This will remove the chat from your list. Your chat partner will still see the conversation. Are you sure?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await provider.hideChat();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}