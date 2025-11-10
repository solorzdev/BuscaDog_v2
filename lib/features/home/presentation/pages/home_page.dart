import 'package:flutter/material.dart';

/* ===== Paleta Buscadog ===== */
const kBuscadogBlue = Color(0xFF32BAEA);
const kBuscadogYellow = Color(0xFFFBB03B);
const kBuscadogPurple = Color(0xFF5642BB);
const kBuscadogRed = Color(0xFFE53C49);

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
              const _ServicesStrip(),
              const _Testimonials(),
              const _Stories(),
              const _Footer(),
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
    final t = Theme.of(context).textTheme;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reencuentros\nque cambian vidas',
          style: t.displaySmall?.copyWith(
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Protege a tu mejor amigo con Buscadog',
          style: t.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: kBuscadogYellow,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Lanza una alerta inteligente y activa a tu comunidad.\nMapas, veterinarias y hogares puente en un solo lugar.',
          style: t.bodyLarge?.copyWith(color: Colors.white.withOpacity(.95)),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () {
                // si tienes helper: goToPage(context, 1);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Ir al mapa…')));
              },
              style: FilledButton.styleFrom(
                backgroundColor: kBuscadogPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Buscar ahora'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Opacity(
          opacity: .95,
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                '8,900+ reencuentros logrados',
                style: t.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );

    final right = Padding(
      padding: EdgeInsets.only(top: isWide ? 0 : 24),
      child: Align(
        alignment: isWide ? Alignment.centerRight : Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                offset: const Offset(0, 18),
                color: Colors.black.withOpacity(.18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              'https://images.unsplash.com/photo-1560807707-8cc77767d783?auto=format&fit=crop&w=600&q=80',
              width: isWide ? 460 : 280,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kBuscadogBlue, Color(0xFF22A7D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 20,
        vertical: isWide ? 48 : 28,
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: left),
                const SizedBox(width: 28),
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
    final t = Theme.of(context).textTheme;

    final left = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        'https://images.unsplash.com/photo-1507149833265-60c372daea22?auto=format&fit=crop&w=900&q=80',
        height: isWide ? 420 : 260,
        fit: BoxFit.cover,
      ),
    );

    final stepStyle = t.bodyLarge?.copyWith(fontWeight: FontWeight.w700);
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tres pasos para un reencuentro rápido',
          style: t.headlineSmall?.copyWith(
            color: kBuscadogPurple,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _StepRow(
          number: '1',
          text: 'Crea la alerta con foto y última ubicación.',
          style: stepStyle,
        ),
        _StepRow(
          number: '2',
          text: 'Activa el mapa y notifica a la comunidad.',
          style: stepStyle,
        ),
        _StepRow(
          number: '3',
          text: 'Recibe reportes y guía de veterinarias cercanas.',
          style: stepStyle,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _Pill(text: 'Geolocalización'),
            _Pill(text: 'Difusión'),
            _Pill(text: 'Colaboración'),
          ],
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
        vertical: isWide ? 40 : 26,
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

class _StepRow extends StatelessWidget {
  final String number, text;
  final TextStyle? style;
  const _StepRow({required this.number, required this.text, this.style});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: kBuscadogYellow.withOpacity(.25),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: kBuscadogPurple,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kBuscadogBlue.withOpacity(.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kBuscadogBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value, label;
  const _Metric({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: kBuscadogYellow,
          ),
        ),
        const SizedBox(height: 2),
        Text(label),
      ],
    );
  }
}

/* ===================== SERVICIOS (tira) ===================== */
class _ServicesStrip extends StatelessWidget {
  const _ServicesStrip();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      color: const Color(0xFFF6FBFF),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: const [
          _ServiceChip(
            icon: Icons.local_hospital_rounded,
            label: 'Veterinarias cercanas',
          ),
          _ServiceChip(
            icon: Icons.storefront_rounded,
            label: 'Tiendas de accesorios',
          ),
          _ServiceChip(icon: Icons.home_rounded, label: 'Hogares puente'),
          _ServiceChip(icon: Icons.pets_rounded, label: 'Adopciones'),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ServiceChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(.06),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kBuscadogPurple),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/* ===================== TESTIMONIOS ===================== */
class _Testimonials extends StatelessWidget {
  const _Testimonials();

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        'Javier Ortiz',
        'Aguascalientes',
        '“Mi gato se escondió por días… y lo encontramos con Buscadog.”',
      ),
      (
        'David Romero',
        'Hermosillo',
        '“La alerta geolocalizada ayudó en minutos.”',
      ),
      (
        'Juan C. Pérez',
        'Guadalajara',
        '“La comunidad respondió de inmediato.”',
      ),
    ];

    return Container(
      color: const Color(0xFFF4F6FF),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Center(
        child: Column(
          children: [
            const Text(
              'No estás solo. Estas familias lo consiguieron.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kBuscadogPurple,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (final it in items)
                  SizedBox(
                    width: 340,
                    child: _cardBase(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              it.$1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: kBuscadogPurple,
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
        'https://images.unsplash.com/photo-1601758123927-196ba3c3f88e?auto=format&fit=crop&w=900&q=80',
      ),
      (
        'Chimuelo y su gran amigo Hipo',
        'https://images.unsplash.com/photo-1583511655626-9b2b0c75c8df?auto=format&fit=crop&w=900&q=80',
      ),
      (
        'Sam, el viajero inesperado',
        'https://images.unsplash.com/photo-1557976609-9111c5e4b8df?auto=format&fit=crop&w=900&q=80',
      ),
    ];

    return Container(
      color: const Color(0xFFE9FAFF),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
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
          const SizedBox(height: 16),
          for (final s in stories)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                collapsedBackgroundColor: kBuscadogBlue,
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
                    child: _cardBase(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(s.$2, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Gracias a la red Buscadog, volvieron a casa.',
                          ),
                        ],
                      ),
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

/* ===================== FOOTER ===================== */
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kBuscadogBlue, Color(0xFF22A7D6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        children: const [
          Text(
            'Buscadog – Tecnología y comunidad al servicio de tu peludo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Opacity(
            opacity: .95,
            child: Text(
              '© 2025 Buscadog. Todos los derechos reservados.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Util base ===================== */
Widget _cardBase({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 18,
          offset: const Offset(0, 10),
          color: Colors.black.withOpacity(.06),
        ),
      ],
      border: Border.all(color: const Color(0xFFCBD5E1).withOpacity(.6)),
    ),
    child: child,
  );
}
