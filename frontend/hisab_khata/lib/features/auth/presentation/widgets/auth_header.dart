import 'package:flutter/material.dart';
import 'package:hisab_khata/core/utils/responsive.dart';

/// Header widget for all auth screens with Hisab Khata logo
class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final iconBox = Responsive.w(context, 56).clamp(48.0, 70.0);
    final cardRadius = Responsive.radius(context, 16);
    final logoRadius = Responsive.radius(context, 10);
    final titleSize = Responsive.sp(context, 28).clamp(22.0, 34.0);

    return Padding(
      padding: EdgeInsets.only(
        top: Responsive.h(context, 32),
        bottom: Responsive.h(context, 24),
        left: Responsive.w(context, 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo
          Container(
            width: iconBox,
            height: iconBox,
            padding: EdgeInsets.all(Responsive.w(context, 6)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: Responsive.radius(context, 12),
                  offset: Offset(0, Responsive.h(context, 4)),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(logoRadius),
              child: Image.asset(
                'assets/images/hisab-khata-logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF00D09E),
                  size: Responsive.sp(context, 28).clamp(22.0, 32.0),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.h(context, 20)),
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
