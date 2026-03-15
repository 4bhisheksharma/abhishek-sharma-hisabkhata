import 'package:flutter/material.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';

/// A reusable list item widget for displaying user information
/// Used for connected users, recent businesses/customers, etc.
class UserListItem extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? profileImageUrl;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showBadge;
  final String? badgeText;
  final Color? badgeColor;

  const UserListItem({
    super.key,
    required this.name,
    required this.subtitle,
    this.profileImageUrl,
    this.trailing,
    this.onTap,
    this.showBadge = false,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              // Avatar with optional badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.lightBlue,
                    backgroundImage:
                        profileImageUrl != null &&
                            ImageUtils.getFullImageUrl(profileImageUrl) != null
                        ? NetworkImage(
                            ImageUtils.getFullImageUrl(profileImageUrl)!,
                          )
                        : null,
                    child:
                        profileImageUrl == null ||
                            ImageUtils.getFullImageUrl(profileImageUrl) == null
                        ? Icon(
                            Icons.person_rounded,
                            color: AppTheme.primaryBlue,
                            size: 24,
                          )
                        : null,
                  ),
                  if (showBadge && badgeText != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor ?? AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Trailing widget (amount, icon, etc.)
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
