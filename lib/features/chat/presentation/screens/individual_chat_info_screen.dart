import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

// Provider & Entities
import '../providers/individual_chat_provider.dart';
import '../../domain/entities/chat_user_entity.dart';
// import '../../../profile/presentation/screens/user_profile_screen.dart'; // Optional für Profilansicht

class IndividualChatInfoScreen extends StatelessWidget {
  const IndividualChatInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wir verwenden den bestehenden Provider vom Chat-Screen
    final provider = context.watch<IndividualChatProvider>();
    final theme = Theme.of(context);

    // Der ChatPartner sollte immer vorhanden sein, wenn wir hier sind.
    final ChatUserEntity partner = provider.chatPartner;

    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        title: Text(partner.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff040324),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: partner.imageUrl != null ? NetworkImage(partner.imageUrl!) : null,
                child: partner.imageUrl == null
                    ? Text(partner.name.isNotEmpty ? partner.name.substring(0, 1).toUpperCase() : '?', style: const TextStyle(fontSize: 40, color: Colors.white))
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                partner.name,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.white24),

              // --- Aktionen ---
              ListTile(
                leading: const Icon(Iconsax.message_remove, color: Colors.orangeAccent),
                title: const Text("Clear Chat History", style: TextStyle(color: Colors.orangeAccent)),
                onTap: () => _showClearHistoryDialog(context, provider),
              ),
              ListTile(
                leading: const Icon(Iconsax.trash, color: Colors.redAccent),
                title: const Text("Delete Chat", style: TextStyle(color: Colors.redAccent)),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Chat History"),
        content: const Text("This will remove all messages from your view. Your chat partner will not be affected. Are you sure?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Dialog schließen
              await provider.clearHistory();
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chat history cleared."), duration: Duration(seconds: 2))
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Dialog für "Delete Chat"
  void _showDeleteChatDialog(BuildContext context, IndividualChatProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Chat"),
        content: const Text("This will remove the chat from your list. Your chat partner will still see the conversation. Are you sure?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Dialog schließen
              await provider.hideChat(); // Ruft die Methode zum Verstecken auf

              if(context.mounted) {
                // Navigiere aus dem Info-Screen und dem Chat-Screen zurück zur Chat-Liste
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}