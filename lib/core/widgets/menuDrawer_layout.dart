import 'package:flutter/material.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '/features/auth/presentation/screens/sign_in_screen.dart';// Für IconData

// Enum für verschiedene Typen von Drawer-Einträgen
enum DrawerItemType { single, expansion }

// Basisklasse für alle Drawer-Einträge
class DrawerItem {
  final String title;
  final IconData? icon; // Optionales Icon
  final DrawerItemType type;

  DrawerItem({
    required this.title,
    this.icon,
    required this.type,
  });
}

// Für einfache klickbare Einträge
class SingleDrawerItem extends DrawerItem {
  final VoidCallback onTap; // Die Aktion, die beim Klicken ausgeführt wird

  SingleDrawerItem({
    required super.title,
    super.icon,
    required this.onTap,
  }) : super(type: DrawerItemType.single);
}

// Für ExpansionTiles mit Unterpunkten
class ExpansionDrawerItem extends DrawerItem {
  final List<SingleDrawerItem> children; // Unterpunkte sind immer SingleDrawerItems

  ExpansionDrawerItem({
    required super.title,
    super.icon,
    required this.children,
  }) : super(type: DrawerItemType.expansion);
}


class MenuDrawerWidget extends StatefulWidget {
  final List<DrawerItem> menuItems;
  // Optional: Callback, um den Drawer nach der Navigation zu schließen
  final VoidCallback? onItemTap;

  const MenuDrawerWidget({
    super.key,
    required this.menuItems,
    this.onItemTap,
  });

  @override
  State<MenuDrawerWidget> createState() => _MenuDrawerWidgetState();
}

class _MenuDrawerWidgetState extends State<MenuDrawerWidget> {
  int? _currentlyExpandedIndex; // Hält den Index des aktuell geöffneten ExpansionTile

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    await authProvider.performSignOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface, // Farbe aus Theme
      child: ListView(
        padding: EdgeInsets.zero, // Kein Padding für ListView im Drawer
        children: <Widget>[
          SizedBox( // Platz für Statusleiste und schönes Aussehen oben
            height: MediaQuery.of(context).padding.top + kToolbarHeight,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1), // Leichter Akzent
              ),
              child: Center(
                child: Text(
                  'MENU', // Oder dein App-Logo/Name
                  style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),
          ...widget.menuItems.asMap().entries.map((entry) { // asMap().entries für Index
            int index = entry.key;
            DrawerItem item = entry.value;

            if (item is ExpansionDrawerItem) {
              return ExpansionTile(
                key: PageStorageKey<String>(item.title), // Für Scroll-Position-Speicherung
                leading: item.icon != null ? Icon(item.icon, color: theme.colorScheme.onSurfaceVariant) : null,
                title: Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _currentlyExpandedIndex == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: _currentlyExpandedIndex == index ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_drop_down,
                  color: _currentlyExpandedIndex == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _currentlyExpandedIndex = expanded ? index : null;
                  });
                },
                initiallyExpanded: _currentlyExpandedIndex == index,
                children: item.children.map((child) {
                  return ListTile(
                    dense: true, // Macht die ListTiles etwas kompakter
                    contentPadding: const EdgeInsets.only(left: 40.0, right: 16.0), // Einrücken
                    leading: child.icon != null ? Icon(child.icon, size: 20, color: theme.colorScheme.onSurfaceVariant) : null,
                    title: Text(
                      child.title,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    onTap: () {
                      child.onTap(); // Führe den Callback aus
                      widget.onItemTap?.call(); // Schließe optional den Drawer
                    },
                  );
                }).toList(),
              );
            } else if (item is SingleDrawerItem) {
              return ListTile(
                leading: item.icon != null ? Icon(item.icon, color: theme.colorScheme.onSurfaceVariant) : null,
                title: Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
                ),
                onTap: () {
                  item.onTap(); // Führe den Callback aus
                  widget.onItemTap?.call();
                },
              );
            }
            return const SizedBox.shrink();
          }),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Logout',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
            ),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}