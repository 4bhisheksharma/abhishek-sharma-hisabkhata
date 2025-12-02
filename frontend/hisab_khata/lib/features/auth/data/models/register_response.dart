class RegisterResponse {
  final int status;
  final String message;
  final RegisterData? data;

  RegisterResponse({required this.status, required this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }

  bool get isSuccess => status == 200;
}

class RegisterData {
  final String email;
  final String? phoneNumber;
  final String fullName;

  RegisterData({required this.email, this.phoneNumber, required this.fullName});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      fullName: json['full_name'] ?? '',
    );
  }
}
