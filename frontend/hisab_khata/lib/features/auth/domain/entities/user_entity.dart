class UserEntity {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final List<String> roles;
  final String? profileType;
  final bool isActive;

  UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.roles,
    this.profileType,
    required this.isActive,
  });

  String? get role => roles.isNotEmpty ? roles.first : profileType;
}
