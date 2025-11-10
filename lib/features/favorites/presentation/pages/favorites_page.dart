import 'package:flutter/material.dart';

// ===== Paleta Buscadog =====
const kBuscadogBlue = Color(0xFF32BAEA);
const kBuscadogYellow = Color(0xFFFBB03B);
const kBuscadogPurple = Color(0xFF5642BB);
const kBuscadogRed = Color(0xFFE53C49);

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    // 🔹 DEMO DATA (conecta a tu backend cuando lo tengas)
    final pets = <PetFavorite>[
      PetFavorite(name: 'Luna', breed: 'Mestiza', age: '2 años'),
      PetFavorite(name: 'Max', breed: 'Labrador', age: '1 año'),
      PetFavorite(name: 'Copito', breed: 'Poodle', age: '4 años'),
    ];

    final vets = <VetFavorite>[
      VetFavorite(
        name: 'VetCare Roma',
        distanceKm: 1.2,
        rating: 4.7,
        openNow: true,
      ),
      VetFavorite(
        name: 'Clínica Canina Norte',
        distanceKm: 3.4,
        rating: 4.5,
        openNow: false,
      ),
    ];

    final saved = <SavedItem>[
      SavedItem(
        title: 'Hogar puente “Patitas”',
        tag: 'Refugio',
        color: kBuscadogPurple,
      ),
      SavedItem(
        title: 'Croquetas Digestive 10kg',
        tag: 'Alimento',
        color: kBuscadogYellow,
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'Mascotas favoritas',
                  color: kBuscadogBlue,
                  icon: Icons.pets_rounded,
                ),
                const SizedBox(height: 8),
                _ResponsiveWrap(
                  children: pets
                      .map(
                        (p) => FavoritePetCard(
                          data: p,
                          onView: () {
                            /* TODO: ver perfil */
                          },
                          onUnfavorite: () {
                            /* TODO: quitar favorito */
                          },
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Veterinarias favoritas',
                  color: kBuscadogPurple,
                  icon: Icons.local_hospital_rounded,
                ),
                const SizedBox(height: 8),
                _ResponsiveWrap(
                  children: vets
                      .map(
                        (v) => FavoriteVetCard(
                          data: v,
                          onCall: () {
                            /* TODO: llamar */
                          },
                          onRoute: () {
                            /* TODO: abrir mapa */
                          },
                          onUnfavorite: () {
                            /* TODO: quitar favorito */
                          },
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Otros guardados',
                  color: kBuscadogYellow,
                  icon: Icons.bookmark_rounded,
                ),
                const SizedBox(height: 8),
                _ResponsiveWrap(
                  children: saved
                      .map(
                        (s) => SavedItemCard(
                          data: s,
                          onOpen: () {
                            /* TODO: abrir detalle */
                          },
                          onRemove: () {
                            /* TODO: quitar guardado */
                          },
                        ),
                      )
                      .toList(),
                ),

                // Estado vacío total (si todo está vacío)
                if (pets.isEmpty && vets.isEmpty && saved.isEmpty) ...[
                  const SizedBox(height: 40),
                  _EmptyHint(color: c),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== MODELOS DEMO ====================
class PetFavorite {
  final String name;
  final String breed;
  final String age;
  final String? photoUrl;
  const PetFavorite({
    required this.name,
    required this.breed,
    required this.age,
    this.photoUrl,
  });
}

class VetFavorite {
  final String name;
  final double distanceKm;
  final double rating;
  final bool openNow;
  const VetFavorite({
    required this.name,
    required this.distanceKm,
    required this.rating,
    required this.openNow,
  });
}

class SavedItem {
  final String title;
  final String tag;
  final Color color;
  const SavedItem({
    required this.title,
    required this.tag,
    required this.color,
  });
}

// ==================== WIDGETS ====================
class FavoritePetCard extends StatelessWidget {
  final PetFavorite data;
  final VoidCallback onView;
  final VoidCallback onUnfavorite;
  const FavoritePetCard({
    super.key,
    required this.data,
    required this.onView,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return _CardBase(
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBuscadogBlue.withOpacity(.12),
            ),
            child: data.photoUrl == null
                ? const Icon(Icons.pets_rounded, size: 36, color: kBuscadogBlue)
                : ClipOval(
                    child: Image.network(data.photoUrl!, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.breed} · ${data.age}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: c.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _Chip(
                      text: 'Esterilizada',
                      color: kBuscadogBlue.withOpacity(.15),
                      fg: kBuscadogBlue,
                    ),
                    _Chip(
                      text: 'Con placa QR',
                      color: kBuscadogPurple.withOpacity(.15),
                      fg: kBuscadogPurple,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Acciones
          Column(
            children: [
              IconButton(
                tooltip: 'Quitar de favoritos',
                onPressed: onUnfavorite,
                icon: const Icon(Icons.favorite_rounded, color: kBuscadogRed),
              ),
              OutlinedButton(onPressed: onView, child: const Text('Ver')),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoriteVetCard extends StatelessWidget {
  final VetFavorite data;
  final VoidCallback onCall;
  final VoidCallback onRoute;
  final VoidCallback onUnfavorite;
  const FavoriteVetCard({
    super.key,
    required this.data,
    required this.onCall,
    required this.onRoute,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return _CardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icono clínica
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kBuscadogPurple.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: kBuscadogPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: c.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${data.distanceKm.toStringAsFixed(1)} km',
                          style: t.bodySmall?.copyWith(
                            color: c.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: kBuscadogYellow,
                        ),
                        const SizedBox(width: 2),
                        Text('${data.rating}', style: t.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              _OpenBadge(open: data.openNow),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.call_rounded, size: 18),
                label: const Text('Llamar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed:
                    onRoute, // aquí luego puedes usar goToPage(context, 1)
                icon: const Icon(Icons.route_rounded, size: 18),
                label: const Text('Cómo llegar'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Quitar de favoritos',
                onPressed: onUnfavorite,
                icon: const Icon(Icons.favorite_rounded, color: kBuscadogRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SavedItemCard extends StatelessWidget {
  final SavedItem data;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  const SavedItemCard({
    super.key,
    required this.data,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return _CardBase(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bookmark_rounded, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  data.tag,
                  style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                ),
              ],
            ),
          ),
          OutlinedButton(onPressed: onOpen, child: const Text('Abrir')),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

// ==================== PIEZAS BASE ====================
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  const _SectionHeader({
    required this.title,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 10),
        Text(title, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _CardBase extends StatelessWidget {
  final Widget child;
  const _CardBase({required this.child});

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
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color fg;
  const _Chip({required this.text, required this.color, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool open;
  const _OpenBadge({required this.open});

  @override
  Widget build(BuildContext context) {
    final text = open ? 'Abierto' : 'Cerrado';
    final color = open ? Colors.green : kBuscadogRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            open ? Icons.schedule_rounded : Icons.schedule_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Distribución responsiva tipo "wrap" (1–3 columnas según ancho)
class _ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  const _ResponsiveWrap({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // breakpoints simples
        final colWidth = w >= 860
            ? (w - 32) / 3
            : w >= 580
            ? (w - 16) / 2
            : w; // 1 columna en móvil

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children
              .map((e) => SizedBox(width: colWidth, child: e))
              .toList(),
        );
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final ColorScheme color;
  const _EmptyHint({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.favorite_border, size: 80, color: color.primary),
          const SizedBox(height: 8),
          Text(
            'Aún no tienes elementos guardados.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              /* TODO: goToPage(context, 1) para mapa */
            },
            icon: const Icon(Icons.search_rounded),
            label: const Text('Explorar'),
          ),
        ],
      ),
    );
  }
}
