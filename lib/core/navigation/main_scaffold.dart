import 'package:flutter/material.dart';

// Auth
import 'package:buscadog_v2/core/auth/auth_state.dart';
import 'package:buscadog_v2/features/auth/presentation/login_page.dart';

// Navegación / UI
import 'package:buscadog_v2/core/navigation/nav_item.dart';
import 'package:buscadog_v2/core/navigation/bottom_nav.dart';
import 'package:buscadog_v2/core/navigation/end_drawer_menu.dart';

// Pages (placeholders actuales)
import 'package:buscadog_v2/features/home/presentation/pages/home_page.dart';
import 'package:buscadog_v2/features/search/presentation/pages/search_page.dart';
import 'package:buscadog_v2/features/favorites/presentation/pages/favorites_page.dart';
import 'package:buscadog_v2/features/notifications/presentation/pages/notifications_page.dart';
import 'package:buscadog_v2/features/profile/presentation/pages/profile_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  // Todas las páginas disponibles (algunas se ocultarán si no hay login)
  late final List<Widget> _allPages = const [
    HomePage(), // 0
    SearchPage(), // 1
    FavoritesPage(), // 2 (puede ser pública o privada a tu gusto)
    NotificationsPage(), // 3
    ProfilePage(), // 4 (RESTRINGIDA)
  ];

  // Ítems del menú inferior/drawer (mismo orden que _allPages)
  final List<NavItem> _allItems = const [
    NavItem(label: 'Inicio', icon: Icons.home_outlined, activeIcon: Icons.home),
    NavItem(
      label: 'Buscar',
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
    ),
    NavItem(
      label: 'Favoritos',
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
    ),
    NavItem(
      label: 'Avisos',
      icon: Icons.notifications_none,
      activeIcon: Icons.notifications,
    ),
    NavItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  /// Índices de _allPages/_allItems que requieren sesión
  final Set<int> _restricted = {
    4,
  }; // Perfil (agrega {2,4} si quieres también favoritos privados)

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthState.I,
      builder: (context, _) {
        final isLogged = AuthState.I.isLogged;

        // Determina qué índices mostrar según estado de sesión
        final visibleIdx = <int>[];
        for (var i = 0; i < _allItems.length; i++) {
          if (_restricted.contains(i) && !isLogged) continue;
          visibleIdx.add(i);
        }

        // Mapea listas visibles
        final pages = [for (final i in visibleIdx) _allPages[i]];
        final items = [for (final i in visibleIdx) _allItems[i]];

        // Ajusta índice si quedó fuera de rango por cambios de visibilidad
        if (_index >= pages.length) _index = 0;

        // Título dinámico
        final title =
            (visibleIdx[_index] == 0 && isLogged && AuthState.I.user != null)
            ? 'Hola, ${AuthState.I.user!.name ?? 'Usuario'}'
            : _allItems[visibleIdx[_index]].label;

        // Handler de selección de pestaña con verificación de login
        Future<void> _selectTab(int tapped) async {
          final realIndex = visibleIdx[tapped];
          final needsLogin = _restricted.contains(realIndex) && !isLogged;
          if (needsLogin) {
            final ok = await Navigator.of(
              context,
            ).push<bool>(MaterialPageRoute(builder: (_) => const LoginPage()));
            if (ok == true && mounted)
              setState(() {}); // reconstruye con sesión
            return;
          }
          setState(() => _index = tapped);
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                tooltip: 'Ayuda',
                icon: const Icon(Icons.help_outline),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Menú',
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
          body: IndexedStack(index: _index, children: pages),

          // Barra inferior “pill”
          bottomNavigationBar: AppBottomNav(
            currentIndex: _index,
            onTap: _selectTab,
            items: items,
          ),

          // Drawer derecho (oscuro)
          endDrawer: AppEndDrawer(
            userName: AuthState.I.user?.name ?? 'Invitado',
            items: items,
            currentIndex: _index,
            onSelect: _selectTab,
          ),
          endDrawerEnableOpenDragGesture: true,
        );
      },
    );
  }
}
