import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hisab_khata/core/storage/storage_service.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for 2 seconds to show welcome screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is already logged in
    final isLoggedIn = await StorageService.isLoggedIn();

    if (isLoggedIn) {
      final role = await StorageService.getUserRole();

      // Navigate to appropriate home screen based on role
      if (role == 'customer') {
        Navigator.pushReplacementNamed(context, '/customer_home');
      } else if (role == 'business') {
        Navigator.pushReplacementNamed(context, '/business_home');
      } else {
        // If role is not set, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // User is not logged in, go to login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = Responsive.w(context, 130).clamp(96.0, 148.0);
    final logoRadius = Responsive.radius(context, 28);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(logoRadius),
                      boxShadow: AppTheme.shadowPrimary,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(logoRadius),
                      child: Image.asset(
                        'assets/images/hisab-khata-logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryBlue,
                                  AppTheme.secondaryBlue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(logoRadius),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              size: Responsive.sp(
                                context,
                                64,
                              ).clamp(44.0, 72.0),
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(context, 32)),
                // App Name
                Text(
                  AppLocalizations.of(context)!.appName,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 30).clamp(24.0, 34.0),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 8)),
                // Tagline
                Text(
                  AppLocalizations.of(context)!.tagline,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 15).clamp(13.0, 18.0),
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 48)),

                // Loading indicator
                SizedBox(
                  width: Responsive.w(context, 28).clamp(22.0, 36.0),
                  height: Responsive.w(context, 28).clamp(22.0, 36.0),
                  child: CircularProgressIndicator(
                    strokeWidth: Responsive.radius(context, 2.5),
                    color: AppTheme.primaryBlue.withValues(alpha: 0.6),
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
