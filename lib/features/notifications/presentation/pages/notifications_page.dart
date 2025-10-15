import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'Notificaciones',
      subtitle: 'Aquí verás alertas importantes y novedades.',
      icon: Icons.notifications_none,
    );
  }
}
