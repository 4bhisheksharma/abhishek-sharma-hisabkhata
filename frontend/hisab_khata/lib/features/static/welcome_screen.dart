import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hisab_khata/config/storage/storage_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                'assets/images/hisab-khata-logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // yedi image load hunna sakena vane fallback icon aauchha
                  return Icon(
                    Icons.account_balance_wallet,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            // App Name
            Text(
              'Hisab खाता',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            Text(
              'Your Personal Digital खाता',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 50),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
