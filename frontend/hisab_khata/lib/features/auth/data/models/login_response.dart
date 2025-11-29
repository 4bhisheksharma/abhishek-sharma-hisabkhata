class LoginResponse {
  final int status;
  final String message;
  final LoginData? data;

  //TODO: this will change completly rn i am just focusing on clean architecture

  LoginResponse({required this.status, required this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 200;
}

class LoginData {
  final User user;
  final Tokens tokens;

  LoginData({required this.user, required this.tokens});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: User.fromJson(json['user']),
      tokens: Tokens.fromJson(json['tokens']),
    );
  }
}

class User {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final List<String> roles;
  final String? profileType;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.roles,
    this.profileType,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['user_id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
      profileType: json['profile_type'],
      isActive: json['is_active'] ?? false,
    );
  }

  String? get role => roles.isNotEmpty ? roles.first : profileType;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'roles': roles,
      'profile_type': profileType,
      'is_active': isActive,
    };
  }
}

class Tokens {
  final String access;
  final String refresh;

  Tokens({required this.access, required this.refresh});

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(access: json['access'] ?? '', refresh: json['refresh'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'access': access, 'refresh': refresh};
  }
}
