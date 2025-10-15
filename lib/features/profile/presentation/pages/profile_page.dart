import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'Perfil',
      subtitle: 'Completa tu información para personalizar tu experiencia.',
      icon: Icons.person_outline,
      // Puedes pasar un botón en `action:` si deseas
    );
  }
}
