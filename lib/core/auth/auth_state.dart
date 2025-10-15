import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String id;
  final String email;
  final String? name;
  const AuthUser({required this.id, required this.email, this.name});

  factory AuthUser.fromMap(Map<String, dynamic> m) => AuthUser(
    id: m['id'].toString(),
    email: m['correo'] as String,
    name: (m['nombre_mostrar'] as String?),
  );
}

class AuthState extends ChangeNotifier {
  static final AuthState I = AuthState._();
  AuthState._();

  String? _token;
  AuthUser? _user;

  String? get token => _token;
  AuthUser? get user => _user;
  bool get isLogged => _token != null && _user != null;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('auth_token');
    final raw = sp.getString('auth_user');
    if (_token != null && raw != null) {
      _user = AuthUser.fromMap(jsonDecode(raw));
    }
    notifyListeners();
  }

  Future<void> saveSession(String token, AuthUser user) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('auth_token', token);
    await sp.setString(
      'auth_user',
      jsonEncode({
        'id': user.id,
        'correo': user.email,
        'nombre_mostrar': user.name,
      }),
    );
    _token = token;
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('auth_token');
    await sp.remove('auth_user');
    _token = null;
    _user = null;
    notifyListeners();
  }
}
