import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatelessWidget {
  final String? currentUrl;
  final Function(XFile file) onPicked;

  const AvatarPicker({super.key, this.currentUrl, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showPicker(context),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: (currentUrl != null && currentUrl!.isNotEmpty)
                ? NetworkImage(currentUrl!)
                : null,
            child: (currentUrl == null || currentUrl!.isEmpty)
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showPicker(context),
          icon: const Icon(Icons.camera_alt, size: 18),
          label: const Text("Cambiar foto"),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) async {
    final picker = ImagePicker();

    // <-- El tipo genérico T de showModalBottomSheet es ImageSource
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galería"),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Cámara"),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) onPicked(picked);
  }
}
