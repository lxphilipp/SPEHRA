// lib/features/sdg/presentation/screens/sdg_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sdg_list_provider.dart';
import '../widgets/sdg_list_item_widget.dart';
import 'sdg_detail_screen.dart';

class SdgListScreen extends StatelessWidget {
  const SdgListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('The 17 SDGs'),
      ),
      body: Consumer<SdgListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.sdgListItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Text('Error: ${provider.error}',
                  style: TextStyle(color: theme.colorScheme.error)),
            );
          }
          if (provider.sdgListItems.isEmpty) {
            return const Center(child: Text('No SDGs found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180.0,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              mainAxisExtent: 160,
            ),
            itemCount: provider.sdgListItems.length,
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