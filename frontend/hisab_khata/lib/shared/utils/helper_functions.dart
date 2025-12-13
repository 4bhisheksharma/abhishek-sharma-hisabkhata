import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HelperFunctions {
  /// Pick an image from gallery
  /// Returns File if image is selected, null otherwise
  static Future<File?> pickImageFromGallery({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Pick an image from camera
  /// Returns File if image is captured, null otherwise
  static Future<File?> pickImageFromCamera({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
