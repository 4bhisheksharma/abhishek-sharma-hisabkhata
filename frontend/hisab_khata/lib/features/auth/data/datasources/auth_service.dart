import 'package:hisab_khata/core/data/api_service.dart';

//TODO: this will change completly rn i am just focusing on clean architecture

class AuthService {
  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    required String role,
    String? businessName,
  }) async {
    try {
      final response = await ApiService.post('/register/', {
        'email': email,
        'password': password,
        'full_name': fullName,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber,
        'role': role,
        if (businessName != null && businessName.isNotEmpty)
          'business_name': businessName,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.post('/verify-otp/', {
        'email': email,
        'otp': otp,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/login/', {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Resend OTP TODO: paxi garumla
  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await ApiService.post('/resend-otp/', {'email': email});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
