class Business {
  final int businessId;
  final int userId;
  final String businessName;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    required this.businessId,
    required this.userId,
    required this.businessName,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });
}
