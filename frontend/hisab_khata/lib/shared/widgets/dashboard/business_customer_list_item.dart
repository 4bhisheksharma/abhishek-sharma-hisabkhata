import 'package:flutter/material.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';

class BusinessCustomerListItem extends StatelessWidget {
  final String businessName;
  final String phoneNumber;
  final String amount;
  final String? profileImageUrl;
  final VoidCallback? onTap;

  const BusinessCustomerListItem({
    super.key,
    required this.businessName,
    required this.phoneNumber,
    required this.amount,
    this.profileImageUrl,
    this.onTap,
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
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.lightGrey.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.lightBlue,
                backgroundImage:
                    profileImageUrl != null &&
                        ImageUtils.getFullImageUrl(profileImageUrl) != null
                    ? NetworkImage(ImageUtils.getFullImageUrl(profileImageUrl)!)
                    : null,
                child:
                    profileImageUrl == null ||
                        ImageUtils.getFullImageUrl(profileImageUrl) == null
                    ? const Icon(
                        Icons.person_rounded,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Business Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
