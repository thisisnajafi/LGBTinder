import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) {
      _cropImage(picked.path);
    }
  }

  Future<void> _cropImage(String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      cropStyle: CropStyle.circle,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Avatar',
          toolbarColor: AppColors.primaryLight,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Crop Avatar',
        ),
      ],
    );
    if (cropped != null) {
      setState(() => _imagePath = cropped.path);
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
              backgroundImage: image != null ? FileImage(
                image.startsWith('http') ? NetworkImage(image) as ImageProvider : FileImage(File(image)),
              ) : null,
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