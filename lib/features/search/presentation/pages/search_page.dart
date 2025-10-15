import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'Buscar',
      subtitle: 'Pronto podrás filtrar por zona, especie y estado.',
      icon: Icons.search,
    );
  }
}
