import 'package:equatable/equatable.dart';

/// Entity representing paid vs to pay analytics data
class PaidVsToPay extends Equatable {
  final double paid;
  final double toPay;

  const PaidVsToPay({required this.paid, required this.toPay});

  @override
  List<Object?> get props => [paid, toPay];
}

/// Entity representing monthly transaction trend data point
class MonthlyTransactionData extends Equatable {
  final String month;
  final double totalAmount;
  final int transactionCount;

  const MonthlyTransactionData({
    required this.month,
    required this.totalAmount,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [month, totalAmount, transactionCount];
}

/// Entity representing monthly transaction trend analytics
class MonthlyTransactionTrend extends Equatable {
  final List<MonthlyTransactionData> trendData;

  const MonthlyTransactionTrend({required this.trendData});

  @override
  List<Object?> get props => [trendData];
}

/// Entity representing a favorite customer (for business analytics)
class FavoriteCustomer extends Equatable {
  final int relationshipId;
  final int customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final double pendingDue;
  final DateTime favoritedAt;
  final int totalTransactions;

  const FavoriteCustomer({
    required this.relationshipId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.pendingDue,
    required this.favoritedAt,
    required this.totalTransactions,
  });

  @override
  List<Object?> get props => [
    relationshipId,
    customerId,
    customerName,
    customerEmail,
    customerPhone,
    pendingDue,
    favoritedAt,
    totalTransactions,
  ];
}

/// Entity representing favorite customers analytics for business
class FavoriteCustomersAnalytics extends Equatable {
  final List<FavoriteCustomer> favoriteCustomers;
  final int totalFavorites;

  const FavoriteCustomersAnalytics({
    required this.favoriteCustomers,
    required this.totalFavorites,
  });

  @override
  List<Object?> get props => [favoriteCustomers, totalFavorites];
}

/// Entity representing a favorite business (for customer analytics)
class FavoriteBusiness extends Equatable {
  final int relationshipId;
  final int businessId;
  final String businessName;
  final String businessEmail;
  final String? businessPhone;
  final double pendingDue;
  final DateTime favoritedAt;
  final int totalTransactions;

  const FavoriteBusiness({
    required this.relationshipId,
    required this.businessId,
    required this.businessName,
    required this.businessEmail,
    this.businessPhone,
    required this.pendingDue,
    required this.favoritedAt,
    required this.totalTransactions,
  });

  @override
  List<Object?> get props => [
    relationshipId,
    businessId,
    businessName,
    businessEmail,
    businessPhone,
    pendingDue,
    favoritedAt,
    totalTransactions,
  ];
}

/// Entity representing favorite businesses analytics for customer
class FavoriteBusinessesAnalytics extends Equatable {
  final List<FavoriteBusiness> favoriteBusinesses;
  final int totalFavorites;

  const FavoriteBusinessesAnalytics({
    required this.favoriteBusinesses,
    required this.totalFavorites,
  });

  @override
  List<Object?> get props => [favoriteBusinesses, totalFavorites];
}

/// Entity representing total transactions analytics
class TotalTransactionsAnalytics extends Equatable {
  final int totalTransactions;
  final String userType;

  const TotalTransactionsAnalytics({
    required this.totalTransactions,
    required this.userType,
  });

  @override
  List<Object?> get props => [totalTransactions, userType];
}

/// Entity representing total amount analytics
class TotalAmountAnalytics extends Equatable {
  final double totalAmount;
  final String userType;

  const TotalAmountAnalytics({
    required this.totalAmount,
    required this.userType,
  });

  @override
  List<Object?> get props => [totalAmount, userType];
}
