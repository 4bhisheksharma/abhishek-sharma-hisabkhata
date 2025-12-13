import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String greeting;
  final String? profileImageUrl;
  final double toGive;
  final double toTake;
  final double? loyaltyPoints;
  final bool showLoyaltyPoints;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const MyAppBar({
    super.key,
    required this.userName,
    this.greeting = 'Good Morning',
    this.profileImageUrl,
    required this.toGive,
    required this.toTake,
    this.loyaltyPoints,
    this.showLoyaltyPoints = false,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(200);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _calculateRatio() {
    if (toTake == 0 && toGive == 0) {
      return '0%';
    } else if (toTake == 0) {
      return '100%';
    } else {
      final ratio = (toGive / toTake) * 100;
      return '${ratio.toStringAsFixed(1)}%';
    }
  }

  String _getRatioMessage() {
    if (toGive > toTake) {
      return 'Your Give is to Take Ratio Looks Good';
    } else if (toTake > toGive) {
      return 'You Need to Give More Than Take';
    } else {
      return 'Your Give and Take is Balanced';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: onProfileTap,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : null,
                        child: profileImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 30,
                                color: AppTheme.primaryBlue,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Name and Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hi, $userName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Loyalty Points
                    if (showLoyaltyPoints) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.card_giftcard,
                              color: AppTheme.primaryBlue,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              loyaltyPoints?.toStringAsFixed(1) ?? "0.0",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Notification Bell
                    GestureDetector(
                      onTap: onNotificationTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Financial Summary and Ratio in Single Row
                Row(
                  children: [
                    // To Give
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.call_made,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'To Give',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'रु ${toGive.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      height: 50,
                      width: 1.5,
                      color: Theme.of(context).colorScheme.onPrimary,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    // To Take
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.call_received,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'To Take',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'रु ${toTake.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: AppTheme.infoBlue,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Ratio Message
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_box_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${_calculateRatio()} | ${_getRatioMessage()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
