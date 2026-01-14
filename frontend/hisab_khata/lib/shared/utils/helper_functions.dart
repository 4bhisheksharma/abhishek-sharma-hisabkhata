import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
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

  /// Show a bottom sheet to let user choose between camera and gallery
  /// Returns File if image is selected/captured, null otherwise
  static Future<File?> showImageSourcePicker(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choose Image Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      context: context,
                      icon: Icons.camera_alt_rounded,
                      label: AppLocalizations.of(context)!.camera,
                      source: ImageSource.camera,
                    ),
                    _buildImageSourceOption(
                      context: context,
                      icon: Icons.photo_library_rounded,
                      label: AppLocalizations.of(context)!.gallery,
                      source: ImageSource.gallery,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return null;

    if (source == ImageSource.camera) {
      return await pickImageFromCamera();
    } else {
      return await pickImageFromGallery();
    }
  }

  static Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, source),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
