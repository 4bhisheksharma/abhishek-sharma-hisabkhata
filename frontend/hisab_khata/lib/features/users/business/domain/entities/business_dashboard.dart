class BusinessDashboard {
  final int businessId;
  final String businessName;
  final String? profilePicture;
  final double toGive;
  final double toTake;
  final int totalCustomers;
  final int totalRequests;

  const BusinessDashboard({
    required this.businessId,
    required this.businessName,
    this.profilePicture,
    required this.toGive,
    required this.toTake,
    required this.totalCustomers,
    required this.totalRequests,
  });
}
