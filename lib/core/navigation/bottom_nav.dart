import 'dart:ui';
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
    final color = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // 👈 menos redondeado
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              // Fondo sólido sin borde
              color: color.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 10),
                  color: Color(0x1A000000),
                ),
              ],
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 64,
                backgroundColor: Colors.transparent,
                indicatorColor: color.primary.withOpacity(0.10),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ), // 👈 recto
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? color.onSurface : color.onSurfaceVariant,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    size: 24,
                    color: selected ? color.primary : color.onSurfaceVariant,
                  );
                }),
              ),
              child: NavigationBar(
                elevation: 0,
                selectedIndex: currentIndex,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: [
                  for (final item in items)
                    NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon),
                      label: item.label,
                    ),
                ],
                onDestinationSelected: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
