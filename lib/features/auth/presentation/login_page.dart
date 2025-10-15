import 'package:flutter/material.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/auth/auth_service.dart';
import 'register_page.dart'; // <— IMPORTA TU PANTALLA DE REGISTRO

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await AuthService.login(_email.text.trim(), _pass.text);
      if (!mounted) return;
      await AuthState.I.saveSession(r.token, r.user);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Bienvenido 👋', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),

              TextFormField(
                controller: _email,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: (v) =>
                    (v == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v))
                    ? 'Correo inválido'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _pass,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
              ),

              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 6),

              FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Entrar'),
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () async {
                      final ok = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                      if (ok == true && mounted) {
                        Navigator.of(context).pop(true); // ya quedó logeado
                      }
                    },
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
