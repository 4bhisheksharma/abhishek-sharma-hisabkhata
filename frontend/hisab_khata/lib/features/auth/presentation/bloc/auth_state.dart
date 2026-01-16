import 'package:equatable/equatable.dart';
import '../../domain/entities/login_result_entity.dart';
import '../../domain/entities/user_entity.dart';

/// Base auth state
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Login success state
class LoginSuccess extends AuthState {
  final LoginResultEntity loginResult;

  const LoginSuccess({required this.loginResult});

  @override
  List<Object?> get props => [loginResult];
}

/// Register success state (navigates to OTP)
class RegisterSuccess extends AuthState {
  final String email;
  final String message;

  const RegisterSuccess({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

/// OTP verification success
class OtpVerificationSuccess extends AuthState {
  final String message;

  const OtpVerificationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// OTP resend success
class OtpResendSuccess extends AuthState {
  final String message;

  const OtpResendSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Authenticated state
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Auth error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Logout success
class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

/// Password change success
class PasswordChangeSuccess extends AuthState {
  final String message;

  const PasswordChangeSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
