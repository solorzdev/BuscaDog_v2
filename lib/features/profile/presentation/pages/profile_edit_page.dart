import 'dart:io';
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

      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cambios guardados correctamente.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  InputDecoration _dec(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    );
  }

  // ======= SECCIONES =======

  Widget _general() {
    return Column(
      children: [
        // Solo aquí está el selector de foto
        Card(
          margin: const EdgeInsets.only(top: 4),
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarPicker(currentUrl: avatarUrl, onPicked: _uploadAvatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
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
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nombreCtrl,
          decoration: _dec('Nombre'),
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: apellidosCtrl,
          decoration: _dec('Apellidos'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nombreMostrarCtrl,
          decoration: _dec('Nombre de perfil', hint: 'Cómo te verán otros'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _contacto() {
    return Column(
      children: [
        TextFormField(
          controller: emailCtrl,
          decoration: _dec('Correo electrónico', hint: 'tu@correo.com'),
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null; // opcional
            final emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
            if (!emailRe.hasMatch(v.trim())) return 'Correo no válido';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: telefonoCtrl,
          decoration: _dec(
            'Teléfono',
            hint: '10 dígitos (México)',
            suffix: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null; // opcional
            if (v.length != 10) return 'Debe contener 10 dígitos';
            return null;
          },
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _sameWhatsapp
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              TextFormField(
                controller: whatsappCtrl,
                decoration: _dec(
                  'WhatsApp',
                  hint: '10 dígitos (México)',
                  suffix: const Icon(Icons.message),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  if (_sameWhatsapp) return null;
                  if (v == null || v.trim().isEmpty) return null; // opcional
                  if (v.length != 10) return 'Debe contener 10 dígitos';
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _direccion() {
    return Column(
      children: [
        TextFormField(
          controller: calleCtrl,
          decoration: _dec('Calle'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: coloniaCtrl,
          decoration: _dec('Colonia'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: municipioCtrl,
          decoration: _dec('Municipio'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: estadoCtrl,
          decoration: _dec('Estado'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: codigoPostalCtrl,
          decoration: _dec(
            'Código postal',
            hint: '5 dígitos',
            suffix: const Icon(Icons.local_post_office),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(5),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null; // opcional
            if (v.length != 5) return 'Debe contener 5 dígitos';
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = nombreMostrarCtrl.text.isNotEmpty
        ? nombreMostrarCtrl.text
        : (nombreCtrl.text.isNotEmpty ? nombreCtrl.text : 'Editar perfil');

    return WillPopScope(
      onWillPop: _confirmDiscardIfNeeded,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'General', icon: Icon(Icons.person)),
                Tab(text: 'Contacto', icon: Icon(Icons.call)),
                Tab(text: 'Dirección', icon: Icon(Icons.home)),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Stack(
            alignment: Alignment.topRight,
            children: [
              FloatingActionButton.extended(
                onPressed: _loading ? null : _saveProfile,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
              if (_dirty)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: const TabBarView(
              // Cada tab se scrolla de forma independiente
              children: [
                _TabScaffold(childBuilder: _TabChild.general),
                _TabScaffold(childBuilder: _TabChild.contacto),
                _TabScaffold(childBuilder: _TabChild.direccion),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====== Helpers de UI ======

enum _TabChild { general, contacto, direccion }

class _TabScaffold extends StatelessWidget {
  final _TabChild childBuilder;
  const _TabScaffold({required this.childBuilder});

  @override
  Widget build(BuildContext context) {
    // Accede al estado para usar sus métodos/props
    final state = context.findAncestorStateOfType<_ProfileEditPageState>()!;
    Widget inner;
    switch (childBuilder) {
      case _TabChild.general:
        inner = state._general();
        break;
      case _TabChild.contacto:
        inner = state._contacto();
        break;
      case _TabChild.direccion:
        inner = state._direccion();
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        key: ValueKey(childBuilder),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            inner,
            const SizedBox(height: 72), // espacio para el FAB
          ],
        ),
      ),
    );
  }
}
