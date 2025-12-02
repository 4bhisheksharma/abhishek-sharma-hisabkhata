import '../entities/user_entity.dart';
import '../entities/login_result_entity.dart';

abstract class AuthRepository {
  /// Registers a new user
  /// Returns success message on success
  /// Throws exception on failure
  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    required String role,
    String? businessName,
  });

  /// Authenticates existing user
  /// Returns LoginResultEntity with user data and tokens on success
  /// Throws exception on failure
  Future<LoginResultEntity> login({
    required String email,
    required String password,
  });

  /// Verifies OTP code for user
  /// Returns true if verification successful
  /// Throws exception on failure
  Future<bool> verifyOtp({required String email, required String otp});

  /// Resends OTP code to user email
  /// Returns true if OTP sent successfully
  /// Throws exception on failure
  Future<bool> resendOtp({required String email});

  /// Logs out current user
  /// Clears all stored tokens and user data
  /// Returns true if logout successful
  Future<bool> logout();

  /// Retrieves currently authenticated user from local storage
  /// Returns UserEntity if user is logged in
  /// Returns null if no user is authenticated
  Future<UserEntity?> getCurrentUser();

  /// Checks if user is currently authenticated
  /// Returns true if valid access token exists
  Future<bool> isAuthenticated();

  /// Gets current access token
  /// Returns token string if exists, null otherwise
  Future<String?> getAccessToken();

  /// Gets current refresh token
  /// Returns token string if exists, null otherwise
  Future<String?> getRefreshToken();
}
