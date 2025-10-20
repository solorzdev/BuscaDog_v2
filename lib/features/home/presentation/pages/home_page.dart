import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido! 🐾',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Accede rápido desde el menú inferior o abre el panel de la derecha para más opciones.',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search),
                label: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
