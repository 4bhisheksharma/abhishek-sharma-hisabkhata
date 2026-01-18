import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryBlue,
              backgroundImage:
                  profileImageUrl != null &&
                      ImageUtils.getFullImageUrl(profileImageUrl) != null
                  ? NetworkImage(ImageUtils.getFullImageUrl(profileImageUrl)!)
                  : null,
              child:
                  profileImageUrl == null ||
                      ImageUtils.getFullImageUrl(profileImageUrl) == null
                  ? const Icon(Icons.person, color: Colors.white, size: 28)
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phoneNumber,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              amount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
