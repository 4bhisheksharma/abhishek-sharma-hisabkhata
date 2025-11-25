import 'package:flutter/material.dart';

/// Controller for login screen
class AuthController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

/// Controller for signup screen with additional fields
class SignupController extends AuthController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String selectedRole = 'customer';

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

/// Controller for OTP verification screen
class OtpController {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  bool isLoading = false;
  bool isResending = false;
  int resendTimer = 59;

  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
  }

  String getOtp() {
    return otpControllers.map((c) => c.text).join();
  }

  void clearOtp() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }
}