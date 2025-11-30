import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository repository;

  ResendOtpUseCase(this.repository);

  Future<bool> call({required String email}) async {
    // Validate input
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }

    // Call repository
    return await repository.resendOtp(email: email.trim());
  }
}
