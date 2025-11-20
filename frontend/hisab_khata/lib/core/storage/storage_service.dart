import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisab_khata/features/auth/models/login_response.dart';

class StorageService {
  // Keys for storage
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'email';
  static const String _keyRole = 'role';
  static const String _keyFirstName = 'first_name';
  static const String _keyLastName = 'last_name';
  static const String _keyIsVerified = 'is_verified';
  static const String _keyLoginTime = 'login_time';

  /// Save complete user session after login
  static Future<void> saveUserSession({
    required Tokens tokens,
    required User user,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save tokens
    await prefs.setString(_keyAccessToken, tokens.access);
    await prefs.setString(_keyRefreshToken, tokens.refresh);

    // Save user data
    await prefs.setInt(_keyUserId, user.id);
    await prefs.setString(_keyEmail, user.email);
    await prefs.setString(_keyRole, user.role ?? '');
    await prefs.setString(_keyFirstName, user.firstName);
    await prefs.setString(_keyLastName, user.lastName);
    await prefs.setBool(_keyIsVerified, user.isVerified);
    await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Get stored tokens
  static Future<Tokens?> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_keyAccessToken);
    final refresh = prefs.getString(_keyRefreshToken);

    if (access == null || refresh == null) return null;

    return Tokens(access: access, refresh: refresh);
  }

  /// Get user data
  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);

    if (userId == null) return null;

    return User(
      id: userId,
      email: prefs.getString(_keyEmail) ?? '',
      role: prefs.getString(_keyRole),
      firstName: prefs.getString(_keyFirstName) ?? '',
      lastName: prefs.getString(_keyLastName) ?? '',
      isVerified: prefs.getBool(_keyIsVerified) ?? false,
    );
  }

  /// Get user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Update access token (for token refresh)
  static Future<void> updateAccessToken(String newAccessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, newAccessToken);
  }

  /// Update user data
  static Future<void> updateUserData({
    String? firstName,
    String? lastName,
    bool? isVerified,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (firstName != null) await prefs.setString(_keyFirstName, firstName);
    if (lastName != null) await prefs.setString(_keyLastName, lastName);
    if (isVerified != null) await prefs.setBool(_keyIsVerified, isVerified);
    if (role != null) await prefs.setString(_keyRole, role);
  }

  /// Clear all session data (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Get login time
  static Future<DateTime?> getLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeString = prefs.getString(_keyLoginTime);
    if (loginTimeString == null) return null;
    return DateTime.tryParse(loginTimeString);
  }
}
