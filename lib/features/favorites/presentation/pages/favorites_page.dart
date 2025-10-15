import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'Favoritos',
      subtitle: 'Aún no tienes elementos guardados.',
      icon: Icons.favorite_border,
    );
  }
}
