import 'package:flutter/material.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/features/auth/presentation/pages/login_screen.dart';
import 'package:hisab_khata/features/auth/presentation/pages/otp_verification_screen.dart';
import 'package:hisab_khata/features/auth/presentation/pages/signup_screen.dart';
import 'package:hisab_khata/features/static/welcome_screen.dart';
import 'package:hisab_khata/features/users/business/presentation/business_home_screen.dart';
import 'package:hisab_khata/features/users/customer/presentation/customer_home_screen.dart';

class AppRouter {
  MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());

      case AppRoutes.otpVerification:
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: ""),
        );

      case AppRoutes.customerHome:
        return MaterialPageRoute(builder: (_) => CustomerHomeScreen());

      case AppRoutes.businessHome:
        return MaterialPageRoute(builder: (_) => BusinessHomeScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
