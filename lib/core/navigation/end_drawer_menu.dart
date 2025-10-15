import 'package:flutter/material.dart';
import 'package:buscadog_v2/core/navigation/nav_item.dart';
import 'package:buscadog_v2/core/auth/auth_state.dart';
import 'package:buscadog_v2/features/auth/presentation/login_page.dart';

class AppEndDrawer extends StatelessWidget {
  final String userName;
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const AppEndDrawer({
    super.key,
    required this.userName,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final width = (w * 0.82).clamp(320.0, 480.0);
    final scheme = Theme.of(context).colorScheme;
    final isLogged = AuthState.I.isLogged;

    return Drawer(
      width: width,
      child: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF0D1B2A),
              surfaceTintColor: Colors.transparent,
            ),
            listTileTheme: const ListTileThemeData(
              iconColor: Color(0xFF9EC5FF),
              textColor: Colors.white,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        isLogged ? 'Perfil' : 'Invitado',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0x22FFFFFF), height: 24),

              // Acciones generales
              const _DrawerAction(
                icon: Icons.settings_outlined,
                label: 'Configuración',
              ),
              const _DrawerAction(
                icon: Icons.lock_outline,
                label: 'Seguridad y privacidad',
              ),
              const _DrawerAction(
                icon: Icons.support_agent_outlined,
                label: 'Ayuda y soporte',
              ),

              // Login / Logout según estado
              ListTile(
                leading: Icon(
                  isLogged ? Icons.logout : Icons.login,
                  color: isLogged ? scheme.tertiary : const Color(0xFF9EC5FF),
                ),
                title: Text(
                  isLogged ? 'Salir' : 'Iniciar sesión',
                  style: TextStyle(
                    color: isLogged ? scheme.tertiary : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).maybePop();
                  if (isLogged) {
                    await AuthState.I.logout();
                  } else {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DrawerAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {}, // TODO: navega a la sección cuando esté lista
    );
  }
}
