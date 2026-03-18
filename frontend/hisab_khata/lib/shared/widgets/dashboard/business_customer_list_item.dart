import 'package:flutter/material.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';
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
    final cardRadius = Responsive.radius(context, 14);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Container(
          margin: EdgeInsets.only(bottom: Responsive.h(context, 8)),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 14),
            vertical: Responsive.h(context, 12),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: AppTheme.lightGrey.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: Responsive.w(context, 22).clamp(18.0, 25.0),
                backgroundColor: AppTheme.lightBlue,
                backgroundImage:
                    profileImageUrl != null &&
                        ImageUtils.getFullImageUrl(profileImageUrl) != null
                    ? NetworkImage(ImageUtils.getFullImageUrl(profileImageUrl)!)
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
              SizedBox(width: Responsive.w(context, 12)),
              // Business Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 15).clamp(13.0, 17.0),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 2)),
                    Text(
                      phoneNumber,
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 13).clamp(11.0, 15.0),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 10),
                  vertical: Responsive.h(context, 4),
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(
                    Responsive.radius(context, 8),
                  ),
                ),
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 14).clamp(12.0, 16.0),
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
