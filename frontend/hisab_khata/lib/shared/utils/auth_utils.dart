import 'package:flutter/material.dart';
import 'package:hisab_khata/config/storage/storage_service.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

class AuthUtils {
  /// Shows logout confirmation dialog and handles logout
  static Future<void> handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await StorageService.clearSession();

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await StorageService.isLoggedIn();
  }

  /// Get current user role
  static Future<String?> getUserRole() async {
    return await StorageService.getUserRole();
  }
}
