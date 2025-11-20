class LoginResponse {
  final int status;
  final String message;
  final LoginData? data;

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
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? role;
  final bool isVerified;

  LoginData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role,
    required this.isVerified,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
