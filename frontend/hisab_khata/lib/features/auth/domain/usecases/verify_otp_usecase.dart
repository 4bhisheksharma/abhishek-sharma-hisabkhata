import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<bool> call({required String email, required String otp}) async {
    // Validate inputs
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }
    if (otp.trim().isEmpty) {
      throw Exception('OTP is required');
    }
    if (otp.length != 6) {
      throw Exception('OTP must be 6 digits');
    }

    // Call repository
    return await repository.verifyOtp(email: email.trim(), otp: otp.trim());
  }
}
