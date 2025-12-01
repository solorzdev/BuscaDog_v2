import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatelessWidget {
  final String? currentUrl;
  final String baseOrigin; // puede traer /api/v1, extraemos el origen
  final Future<void> Function(XFile) onPicked;
  final double size;

  const AvatarPicker({
    super.key,
    required this.currentUrl,
    required this.baseOrigin,
    required this.onPicked,
    this.size = 74,
  });

  // Si la URL ya es absoluta, se usa tal cual; si es relativa, se arma con el origin
  String _resolve(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final o = Uri.parse(baseOrigin); // p.ej. http://10.0.2.2:3000/api/v1
    final origin = Uri(
      scheme: o.scheme,
      host: o.host,
      port: o.port,
    ).toString(); // http://10.0.2.2:3000
    final clean = url.startsWith('/')
        ? url.substring(1)
        : url; // uploads/avatars/...
    return '$origin/$clean';
  }

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? x = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () async {
                final shot = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 90,
                );
                // ignore: use_build_context_synchronously
                Navigator.pop(ctx, shot);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () async {
                final img = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 90,
                );
                // ignore: use_build_context_synchronously
                Navigator.pop(ctx, img);
              },
            ),
          ],
        ),
      ),
    );

    if (x != null) await onPicked(x);
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolve(currentUrl); // puede ser '' si no hay avatar
    final ImageProvider<Object>? provider = url.isEmpty
        ? null
        : NetworkImage(url);

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(size),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,

        // ✅ seguro: null si no hay imagen
        foregroundImage: provider,

        // ✅ solo setea el handler si hay provider
        onForegroundImageError: provider == null
            ? null
            : (Object ex, StackTrace? st) {
                debugPrint('Avatar load error: $ex');
              },

        // ✅ ícono placeholder cuando no hay imagen
        child: provider == null
            ? Icon(Icons.person, size: size * 0.45, color: Colors.black45)
            : null,
      ),
    );
  }
}
