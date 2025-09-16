import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/stories_service.dart';
import '../utils/api_error_handler.dart';

class StoryCreationScreen extends StatefulWidget {
  const StoryCreationScreen({Key? key}) : super(key: key);

  @override
  State<StoryCreationScreen> createState() => _StoryCreationScreenState();
}

class _StoryCreationScreenState extends State<StoryCreationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  StoryType _selectedType = StoryType.text;
  File? _selectedImage;
  File? _selectedVideo;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Create Story'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _publishStory,
            child: Text(
              'Publish',
              style: AppTypography.body1.copyWith(
                color: _isLoading ? Colors.white54 : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStoryTypeSelector(),
          Expanded(
            child: _buildStoryContent(),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildStoryTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTypeButton(
            'Text',
            Icons.text_fields,
            StoryType.text,
          ),
          const SizedBox(width: 16),
          _buildTypeButton(
            'Photo',
            Icons.photo_camera,
            StoryType.image,
          ),
          const SizedBox(width: 16),
          _buildTypeButton(
            'Video',
            Icons.videocam,
            StoryType.video,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, IconData icon, StoryType type) {
    final isSelected = _selectedType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedImage = null;
            _selectedVideo = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.navbarBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white24,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.body2.copyWith(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    switch (_selectedType) {
      case StoryType.text:
        return _buildTextStory();
      case StoryType.image:
        return _buildImageStory();
      case StoryType.video:
        return _buildVideoStory();
    }
  }

  Widget _buildTextStory() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s on your mind?',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppTypography.body1.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: AppTypography.body1.copyWith(
                  color: Colors.white54,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageStory() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: _selectedImage != null
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.navbarBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white24,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No image selected',
                          style: AppTypography.body1.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 3,
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Add a caption...',
              hintStyle: AppTypography.body1.copyWith(
                color: Colors.white54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStory() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: _selectedVideo != null
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Video preview would go here
                          Container(
                            color: AppColors.navbarBackground,
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                size: 64,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.navbarBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white24,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No video selected',
                          style: AppTypography.body1.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 3,
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Add a caption...',
              hintStyle: AppTypography.body1.copyWith(
                color: Colors.white54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_selectedType == StoryType.image || _selectedType == StoryType.video) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: Icon(
                  _selectedType == StoryType.image ? Icons.photo_library : Icons.video_library,
                  color: Colors.white,
                ),
                label: Text(
                  _selectedType == StoryType.image ? 'Choose Photo' : 'Choose Video',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _captureMedia,
                icon: Icon(
                  _selectedType == StoryType.image ? Icons.camera_alt : Icons.videocam,
                  color: Colors.white,
                ),
                label: Text(
                  _selectedType == StoryType.image ? 'Take Photo' : 'Record Video',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _publishStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Publish Story',
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickMedia() async {
    try {
      final XFile? file = await _imagePicker.pickMedia(
        mediaType: _selectedType == StoryType.image 
            ? MediaType.image 
            : MediaType.video,
      );
      
      if (file != null) {
        setState(() {
          if (_selectedType == StoryType.image) {
            _selectedImage = File(file.path);
          } else {
            _selectedVideo = File(file.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick media: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captureMedia() async {
    try {
      final XFile? file = await _imagePicker.pickMedia(
        mediaType: _selectedType == StoryType.image 
            ? MediaType.image 
            : MediaType.video,
        source: ImageSource.camera,
      );
      
      if (file != null) {
        setState(() {
          if (_selectedType == StoryType.image) {
            _selectedImage = File(file.path);
          } else {
            _selectedVideo = File(file.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture media: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _publishStory() async {
    if (_selectedType == StoryType.text && _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text for your story'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedType == StoryType.image && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for your story'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedType == StoryType.video && _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video for your story'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await StoriesService.createStory(
        type: _selectedType,
        content: _textController.text.trim(),
        imageFile: _selectedImage,
        videoFile: _selectedVideo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ApiErrorHandler.handleApiError(
          context,
          e,
          customMessage: 'Failed to publish story. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

enum StoryType {
  text,
  image,
  video,
}
