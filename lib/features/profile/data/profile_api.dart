import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ProfileApi {
  final Dio _dio;
  final String baseUrl; // Ojo: que incluya /api/v1 si lo usas así

  ProfileApi(this._dio, {required this.baseUrl, required String jwt}) {
    _dio.options.headers['Authorization'] = 'Bearer $jwt';
    // opcional: _dio.options.baseUrl = baseUrl;
  }

  Future<Map<String, dynamic>> me() async {
    final r = await _dio.get('$baseUrl/usuarios/me');
    return Map<String, dynamic>.from(r.data['user']);
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async {
    final r = await _dio.patch('$baseUrl/usuarios/me', data: data);
    return Map<String, dynamic>.from(r.data['user']);
  }

  // ✅ sin token aquí
  Future<String> uploadAvatar(XFile picked) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(picked.path, filename: picked.name),
    });

    final r = await _dio.post(
      '$baseUrl/usuarios/me/avatar',
      data: form,
      options: Options(
        contentType: 'multipart/form-data',
        validateStatus: (s) => s != null && s < 500, // deja ver 4xx
      ),
    );

    if (r.statusCode == 200) {
      return (r.data as Map<String, dynamic>)['url'] as String;
    }
    throw Exception('Upload falló ${r.statusCode}: ${r.data}');
  }
}
