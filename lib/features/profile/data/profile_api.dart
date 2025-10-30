import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ProfileApi {
  final Dio _dio;
  final String baseUrl;

  ProfileApi(this._dio, {required this.baseUrl, required String jwt}) {
    _dio.options.headers['Authorization'] = 'Bearer $jwt';
  }

  Future<Map<String, dynamic>> me() async {
    final r = await _dio.get('$baseUrl/usuarios/me');
    return Map<String, dynamic>.from(r.data['user']);
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async {
    final r = await _dio.patch('$baseUrl/usuarios/me', data: data);
    return Map<String, dynamic>.from(r.data['user']);
  }

  Future<String> uploadAvatar(XFile picked) async {
    final form = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        picked.path,
        filename: 'avatar.jpg',
      ),
    });
    final r = await _dio.post('$baseUrl/usuarios/me/avatar', data: form);
    return r.data['avatar_url'] as String;
  }
}
