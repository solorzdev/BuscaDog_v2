import 'package:flutter/material.dart';
import 'nav_item.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              blurRadius: 20,
              offset: Offset(0, 12),
              color: Color(0x1A000000),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: scheme.secondaryContainer,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? scheme.primary : const Color(0xFF1B2A4A),
              );
            }),
          ),
          child: NavigationBar(
            height: 64,
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            destinations: items
                .map(
                  (i) => NavigationDestination(
                    icon: Icon(i.icon),
                    selectedIcon: Icon(i.activeIcon ?? i.icon),
                    label: i.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
