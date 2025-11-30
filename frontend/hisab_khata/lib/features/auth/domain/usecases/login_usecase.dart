import '../entities/login_result_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResultEntity> call({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }
    if (password.trim().isEmpty) {
      throw Exception('Password is required');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Call repository
    return await repository.login(email: email.trim(), password: password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
