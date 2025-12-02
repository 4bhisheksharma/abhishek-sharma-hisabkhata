import '../../domain/entities/user_entity.dart';
import '../../domain/entities/tokens_entity.dart';
import '../../domain/entities/login_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_response.dart';
import '../../../../config/storage/storage_service.dart';
import '../../../../core/errors/exceptions.dart';

/// Implementation of AuthRepository
/// Handles data operations and converts between models and entities
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    required String role,
    String? businessName,
  }) async {
    final response = await remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
      businessName: businessName,
    );

    if (!response.isSuccess) {
      throw Exception(response.message);
    }

    // Return email for OTP verification
    return response.data?.email ?? email;
  }

  @override
  Future<LoginResultEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message);
    }

    // Convert model to entity
    final user = _mapUserToEntity(response.data!.user);
    final tokens = _mapTokensToEntity(response.data!.tokens);

    // Save session
    await StorageService.saveUserSession(
      tokens: response.data!.tokens,
      user: response.data!.user,
    );

    return LoginResultEntity(user: user, tokens: tokens);
  }

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await remoteDataSource.verifyOtp(email: email, otp: otp);
      return response['status'] == 200;
    } catch (e) {
      // Re-throw with a cleaner error message
      if (e is ServerException) {
        throw Exception(e.exceptionMessage);
      }
      rethrow;
    }
  }

  @override
  Future<bool> resendOtp({required String email}) async {
    try {
      final response = await remoteDataSource.resendOtp(email: email);
      return response['status'] == 200;
    } catch (e) {
      // Re-throw with a cleaner error message
      if (e is ServerException) {
        throw Exception(e.exceptionMessage);
      }
      rethrow;
    }
  }

  @override
  Future<bool> logout() async {
    await StorageService.clearSession();
    return true;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await StorageService.getUserData();
    if (user == null) return null;
    return _mapUserToEntity(user);
  }

  @override
  Future<bool> isAuthenticated() async {
    return await StorageService.isLoggedIn();
  }

  @override
  Future<String?> getAccessToken() async {
    return await StorageService.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await StorageService.getRefreshToken();
  }

  /// Helper method to convert User model to UserEntity
  UserEntity _mapUserToEntity(User user) {
    return UserEntity(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      roles: user.roles,
      profileType: user.profileType,
      isActive: user.isActive,
    );
  }

  /// Helper method to convert Tokens model to TokensEntity
  TokensEntity _mapTokensToEntity(Tokens tokens) {
    return TokensEntity(access: tokens.access, refresh: tokens.refresh);
  }
}
