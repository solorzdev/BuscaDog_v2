import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../profile/data/profile_api.dart';
import '../widgets/avatar_picker.dart';

class ProfileEditPage extends StatefulWidget {
  final ProfileApi api;
  final Map<String, dynamic> user;
  const ProfileEditPage({super.key, required this.api, required this.user});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController nombreCtrl;
  late final TextEditingController nombreMostrarCtrl;
  late final TextEditingController apellidosCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController telefonoCtrl;
  late final TextEditingController whatsappCtrl;
  late final TextEditingController calleCtrl;
  late final TextEditingController coloniaCtrl;
  late final TextEditingController municipioCtrl;
  late final TextEditingController estadoCtrl;
  late final TextEditingController codigoPostalCtrl;

  String? avatarUrl;
  bool _dirty = false;
  bool _loading = false;
  bool _sameWhatsapp = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;

    nombreCtrl = TextEditingController(text: u['nombre'] ?? '');
    nombreMostrarCtrl = TextEditingController(text: u['nombre_mostrar'] ?? '');
    apellidosCtrl = TextEditingController(text: u['apellidos'] ?? '');
    emailCtrl = TextEditingController(text: u['email'] ?? u['correo'] ?? '');
    telefonoCtrl = TextEditingController(text: u['telefono'] ?? '');
    whatsappCtrl = TextEditingController(text: u['whatsapp'] ?? '');
    calleCtrl = TextEditingController(text: u['calle'] ?? '');
    coloniaCtrl = TextEditingController(text: u['colonia'] ?? '');
    municipioCtrl = TextEditingController(text: u['municipio'] ?? '');
    estadoCtrl = TextEditingController(text: u['estado'] ?? '');
    codigoPostalCtrl = TextEditingController(text: u['codigo_postal'] ?? '');
    avatarUrl = u['avatar_url'];

    _sameWhatsapp =
        (telefonoCtrl.text.isNotEmpty &&
        telefonoCtrl.text == whatsappCtrl.text);

