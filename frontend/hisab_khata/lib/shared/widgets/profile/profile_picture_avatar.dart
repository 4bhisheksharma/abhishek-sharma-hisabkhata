import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';

/// Reusable widget for displaying profile picture
/// Used in profile view screens for both customer and business
class ProfilePictureAvatar extends StatelessWidget {
  final String? profilePicture;
  final IconData placeholderIcon;
  final double radius;
  final Color backgroundColor;

  const ProfilePictureAvatar({
    super.key,
    required this.profilePicture,
    this.placeholderIcon = Icons.person,
    this.radius = 60,
    this.backgroundColor = AppTheme.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: ImageUtils.getFullImageUrl(profilePicture) != null
          ? NetworkImage(ImageUtils.getFullImageUrl(profilePicture)!)
          : null,
      child: ImageUtils.getFullImageUrl(profilePicture) == null
          ? Icon(placeholderIcon, size: radius, color: Colors.white)
          : null,
    );
  }
}
