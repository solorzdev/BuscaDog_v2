import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 1024;
        return ColoredBox(
          color: cs.surface,
          child: ListView(
            children: [
              _HeroSection(isWide: isWide),
              _StepsAndStats(isWide: isWide),
              _Testimonials(),
              _Stories(),
              _CtaBanner(),
              _Footer(),
            ],
          ),
        );
      },
    );
  }
}

/* ===================== HERO ===================== */
class _HeroSection extends StatelessWidget {
  final bool isWide;
  const _HeroSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1EB6DC);
    const purple = Color(0xFF4B3FD6);

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perdida no\nsignifica\nimposible.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 42,
            height: 1.05,
          ),
        ),
        const Text(
          'Volvamos a encontrarnos.',
          style: TextStyle(
            color: purple,
            fontWeight: FontWeight.w900,
            fontSize: 36,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Lanza una alerta inteligente y conecta con vecinos, rescatistas y familias dispuestas a ayudar.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Nombre de tu mascota…',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () => _goSearch(context),
              style: FilledButton.styleFrom(
                backgroundColor: purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              child: const Text('Buscar ahora'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Opacity(
          opacity: .9,
          child: Text(
            '✓ Más de 8,900 reencuentros logrados en México 🇲🇽',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );

    final right = Padding(
      padding: EdgeInsets.only(top: isWide ? 0 : 24),
      child: Align(
        alignment: isWide ? Alignment.centerRight : Alignment.center,
        child: Image.network(
          'https://images.unsplash.com/photo-1560807707-8cc77767d783?auto=format&fit=crop&w=600&q=80',
          width: isWide ? 420 : 260,
          fit: BoxFit.contain,
        ),
      ),
    );

    return Container(
      color: blue,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 20,
        vertical: isWide ? 40 : 24,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: left),
                const SizedBox(width: 24),
                right,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, right],
            ),
    );
  }
}

/* ===================== PASOS + STATS ===================== */
class _StepsAndStats extends StatelessWidget {
  final bool isWide;
  const _StepsAndStats({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final left = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        'https://images.unsplash.com/photo-1507149833265-60c372daea22?auto=format&fit=crop&w=800&q=80',
        height: isWide ? 420 : 260,
        fit: BoxFit.cover,
      ),
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tres pasos para un reencuentro rápido',
          style: TextStyle(
            color: Color(0xFF4B3FD6),
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Creamos una alerta geolocalizada que se difunde en redes sociales y canales locales.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(backgroundColor: Color(0xFFE55555)),
          child: const Text('Ver planes de rescate'),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 40,
          runSpacing: 16,
          children: const [
            _Metric(value: '82+', label: 'Búsquedas activas'),
            _Metric(value: '48+', label: 'Reencuentros hoy'),
          ],
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 20,
        vertical: isWide ? 40 : 24,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: left),
                const SizedBox(width: 32),
                Expanded(child: right),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(height: 16), right],
            ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  const _Metric({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFFF3A521),
          ),
        ),
        const SizedBox(height: 2),
        Text(label),
      ],
    );
  }
}

/* ===================== TESTIMONIOS ===================== */
class _Testimonials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Javier Ortiz', 'Aguascalientes', '“Mi gato se escondió por días…”'),
      ('David Romero', 'Hermosillo', '“Encontramos a nuestro perrito…”'),
      ('Juan Carlos Pérez', 'Guadalajara', '“Gracias a la difusión…”'),
    ];

    return Container(
      color: const Color(0xFFF4EEDF),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Center(
        child: Column(
          children: [
            const Text(
              'No estás solo. Estas familias lo consiguieron.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4B3FD6),
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (final it in items)
                  SizedBox(
                    width: 340,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              it.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4B3FD6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Opacity(opacity: .8, child: Text(it.$2)),
                            const SizedBox(height: 8),
                            Text(it.$3, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== HISTORIAS ===================== */
class _Stories extends StatelessWidget {
  const _Stories();

  @override
  Widget build(BuildContext context) {
    final stories = [
      (
        'El regreso de Linda con Luciana',
        'https://images.unsplash.com/photo-1601758123927-196ba3c3f88e?auto=format&fit=crop&w=800&q=80',
      ),
      (
        'Chimuelo y su gran amigo Hipo',
        'https://images.unsplash.com/photo-1583511655626-9b2b0c75c8df?auto=format&fit=crop&w=800&q=80',
      ),
      (
        'Sam, el viajero inesperado',
        'https://images.unsplash.com/photo-1557976609-9111c5e4b8df?auto=format&fit=crop&w=800&q=80',
      ),
    ];

    return Container(
      color: const Color(0xFFE1F6FA),
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
      child: Column(
        children: [
          const Text(
            'Historias que inspiran',
            style: TextStyle(
              color: Color(0xFF0D2B4F),
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 20),
          for (final s in stories)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                collapsedBackgroundColor: const Color(0xFF1EB6DC),
                backgroundColor: Colors.white,
                title: Text(
                  s.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(s.$2, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gracias a la red de Buscadog, lograron reencontrarse después de varios días.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/* ===================== CTA MORADO ===================== */
class _CtaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF4B3FD6),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Text(
            'Únete a nuestra red de búsqueda y reencuentros',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Explora casos en tiempo real y sé parte de una comunidad que ayuda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => _goSearch(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF3A521),
            ),
            child: const Text('Explorar mapa'),
          ),
        ],
      ),
    );
  }
}

/* ===================== FOOTER ===================== */
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1EB6DC),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        children: const [
          Text(
            'BuscaDog – Conectando corazones, rescatando vidas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Opacity(
            opacity: .9,
            child: Text(
              '© 2025 BuscaDog. Todos los derechos reservados.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Helper ===================== */
void _goSearch(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Ir al mapa… (conecta tu tab)')));
}
