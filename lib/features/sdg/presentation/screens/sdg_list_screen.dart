import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sdg_list_provider.dart';
import '../widgets/sdg_list_item_widget.dart'; // Erstellen wir als Nächstes
import 'sdg_detail_screen.dart'; // Für die Navigation
// Für Theme

class SdgListScreen extends StatelessWidget {
  const SdgListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('The 17 SDGs', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        elevation: theme.appBarTheme.elevation,
      ),
      body: Consumer<SdgListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.sdgListItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}', style: TextStyle(color: theme.colorScheme.error)));
          }
          if (provider.sdgListItems.isEmpty) {
            return const Center(child: Text('No SDGs found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: provider.sdgListItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final sdgItem = provider.sdgListItems[index];
              return SdgListItemWidget(
                sdgItem: sdgItem,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SdgDetailScreen(
                        sdgId: sdgItem.id,
                        initialTitle: sdgItem.title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}