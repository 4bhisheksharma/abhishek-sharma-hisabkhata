import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/image_utils.dart';

/// Reusable profile card with favorite star badge
/// Used in Connected User Details page header
class ProfileCardWithBadge extends StatelessWidget {
  final String? profilePicture;
  final bool showFavorite;
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback? onFavoriteTap;
  final double size;

  const ProfileCardWithBadge({
    super.key,
    this.profilePicture,
    this.showFavorite = false,
    this.isFavorite = false,
    this.isLoading = false,
    this.onFavoriteTap,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Profile picture container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryBlue, width: 2.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: profilePicture != null && profilePicture!.isNotEmpty
                ? Image.network(
                    ImageUtils.getFullImageUrl(profilePicture) ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
          ),
        ),
        // Favorite star badge
        if (showFavorite)
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: isLoading ? null : onFavoriteTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isFavorite
                      ? AppTheme.primaryBlue
                      : AppTheme.dividerColor,
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppTheme.surfaceGrey,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.5,
        color: AppTheme.textHint,
      ),
    );
  }
}
