import 'package:flutter/material.dart';
import 'package:hisab_khata/features/auth/presentation/login_screen.dart';
import 'package:hisab_khata/features/auth/presentation/signup_screen.dart';
import 'package:hisab_khata/features/static/choose_user_screen.dart';
import 'package:hisab_khata/features/static/welcome_screen.dart';
import 'package:hisab_khata/features/users/business/presentation/business_home_screen.dart';
import 'package:hisab_khata/features/users/customer/presentation/customer_home_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    "/business_home": (context) => const BusinessHomeScreen(),
    "/customer_home": (context) => const CustomerHomeScreen(),
    "/welcome": (context) => const WelcomeScreen(),
    "/choose_user": (context) => const ChooseUserScreen(),
    "/login": (context) => const LoginScreen(),
    "/signup": (context) => const SignupScreen(),
    // "/profile": (context) => const ProfileScreen(),
  };
  static var initialRoute = "/welcome";
}