import 'package:flutter/material.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';

class MyStatCard extends StatelessWidget {
  final String title;
  final String firstLabel;
  final String firstValue;
  final String secondLabel;
  final String secondValue;
  final IconData icon;
  final VoidCallback? onTap;

  const MyStatCard({
    super.key,
    required this.title,
    required this.firstLabel,
    required this.firstValue,
    required this.secondLabel,
    required this.secondValue,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = Responsive.h(context, 90).clamp(82.0, 108.0);
    final iconBox = Responsive.w(context, 46).clamp(38.0, 52.0);
    final borderRadius = Responsive.radius(context, 16);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: AppTheme.shadowPrimary,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 16),
            vertical: Responsive.h(context, 12),
          ),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    Responsive.radius(context, 14),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: Responsive.sp(context, 24).clamp(18.0, 26.0),
                ),
              ),
              SizedBox(width: Responsive.w(context, 14)),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(context, 13).clamp(11.0, 15.0),
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 8)),
                    // Stats Row
                    Row(
                      children: [
                        // First Stat
                        Row(
                          children: [
                            Icon(
                              Icons.store_outlined,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: Responsive.sp(context, 14).clamp(12.0, 16.0),
                            ),
                            SizedBox(width: Responsive.w(context, 4)),
                            Text(
                              firstLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: Responsive.sp(context, 11).clamp(9.0, 13.0),
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(width: Responsive.w(context, 4)),
                            Text(
                              firstValue,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.sp(context, 12).clamp(10.0, 14.0),
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: Responsive.w(context, 16)),
                        // Second Stat
                        Row(
                          children: [
                            Icon(
                              Icons.pending_outlined,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: Responsive.sp(context, 14).clamp(12.0, 16.0),
                            ),
                            SizedBox(width: Responsive.w(context, 4)),
                            Text(
                              secondLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: Responsive.sp(context, 11).clamp(9.0, 13.0),
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(width: Responsive.w(context, 4)),
                            Text(
                              secondValue,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.sp(context, 12).clamp(10.0, 14.0),
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
