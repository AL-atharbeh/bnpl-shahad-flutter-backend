import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/language_service.dart';
import '../theme/app_colors.dart';

const int kMaxImageBytes = 5 * 1024 * 1024;

/// Asks for gallery or camera, then picks an image already scaled down, which
/// does on the phone what the portal does with a canvas before uploading.
Future<XFile?> pickImage(
  BuildContext context, {
  required double maxSide,
  int quality = 80,
}) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SourceTile(
              icon: Icons.photo_library_rounded,
              label: context.tr('chooseFromGallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            _SourceTile(
              icon: Icons.photo_camera_rounded,
              label: context.tr('takePhoto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    ),
  );
  if (source == null) return null;

  return ImagePicker().pickImage(
    source: source,
    maxWidth: maxSide,
    maxHeight: maxSide,
    imageQuality: quality,
  );
}

/// The store logo is saved inline, as a data URL, the same as on the portal.
Future<String> toDataUrl(XFile file) async {
  final bytes = await File(file.path).readAsBytes();
  final lower = file.path.toLowerCase();
  final mime = lower.endsWith('.png') ? 'image/png' : 'image/jpeg';
  return 'data:$mime;base64,${base64Encode(bytes)}';
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.green50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
