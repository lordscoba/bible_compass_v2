import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    bool on(String path) => loc.startsWith(path);

    return BottomAppBar(
      height: 68,
      color: const Color(0xFF0BA37F),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomItem(
            icon: Icons.article_outlined,
            label: 'Categories',
            selected: on('/category'),
            onTap: () => context.go('/category'),
          ),
          const SizedBox(width: 48), // space for center-docked FAB
          _BottomItem(
            icon: Icons.favorite,
            label: 'Favorites',
            selected: on('/favorite'),
            onTap: () => context.go('/favorite'),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = Colors.white;
    final inactive = Colors.white.withOpacity(0.85);

    return InkWell(
      onTap: onTap,
      // Give the cell predictable height and center the column
      child: SizedBox(
        height: 56, // <= fits icon + text comfortably inside a 64px bar
        width: 96, // <= nice tap target; adjust if you prefer
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: selected ? active : inactive),
            const SizedBox(height: 2),
            // If text scale gets big, avoid overflow by fading/ellipsizing
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? active : inactive,
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminBottomBar extends StatelessWidget {
  const AdminBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 50,
      color: const Color(0xFF0BA37F),
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.article_outlined, color: Colors.white),
              onPressed: () {
                context.go('/admin/categories');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.account_box_outlined, color: Colors.white),
              onPressed: () {
                context.go('/admin/users');
              },
            ),
          ),
        ],
      ),
    );
  }
}
