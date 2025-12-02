import 'package:equatable/equatable.dart';

/// Base auth event
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Login event
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Register event
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String role;
  final String? businessName;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    this.businessName,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    fullName,
    phoneNumber,
    role,
    businessName,
  ];
}

/// Verify OTP event
class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

/// Resend OTP event
class ResendOtpEvent extends AuthEvent {
  final String email;

  const ResendOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Logout event
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Check auth status event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
