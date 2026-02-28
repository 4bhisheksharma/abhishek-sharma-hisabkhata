import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';

class MySnackbar {
  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
        duration: duration,
      ),
    );
  }

  /// Show success snackbar with green background
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.successGreen,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Show error snackbar with red background
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.errorRed,
      icon: Icons.error_outline_rounded,
      duration: const Duration(seconds: 4),
    );
  }

  /// Show info snackbar with blue background
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.infoBlue,
      icon: Icons.info_outline_rounded,
    );
  }

  /// Show warning snackbar with orange background
  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.warningOrange,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Show custom snackbar with custom color
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration? duration,
    IconData? icon,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: backgroundColor ?? AppTheme.darkGrey,
      icon: icon ?? Icons.notifications_none_rounded,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
