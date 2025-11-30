import '../entities/login_result_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<LoginResultEntity> call({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    required String role,
    String? businessName,
  }) async {
    // Validate inputs
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }
    if (password.trim().isEmpty) {
      throw Exception('Password is required');
    }
    if (fullName.trim().isEmpty) {
      throw Exception('Full name is required');
    }
    if (role.trim().isEmpty) {
      throw Exception('Role is required');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }

    // Call repository
    return await repository.register(
      email: email.trim(),
      password: password,
      fullName: fullName.trim(),
      phoneNumber: phoneNumber?.trim(),
      role: role.trim(),
      businessName: businessName?.trim(),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
