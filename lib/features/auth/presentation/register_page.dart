import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  // Cuenta
  final _name = TextEditingController();
  final _last = TextEditingController();
  final _display = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  // Contacto
  final _phone = TextEditingController();
  final _wa = TextEditingController();
  bool _sameWa = true;

  bool _loading = false;
  bool _obscure = true;
  bool _accepted = false;
  String? _error;
  double _strength = 0;

  String? _vEmail(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu correo';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Correo inválido';
  }

  String? _vPass(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Za-z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
      return 'Incluye letras y números';
    }
    return null;
  }

  void _onPassChanged(String v) {
    var s = 0.0;
    if (v.length >= 8) s += .34;
    if (RegExp(r'[A-Za-z]').hasMatch(v) && RegExp(r'\d').hasMatch(v)) s += .33;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v)) s += .33;
    setState(() => _strength = s.clamp(0.0, 1.0));
  }

  InputDecoration _dec(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      isDense: true,
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_accepted) {
      setState(() => _error = 'Debes aceptar Términos y Privacidad.');
      return;
    }
    if (_pass.text != _pass2.text) {
      setState(() => _error = 'Las contraseñas no coinciden.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final payload =
        {
          "nombre": _name.text.trim(),
          "apellidos": _last.text.trim().isEmpty ? null : _last.text.trim(),
          "nombre_mostrar": _display.text.trim().isEmpty
              ? null
              : _display.text.trim(),
          "correo": _email.text.trim().toLowerCase(),
          "contrasena": _pass.text,
          "telefono": _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          "whatsapp": _sameWa
              ? (_phone.text.trim().isEmpty ? null : _phone.text.trim())
              : (_wa.text.trim().isEmpty ? null : _wa.text.trim()),
        }..removeWhere((k, v) {
          if (v == null) return true;
          if (v is String && v.trim().isEmpty) return true;
          return false;
        });

    try {
      final r = await AuthService.registerPayload(payload);
      await AuthState.I.saveSession(r.token, r.user);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Bienvenido 👋',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              // ===== Datos de cuenta =====
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _dec('Nombre', icon: Icons.person_outline),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Nombre demasiado corto'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _last,
                textCapitalization: TextCapitalization.words,
                decoration: _dec('Apellidos', icon: Icons.badge_outlined),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _display,
                textCapitalization: TextCapitalization.words,
                decoration: _dec(
                  'Nombre de perfil (opcional)',
                  icon: Icons.tag_faces_outlined,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('Correo', icon: Icons.mail_outline),
                validator: _vEmail,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _pass,
                obscureText: _obscure,
                onChanged: _onPassChanged,
                decoration: _dec('Contraseña', icon: Icons.lock_outline)
                    .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                validator: _vPass,
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: _strength,
                minHeight: 6,
                backgroundColor: scheme.surfaceVariant,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pass2,
                obscureText: _obscure,
                decoration: _dec(
                  'Confirmar contraseña',
                  icon: Icons.lock_reset_outlined,
                ),
                validator: (v) => (v != _pass.text) ? 'No coincide' : null,
              ),

              const SizedBox(height: 12),

              // ===== Contacto breve =====
              TextFormField(
                controller: _phone,
                decoration: _dec(
                  'Teléfono (opcional)',
                  icon: Icons.phone_outlined,
                  hint: '10 dígitos',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return v.length == 10 ? null : 'Debe contener 10 dígitos';
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Usar mismo número en WhatsApp'),
                value: _sameWa,
                onChanged: (val) => setState(() {
                  _sameWa = val;
                  if (val) _wa.text = _phone.text;
                }),
              ),
              if (!_sameWa) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _wa,
                  decoration: _dec(
                    'WhatsApp (opcional)',
                    icon: Icons.message_outlined,
                    hint: '10 dígitos',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (_sameWa) return null;
                    if (v == null || v.trim().isEmpty) return null;
                    return v.length == 10 ? null : 'Debe contener 10 dígitos';
                  },
                ),
              ],

              const SizedBox(height: 12),

              // ===== Términos =====
              Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    onChanged: (v) => setState(() => _accepted = v ?? false),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: [
                        const Text('Acepto los'),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Términos y Condiciones',
                            style: TextStyle(
                              color: scheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Text('y la'),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Política de Privacidad',
                            style: TextStyle(
                              color: scheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: TextStyle(color: scheme.error)),
                ),

              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt),
                label: const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
