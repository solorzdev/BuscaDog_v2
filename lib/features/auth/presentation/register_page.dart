import 'package:flutter/material.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _accepted = false;
  String? _error;
  double _strength = 0;

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu correo';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'Correo inválido';
  }

  String? _validatePass(String? v) {
    if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  void _onPassChanged(String v) {
    // Indicador simple de fuerza
    var s = 0.0;
    if (v.length >= 6) s += .25;
    if (RegExp(r'[A-Z]').hasMatch(v)) s += .25;
    if (RegExp(r'[0-9]').hasMatch(v)) s += .25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v)) s += .25;
    setState(() => _strength = s.clamp(0.0, 1.0));
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
    try {
      final r = await AuthService.register(
        _email.text.trim(),
        _pass.text,
        _name.text.trim(),
      );
      await AuthState.I.saveSession(r.token, r.user); // auto-login
      if (mounted) Navigator.of(context).pop(true); // vuelve indicando éxito
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

              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Nombre demasiado corto'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _pass,
                obscureText: _obscure,
                onChanged: _onPassChanged,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: _validatePass,
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _strength,
                minHeight: 6,
                backgroundColor: scheme.surfaceVariant,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _pass2,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (v) => (v != _pass.text) ? 'No coincide' : null,
              ),
              const SizedBox(height: 12),

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
                          onTap: () {
                            /* TODO: abrir términos */
                          },
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
                          onTap: () {
                            /* TODO: abrir privacidad */
                          },
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
