import 'package:flutter/material.dart';
import 'package:hisab_khata/shared/widgets/dashboard/my_appbar.dart';
import 'package:hisab_khata/shared/widgets/my_bottom_nav_bar.dart';

class SharedDashboard extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;
  final double toGive;
  final double toTake;
  final double? loyaltyPoints;
  final bool showLoyaltyPoints;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final Widget body;
  final int currentNavIndex;
  final Function(int)? onNavTap;

  const SharedDashboard({
    super.key,
    required this.userName,
    this.profileImageUrl,
    required this.toGive,
    required this.toTake,
    this.loyaltyPoints,
    this.showLoyaltyPoints = false,
    this.onProfileTap,
    this.onNotificationTap,
    required this.body,
    this.currentNavIndex = 0,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        userName: userName,
        profileImageUrl: profileImageUrl,
        toGive: toGive,
        toTake: toTake,
        loyaltyPoints: loyaltyPoints,
        showLoyaltyPoints: showLoyaltyPoints,
        onProfileTap: onProfileTap,
        onNotificationTap: onNotificationTap,
      ),
      body: body,
      bottomNavigationBar: onNavTap != null
          ? MyBottomNavBar(currentIndex: currentNavIndex, onTap: onNavTap!)
          : null,
    );
  }
}
