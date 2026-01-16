import '../../../../core/data/base_remote_data_source.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/login_response.dart';
import '../models/register_response.dart';

/// Abstract class defining auth remote data source contract
abstract class AuthRemoteDataSource {
  /// Register new user
  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    required String role,
    String? businessName,
  });

  /// Login user
  Future<LoginResponse> login({
    required String email,
    required String password,
  });

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  });

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp({required String email});

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

/// Implementation of AuthRemoteDataSource using BaseRemoteDataSource
class AuthRemoteDataSourceImpl extends BaseRemoteDataSource
    implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({super.client});

  @override
  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    required String role,
    String? businessName,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': role,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'phone_number': phoneNumber,
      if (businessName != null && businessName.isNotEmpty)
        'business_name': businessName,
    };

    final response = await post(
      'auth/${ApiEndpoints.register}',
      body: body,
      includeAuth: false,
    );

    return RegisterResponse.fromJson(response);
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final body = {'email': email, 'password': password};

    final response = await post(
      'auth/${ApiEndpoints.login}',
      body: body,
      includeAuth: false,
    );

    return LoginResponse.fromJson(response);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final body = {'email': email, 'otp': otp};

    final response = await post(
      'auth/${ApiEndpoints.otpVerification}',
      body: body,
      includeAuth: false,
    );

    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final body = {'email': email};

    final response = await post(
      'auth/${ApiEndpoints.resendOtp}',
      body: body,
      includeAuth: false,
    );

    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final body = {
      'old_password': oldPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };

    final response = await post(
      'auth/${ApiEndpoints.changePassword}',
      body: body,
      includeAuth: true,
    );

    return response as Map<String, dynamic>;
  }
}
