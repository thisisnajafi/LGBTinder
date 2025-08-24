import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/colors.dart';

class AvatarUpload extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String) onImageSelected;

  const AvatarUpload({
    Key? key,
    this.initialImageUrl,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  State<AvatarUpload> createState() => _AvatarUploadState();
}

class _AvatarUploadState extends State<AvatarUpload> {
  String? _imagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _confirm() {
    if (_imagePath != null) {
      widget.onImageSelected(_imagePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _imagePath ?? widget.initialImageUrl;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryLight.withOpacity(0.1),
              backgroundImage: image != null ? (image.startsWith('http') 
                ? NetworkImage(image) as ImageProvider 
                : FileImage(File(image))) : null,
              child: image == null
                  ? Icon(Icons.person, size: 60, color: AppColors.primaryLight)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.edit, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _imagePath != null ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm'),
            ),
            const SizedBox(width: 16),
            if (_imagePath != null)
              OutlinedButton(
                onPressed: () => setState(() => _imagePath = null),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
          ],
        ),
      ],
    );
  }
} 