    for (final c in [
      nombreCtrl,
      nombreMostrarCtrl,
      apellidosCtrl,
      emailCtrl,
      telefonoCtrl,
      whatsappCtrl,
      calleCtrl,
      coloniaCtrl,
      municipioCtrl,
      estadoCtrl,
      codigoPostalCtrl,
    ]) {
      c.addListener(() {
        if (!_dirty) setState(() => _dirty = true);
      });
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    nombreMostrarCtrl.dispose();
    apellidosCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();
    whatsappCtrl.dispose();
    calleCtrl.dispose();
    coloniaCtrl.dispose();
    municipioCtrl.dispose();
    estadoCtrl.dispose();
    codigoPostalCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadAvatar(XFile file) async {
    final url = await widget.api.uploadAvatar(file);
    if (!mounted) return;
    setState(() {
      avatarUrl = url;
      _dirty = true;
    });
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_dirty || _loading) return true;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar cambios'),
        content: const Text(
          'Tienes cambios sin guardar. ¿Deseas salir y descartarlos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'nombre': nombreCtrl.text.trim(),
      'nombre_mostrar': nombreMostrarCtrl.text.trim(),
      'apellidos': apellidosCtrl.text.trim(),
      'email': emailCtrl.text
          .trim(), // si backend espera 'correo', cámbialo aquí
      'telefono': telefonoCtrl.text.trim(),
      'whatsapp': (_sameWhatsapp ? telefonoCtrl.text : whatsappCtrl.text)
          .trim(),
      'calle': calleCtrl.text.trim(),
      'colonia': coloniaCtrl.text.trim(),
      'municipio': municipioCtrl.text.trim(),
      'estado': estadoCtrl.text.trim(),
      'codigo_postal': codigoPostalCtrl.text.trim(),
    }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

    try {
      final updated = await widget.api.updateMe(data);
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados correctamente.')),
      );
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  // =====================
  // Helpers de layout UI
  // =====================

  static const _kGap = 10.0;

  Widget _sectionTitle(String text, {IconData? icon}) {
    final style = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(text, style: style),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 24);

  Widget _sectionCard(List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final w in children) ...[
            w,
            if (w != children.last) const SizedBox(height: _kGap),
          ],
        ],
      ),
    );
  }

  InputDecoration _denseDec(
    String label, {
    IconData? icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      isDense: true,
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    IconData? icon,
    String? hint,
    TextInputType? keyboard,
    List<TextInputFormatter>? fmt,
    String? Function(String?)? validator,
    TextCapitalization caps = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: c,
      decoration: _denseDec(label, icon: icon, hint: hint),
      keyboardType: keyboard,
      inputFormatters: fmt,
      validator: validator,
      textCapitalization: caps,
    );
  }

  /// Layout 2 columnas responsive
  Widget _twoCol(List<Widget> fields) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final two = c.maxWidth >= 520; // Umbral 2 cols
        if (!two) {
          return Column(
            children: [
              for (final f in fields) ...[f, const SizedBox(height: _kGap)],
            ],
          );
        }
        final half = (c.maxWidth - _kGap) / 2;
        return Wrap(
          spacing: _kGap,
          runSpacing: _kGap,
          children: [for (final f in fields) SizedBox(width: half, child: f)],
        );
      },
    );
  }

  // ==============
  // SECCIONES UI
  // ==============

  Widget _perfilSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Perfil', icon: Icons.person_outline),
        _sectionCard([
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarPicker(
                currentUrl: avatarUrl,
                baseOrigin: widget.api.baseUrl, // 👈 nuevo
                onPicked: _uploadAvatar,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreMostrarCtrl.text.isNotEmpty
                          ? nombreMostrarCtrl.text
                          : (nombreCtrl.text.isNotEmpty
                                ? '${nombreCtrl.text} ${apellidosCtrl.text}'
                                      .trim()
                                : 'Tu nombre'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toca la foto para cambiarla',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
        _sectionCard([
          _twoCol([
            _input(
              nombreCtrl,
              'Nombre',
              icon: Icons.person_outline,
              caps: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
            ),
            _input(
              apellidosCtrl,
              'Apellidos',
              icon: Icons.badge_outlined,
              caps: TextCapitalization.words,
            ),
            _input(
              nombreMostrarCtrl,
              'Nombre de perfil',
              icon: Icons.tag_outlined,
              caps: TextCapitalization.words,
            ),
          ]),
        ]),
      ],
    );
  }

  Widget _contactoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Contacto', icon: Icons.call_outlined),
        _sectionCard([
          _input(
            emailCtrl,
            'Correo electrónico',
            icon: Icons.mail_outline,
            hint: 'tu@correo.com',
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null; // opcional
              final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
              return re.hasMatch(v.trim()) ? null : 'Correo no válido';
            },
          ),
          _twoCol([
            _input(
              telefonoCtrl,
              'Teléfono',
              icon: Icons.phone_outlined,
              hint: '10 dígitos',
              keyboard: TextInputType.phone,
              fmt: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return v.length == 10 ? null : 'Debe contener 10 dígitos';
              },
            ),
            const SizedBox.shrink(),
          ]),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Usar mismo número en WhatsApp'),
            value: _sameWhatsapp,
            onChanged: (val) {
              setState(() {
                _sameWhatsapp = val;
                if (val) whatsappCtrl.text = telefonoCtrl.text;
                _dirty = true;
              });
            },
          ),
          if (!_sameWhatsapp)
            _input(
              whatsappCtrl,
              'WhatsApp',
              icon: Icons.message_outlined,
              hint: '10 dígitos',
              keyboard: TextInputType.phone,
              fmt: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                if (_sameWhatsapp) return null;
                if (v == null || v.trim().isEmpty) return null;
                return v.length == 10 ? null : 'Debe contener 10 dígitos';
              },
            ),
        ]),
      ],
    );
  }

  Widget _direccionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Dirección', icon: Icons.home_outlined),
        _sectionCard([
          _input(
            calleCtrl,
            'Calle',
            icon: Icons.map_outlined,
            caps: TextCapitalization.words,
          ),
          _twoCol([
            _input(
              coloniaCtrl,
              'Colonia',
              icon: Icons.home_work_outlined,
              caps: TextCapitalization.words,
            ),
            _input(
              municipioCtrl,
              'Municipio',
              icon: Icons.location_city_outlined,
              caps: TextCapitalization.words,
            ),
            _input(
              estadoCtrl,
              'Estado',
              icon: Icons.public_outlined,
              caps: TextCapitalization.words,
            ),
            _input(
              codigoPostalCtrl,
              'Código postal',
              icon: Icons.local_post_office_outlined,
              keyboard: TextInputType.number,
              fmt: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return v.length == 5 ? null : 'Debe contener 5 dígitos';
              },
            ),
          ]),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmDiscardIfNeeded,
      child: Scaffold(
        // Título limpio y genérico (sin nombre del usuario)
        appBar: AppBar(title: const Text('Editar perfil')),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _dirty && !_loading ? _saveProfile : null,
          icon: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.save),
          label: Text(_dirty ? 'Guardar' : 'Sin cambios'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _perfilSection(),
              _divider(),
              _contactoSection(),
              _divider(),
              _direccionSection(),
              const SizedBox(height: 80), // espacio para el FAB
            ],
          ),
        ),
      ),
    );
  }
}
