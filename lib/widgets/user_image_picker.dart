import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(XFile? pickImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  XFile? _pickedImageFile;
  Uint8List? _imageBytes;

  void _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedImage == null) {
        print('No image selected');
        return;
      }

      print('Image selected: ${pickedImage.name}');

      // Read and validate image bytes
      final bytes = await pickedImage.readAsBytes();
      if (bytes.isEmpty) {
        _showError('Selected file is empty');
        return;
      }

      print('Image bytes length: ${bytes.length}');

      // FIXED: Better image validation
      if (!_isValidImageFile(bytes)) {
        _showError('Please select a valid image file (PNG, JPG, JPEG)');
        return;
      }

      // FIXED: Safe state update
      if (mounted) {
        setState(() {
          _pickedImageFile = pickedImage;
          _imageBytes = bytes;
        });

        // Pass the image to parent
        widget.onPickImage(pickedImage);
        print('✅ Image selection successful');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showError('Failed to pick image. Please try again.');
    }
  }

  // FIXED: Improved image validation
  bool _isValidImageFile(Uint8List bytes) {
    if (bytes.length < 4) {
      print('File too small to be valid image');
      return false;
    }

    // Check for valid image file signatures
    // JPEG starts with 0xFF 0xD8
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      print('Valid JPEG detected');
      return true;
    }

    // PNG starts with 0x89 0x50 0x4E 0x47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      print('Valid PNG detected');
      return true;
    }

    // GIF starts with 0x47 0x49 0x46
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      print('Valid GIF detected');
      return true;
    }

    // WebP starts with 0x52 0x49 0x46 0x46
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      print('Valid WebP detected');
      return true;
    }

    print(
      'Invalid image format detected. First 10 bytes: ${bytes.take(10).toList()}',
    );
    return false;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildImageWidget() {
    if (_imageBytes != null) {
      return CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 40,
        backgroundImage: MemoryImage(_imageBytes!),
      );
    } else {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 40,
        child: Icon(Icons.person, size: 40, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImageWidget(),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image, color: Colors.white54),
          label: Text(
            _pickedImageFile == null ? "Add Image" : "Change Image",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
