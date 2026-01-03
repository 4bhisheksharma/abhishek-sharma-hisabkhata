import 'package:flutter/material.dart';
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
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                        isFavorite ? Icons.star : Icons.star_border,
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
      color: Colors.grey.shade200,
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey.shade400),
    );
  }
}
