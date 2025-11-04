import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:buscadog_v2/core/auth/auth_state.dart';

class AuthResult {
  final String token;
  final AuthUser user;
  const AuthResult(this.token, this.user);
}

class AuthService {
  /// Dirección del backend Node.js
  static const String base = 'http://10.0.2.2:8080';
  static Uri _u(String p) => Uri.parse('$base$p');

  /// --- LOGIN ---
  static Future<AuthResult> login(String correo, String contrasena) async {
    final resp = await http.post(
      _u('/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login fallido');
    }
    final token = (data['access_token'] ?? data['token']) as String;
    final user = AuthUser.fromMap(data['user']);
    return AuthResult(token, user);
  }

  /// --- REGISTRO ---
  static Future<AuthResult> register(
    String correo,
    String contrasena,
    String nombre,
  ) {
    final payload = <String, dynamic>{
      'correo': correo,
      'contrasena': contrasena,
      'nombre': nombre,
      'nombre_mostrar': nombre,
    };
    return registerPayload(payload);
  }

  /// --- REGISTRO ---
  static Future<AuthResult> registerPayload(
    Map<String, dynamic> payload,
  ) async {
    final resp = await http.post(
      _u('/api/v1/auth/registrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final data = jsonDecode(resp.body);
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception(data['error'] ?? 'Error al registrar');
    }

    final token = (data['access_token'] ?? data['token']) as String;
    final user = AuthUser.fromMap(data['user']);
    return AuthResult(token, user);
  }
}
