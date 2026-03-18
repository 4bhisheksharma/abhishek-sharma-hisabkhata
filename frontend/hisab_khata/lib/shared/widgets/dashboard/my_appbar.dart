import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

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
  final bool hasUnreadNotifications;

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
    this.hasUnreadNotifications = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(220); //can tuik adjust height as needed

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
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

  String _getRatioMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (toGive > toTake) {
      return l10n.giveToTakeRatioGood;
    } else if (toTake > toGive) {
      return l10n.needToGiveMore;
    } else {
      return l10n.giveAndTakeBalanced;
    }
  }

  void _showLoyaltyPointsDialog(BuildContext context) {
    final points = (loyaltyPoints ?? 0).toInt();
    showDialog(
      context: context,
      builder: (context) => LoyaltyPointsDialog(points: points),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.w(context, 20).clamp(14.0, 24.0);
    final topPadding = Responsive.h(context, 12).clamp(8.0, 16.0);
    final avatarRadius = Responsive.w(context, 20).clamp(16.0, 24.0);

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      elevation: 0,
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
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              Responsive.h(context, 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: onProfileTap,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : null,
                          child: profileImageUrl == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: Responsive.sp(context, 24).clamp(18.0, 28.0),
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.w(context, 12)),
                    // Name and Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hi, $userName',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.sp(context, 18).clamp(14.0, 20.0),
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: Responsive.h(context, 2)),
                          Text(
                            _getGreeting(context),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: Responsive.sp(context, 13).clamp(11.0, 15.0),
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Loyalty Points
                    if (showLoyaltyPoints) ...[
                      GestureDetector(
                        onTap: () => _showLoyaltyPointsDialog(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(context, 10),
                            vertical: Responsive.h(context, 6),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.card_giftcard_rounded,
                                color: Colors.white,
                                size: Responsive.sp(context, 16).clamp(12.0, 18.0),
                              ),
                              SizedBox(width: Responsive.w(context, 4)),
                              Text(
                                loyaltyPoints?.toStringAsFixed(1) ?? "0.0",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.sp(context, 13).clamp(11.0, 15.0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(context, 8)),
                    ],
                    // Notification Bell
                    GestureDetector(
                      onTap: onNotificationTap,
                      child: Container(
                        padding: EdgeInsets.all(Responsive.w(context, 8)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: Responsive.sp(context, 20).clamp(16.0, 24.0),
                            ),
                            if (hasUnreadNotifications)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 14)),
                // Financial Summary Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
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
                                      Icons.arrow_upward_rounded,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.toGive,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Rs. ${toGive.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.2),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
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
                                      Icons.arrow_downward_rounded,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.toTake,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Rs. ${toTake.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Ratio Message
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${_calculateRatio()} | ${_getRatioMessage(context)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoyaltyPointsDialog extends StatefulWidget {
  final int points;

  const LoyaltyPointsDialog({super.key, required this.points});

  @override
  State<LoyaltyPointsDialog> createState() => _LoyaltyPointsDialogState();
}

class _LoyaltyPointsDialogState extends State<LoyaltyPointsDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    // Start confetti when dialog opens
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      title: Row(
        children: [
          const Icon(
            Icons.card_giftcard,
            color: AppTheme.primaryBlue,
            size: 28,
          ),
          // const SizedBox(width: 10),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 200,
          maxWidth: 350, // prevents too wide dialog
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Confetti
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              height: 160,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 3.14 / 2,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.03,
                numberOfParticles: 8,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  AppTheme.primaryBlue,
                  Colors.yellow,
                  Colors.red,
                ],
                maxBlastForce: 15,
                minBlastForce: 5,
                minimumSize: const Size(4, 4),
                maximumSize: const Size(8, 8),
              ),
            ),

            // Text Content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Text(
                'Your Gazab Customer Point is ${widget.points}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}
