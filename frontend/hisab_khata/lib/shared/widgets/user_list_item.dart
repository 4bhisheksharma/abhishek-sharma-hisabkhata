import 'package:flutter/material.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';
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
    final cardRadius = Responsive.radius(context, 14);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Container(
          margin: EdgeInsets.only(bottom: Responsive.h(context, 10)),
          padding: EdgeInsets.all(Responsive.w(context, 12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              // Avatar with optional badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: Responsive.w(context, 22).clamp(18.0, 25.0),
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
                            size: Responsive.sp(context, 24).clamp(18.0, 26.0),
                          )
                        : null,
                  ),
                  if (showBadge && badgeText != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 6),
                          vertical: Responsive.h(context, 2),
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor ?? AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(
                            Responsive.radius(context, 8),
                          ),
                        ),
                        child: Text(
                          badgeText!,
                          style: TextStyle(
                            fontSize: Responsive.sp(
                              context,
                              10,
                            ).clamp(9.0, 12.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: Responsive.w(context, 12)),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 15).clamp(13.0, 17.0),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(context, 2)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 13).clamp(11.0, 15.0),
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
