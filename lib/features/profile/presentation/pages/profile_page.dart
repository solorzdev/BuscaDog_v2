import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/auth/auth_state.dart'; // <- tu estado de auth
import '../../../profile/data/profile_api.dart';
import 'profile_edit_page.dart';

const String _apiBase = 'http://10.0.2.2:8080/api/v1';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool loading = true;
  ProfileApi? api;

  // Ajusta para dispositivo físico si lo usas:
  // - Emulador Android: 10.0.2.2
  // - Dispositivo físico en misma red: IP de tu PC, ej. 192.168.1.10
  // static const String _apiBase = 'http://10.0.2.2:8080/api/v1';

  String _normalizeAvatarUrl(String? raw) {
    if (raw == null) return '';
    final u = raw.trim();
    if (u.isEmpty) return '';
    if (u.startsWith('http://') || u.startsWith('https://'))
      return u; // ya absoluta
    const base = 'http://10.0.2.2:8080'; // solo si alguna vez viniera relativa
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = u.startsWith('/') ? u : '/$u';
    return '$b$p';
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1) Necesitamos token
    final token = AuthState.I.token; // asegúrate que ya existe tras login
    if (token == null || token.isEmpty) {
      setState(() => loading = false);
      return;
    }
    // api = ProfileApi(Dio(), baseUrl: _apiBase, jwt: token);

    final dio = Dio(
      BaseOptions(
        baseUrl: _apiBase,
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    api = ProfileApi(dio, baseUrl: _apiBase, jwt: token);

    // 2) Cargar perfil
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (api == null) {
      setState(() => loading = false);
      return;
    }
    try {
      final u = await api!.me();
      setState(() {
        user = u;
        loading = false;
      });
    } catch (e) {
      // Si falla (401/connection refused), lo mostramos y dejamos editar
      debugPrint('Error al cargar perfil: $e');
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el perfil.')),
      );
    }
  }

  Future<void> _goToEdit() async {
    if (api == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para editar tu perfil.')),
      );
      return;
    }
    // Si no hay datos, manda un mapa vacío y que el form se inicialice en blanco
    final initial = user ?? <String, dynamic>{};
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditPage(api: api!, user: initial),
      ),
    );
    if (updated != null) {
      setState(() => user = updated as Map<String, dynamic>);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ======= Sin sesión =======
    if (AuthState.I.token == null || AuthState.I.token!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: AppEmptyState(
          title: 'No has iniciado sesión',
          subtitle: 'Inicia sesión para poder ver y editar tu perfil.',
          icon: Icons.lock_outline,
          action: ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Iniciar sesión'),
            onPressed: () {
              // Navega a tu flujo de login
              Navigator.of(context).pushNamed('/login');
            },
          ),
        ),
      );
    }

    // ======= Cargando =======
    if (loading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    // ======= Con sesión, sin datos (primera vez) =======
    if (user == null) {
      return Scaffold(
        body: AppEmptyState(
          title: 'Perfil',
          subtitle:
              'Aún no has completado tu información. Puedes editarla ahora.',
          icon: Icons.person_outline,
          action: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Completar perfil'),
            onPressed: _goToEdit,
          ),
        ),
      );
    }

    // ======= Con datos =======
    final String avatar = (user?['avatar_url'] as String?)?.trim() ?? '';
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Antes del CircleAvatar:
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: avatar.isNotEmpty
                    ? CachedNetworkImageProvider(
                        avatar,
                      ) // URL absoluta del backend
                    : null,
                child: avatar.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),

              const SizedBox(height: 12),
              Text(
                user!['nombre_mostrar'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user!['correo'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _infoCard(
                title: "Información personal",
                items: {
                  "Nombre": user!['nombre'] ?? '-',
                  "Apellidos": user!['apellidos'] ?? '-',
                  "Teléfono": user!['telefono'] ?? '-',
                  "WhatsApp": user!['whatsapp'] ?? '-',
                },
              ),
              const SizedBox(height: 12),
              _infoCard(
                title: "Dirección",
                items: {
                  "Calle": user!['calle'] ?? '-',
                  "Colonia": user!['colonia'] ?? '-',
                  "Municipio": user!['municipio'] ?? '-',
                  "Estado": user!['estado'] ?? '-',
                  "Código postal": user!['codigo_postal'] ?? '-',
                },
              ),
              ElevatedButton.icon(
                onPressed: _goToEdit,
                icon: const Icon(Icons.edit),
                label: const Text("Editar perfil"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required Map<String, String> items,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(color: Colors.grey)),
                    Flexible(
                      child: Text(
                        e.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
