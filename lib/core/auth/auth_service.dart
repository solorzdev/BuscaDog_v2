// lib/core/auth/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:buscadog_v2/core/auth/auth_state.dart';

/// Resultado de auth (evita usar records para mayor compatibilidad con SDKs)
class AuthResult {
  final String token;
  final AuthUser user;
  const AuthResult(this.token, this.user);
}

class AuthService {
  /// Dirección del backend Node.js
  static const String base = 'http://10.0.2.2:8080';
  // En dispositivo físico: usa la IP local de tu PC, p. ej. 'http://192.168.1.10:8080'

  /// --- LOGIN ---
  static Future<AuthResult> login(String correo, String contrasena) async {
    final resp = await http.post(
      Uri.parse('$base/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login fallido');
    }

    final token = data['access_token'] as String;
    final user = AuthUser.fromMap(data['user']);
    return AuthResult(token, user);
  }

  // lib/core/auth/auth_service.dart (ya definido)
  static Future<AuthResult> register(
    String correo,
    String contrasena,
    String nombre,
  ) async {
    final resp = await http.post(
      Uri.parse('$base/api/v1/auth/registrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'contrasena': contrasena,
        'nombre_mostrar': nombre,
      }),
    );
    final data = jsonDecode(resp.body);
    if (resp.statusCode != 201) {
      throw Exception(data['error'] ?? 'Error al registrar');
    }
    return AuthResult(
      data['access_token'] as String,
      AuthUser.fromMap(data['user']),
    );
  }
}
