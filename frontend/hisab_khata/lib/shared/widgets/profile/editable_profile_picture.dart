import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';

/// Reusable widget for profile picture with edit capability
/// Used in profile edit screens for both customer and business
class EditableProfilePicture extends StatelessWidget {
  final File? selectedImage;
  final String? currentProfilePicture;
  final VoidCallback onTap;
  final IconData placeholderIcon;
  final double radius;

  const EditableProfilePicture({
    super.key,
    required this.selectedImage,
    required this.currentProfilePicture,
    required this.onTap,
    this.placeholderIcon = Icons.person,
    this.radius = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : (ImageUtils.getFullImageUrl(currentProfilePicture) != null
                            ? NetworkImage(
                                ImageUtils.getFullImageUrl(
                                  currentProfilePicture,
                                )!,
                              )
                            : null)
                        as ImageProvider?,
              child: selectedImage == null && currentProfilePicture == null
                  ? Icon(
                      placeholderIcon,
                      size: radius,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onTap,
          child: Text(
            'Change Profile Picture',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
