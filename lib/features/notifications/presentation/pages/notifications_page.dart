import 'package:flutter/material.dart';

// ===== Paleta Buscadog =====
const kBuscadogBlue = Color(0xFF32BAEA);
const kBuscadogYellow = Color(0xFFFBB03B);
const kBuscadogPurple = Color(0xFF5642BB);
const kBuscadogRed = Color(0xFFE53C49);

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    // 🔹 Datos de ejemplo
    final notifications = <NotificationItem>[
      NotificationItem(
        title: 'Nueva mascota reportada cerca',
        message:
            'Se avistó un perro color beige en Av. Patria, podría coincidir con Luna.',
        timeAgo: 'Hace 10 min',
        color: kBuscadogRed,
        icon: Icons.pets_rounded,
      ),
      NotificationItem(
        title: 'VetCare Roma ofrece descuento',
        message: '10% en vacunas y consultas durante noviembre.',
        timeAgo: 'Hace 3 h',
        color: kBuscadogPurple,
        icon: Icons.local_hospital_rounded,
      ),
      NotificationItem(
        title: 'Actualiza tu perfil',
        message: 'Agrega tu número de contacto para facilitar reencuentros.',
        timeAgo: 'Ayer',
        color: kBuscadogYellow,
        icon: Icons.person_outline_rounded,
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: notifications.isEmpty
          ? const _EmptyNotifications()
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notificaciones',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ...notifications.map((n) => NotificationCard(data: n)),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            // TODO: limpiar notificaciones o refrescar
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Actualizar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ============================================================
// 🟦 MODELO
// ============================================================
class NotificationItem {
  final String title;
  final String message;
  final String timeAgo;
  final Color color;
  final IconData icon;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.color,
    required this.icon,
  });
}

// ============================================================
// 🟨 CARD
// ============================================================
class NotificationCard extends StatelessWidget {
  final NotificationItem data;
  const NotificationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.06),
          ),
        ],
        border: Border.all(color: c.outlineVariant.withOpacity(.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: data.color.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: c.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🟩 ESTADO VACÍO
// ============================================================
class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: kBuscadogBlue,
            ),
            const SizedBox(height: 16),
            Text(
              'Notificaciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: c.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí verás alertas importantes y novedades.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: c.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: abrir configuración o refrescar
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
              style: FilledButton.styleFrom(
                backgroundColor: kBuscadogBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
