import '../../domain/entities/analytics.dart';

/// Model for Paid vs To Pay analytics response
class PaidVsToPayModel extends PaidVsToPay {
  const PaidVsToPayModel({required super.paid, required super.toPay});

  factory PaidVsToPayModel.fromJson(Map<String, dynamic> json) {
    return PaidVsToPayModel(
      paid: double.parse(json['paid'].toString()),
      toPay: double.parse(json['to_pay'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'paid': paid, 'to_pay': toPay};
  }

  /// Convert entity to model
  factory PaidVsToPayModel.fromEntity(PaidVsToPay entity) {
    return PaidVsToPayModel(paid: entity.paid, toPay: entity.toPay);
  }
}

/// Model for monthly transaction data point
class MonthlyTransactionDataModel extends MonthlyTransactionData {
  const MonthlyTransactionDataModel({
    required super.month,
    required super.totalAmount,
    required super.transactionCount,
  });

  factory MonthlyTransactionDataModel.fromJson(Map<String, dynamic> json) {
    return MonthlyTransactionDataModel(
      month: json['month'] as String,
      totalAmount: double.parse(json['total_amount'].toString()),
      transactionCount: json['transaction_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'total_amount': totalAmount,
      'transaction_count': transactionCount,
    };
  }

  /// Convert entity to model
  factory MonthlyTransactionDataModel.fromEntity(
    MonthlyTransactionData entity,
  ) {
    return MonthlyTransactionDataModel(
      month: entity.month,
      totalAmount: entity.totalAmount,
      transactionCount: entity.transactionCount,
    );
  }
}

/// Model for monthly transaction trend analytics response
class MonthlyTransactionTrendModel extends MonthlyTransactionTrend {
  const MonthlyTransactionTrendModel({required super.trendData});

  factory MonthlyTransactionTrendModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final trendDataJson = data['trend_data'] as List<dynamic>;

    final trendData = trendDataJson
        .map(
          (item) => MonthlyTransactionDataModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    return MonthlyTransactionTrendModel(trendData: trendData);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'trend_data': trendData
            .map((data) => (data as MonthlyTransactionDataModel).toJson())
            .toList(),
      },
    };
  }

  /// Convert entity to model
  factory MonthlyTransactionTrendModel.fromEntity(
    MonthlyTransactionTrend entity,
  ) {
    return MonthlyTransactionTrendModel(
      trendData: entity.trendData
          .map((data) => MonthlyTransactionDataModel.fromEntity(data))
          .toList(),
    );
  }
}

/// Model for favorite customer
class FavoriteCustomerModel extends FavoriteCustomer {
  const FavoriteCustomerModel({
    required super.relationshipId,
    required super.customerId,
    required super.customerName,
    required super.customerEmail,
    super.customerPhone,
    required super.pendingDue,
    required super.favoritedAt,
    required super.totalTransactions,
  });

  factory FavoriteCustomerModel.fromJson(Map<String, dynamic> json) {
    return FavoriteCustomerModel(
      relationshipId: json['relationship_id'] as int,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String?,
      pendingDue: double.parse(json['pending_due'].toString()),
      favoritedAt: DateTime.parse(json['favorited_at'] as String),
      totalTransactions: json['total_transactions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relationship_id': relationshipId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'pending_due': pendingDue,
      'favorited_at': favoritedAt.toIso8601String(),
      'total_transactions': totalTransactions,
    };
  }

  /// Convert entity to model
  factory FavoriteCustomerModel.fromEntity(FavoriteCustomer entity) {
    return FavoriteCustomerModel(
      relationshipId: entity.relationshipId,
      customerId: entity.customerId,
      customerName: entity.customerName,
      customerEmail: entity.customerEmail,
      customerPhone: entity.customerPhone,
      pendingDue: entity.pendingDue,
      favoritedAt: entity.favoritedAt,
      totalTransactions: entity.totalTransactions,
    );
  }
}

/// Model for favorite customers analytics response
class FavoriteCustomersAnalyticsModel extends FavoriteCustomersAnalytics {
  const FavoriteCustomersAnalyticsModel({
    required super.favoriteCustomers,
    required super.totalFavorites,
  });

  factory FavoriteCustomersAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final favoriteCustomersJson = data['favorite_customers'] as List<dynamic>;

    final favoriteCustomers = favoriteCustomersJson
        .map(
          (item) =>
              FavoriteCustomerModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return FavoriteCustomersAnalyticsModel(
      favoriteCustomers: favoriteCustomers,
      totalFavorites: data['total_favorites'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'favorite_customers': favoriteCustomers
            .map((customer) => (customer as FavoriteCustomerModel).toJson())
            .toList(),
        'total_favorites': totalFavorites,
      },
    };
  }

  /// Convert entity to model
  factory FavoriteCustomersAnalyticsModel.fromEntity(
    FavoriteCustomersAnalytics entity,
  ) {
    return FavoriteCustomersAnalyticsModel(
      favoriteCustomers: entity.favoriteCustomers
          .map((customer) => FavoriteCustomerModel.fromEntity(customer))
          .toList(),
      totalFavorites: entity.totalFavorites,
    );
  }
}

/// Model for favorite business
class FavoriteBusinessModel extends FavoriteBusiness {
  const FavoriteBusinessModel({
    required super.relationshipId,
    required super.businessId,
    required super.businessName,
    required super.businessEmail,
    super.businessPhone,
    required super.pendingDue,
    required super.favoritedAt,
    required super.totalTransactions,
  });

  factory FavoriteBusinessModel.fromJson(Map<String, dynamic> json) {
    return FavoriteBusinessModel(
      relationshipId: json['relationship_id'] as int,
      businessId: json['business_id'] as int,
      businessName: json['business_name'] as String,
      businessEmail: json['business_email'] as String,
      businessPhone: json['business_phone'] as String?,
      pendingDue: double.parse(json['pending_due'].toString()),
      favoritedAt: DateTime.parse(json['favorited_at'] as String),
      totalTransactions: json['total_transactions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relationship_id': relationshipId,
      'business_id': businessId,
      'business_name': businessName,
      'business_email': businessEmail,
      'business_phone': businessPhone,
      'pending_due': pendingDue,
      'favorited_at': favoritedAt.toIso8601String(),
      'total_transactions': totalTransactions,
    };
  }

  /// Convert entity to model
  factory FavoriteBusinessModel.fromEntity(FavoriteBusiness entity) {
    return FavoriteBusinessModel(
      relationshipId: entity.relationshipId,
      businessId: entity.businessId,
      businessName: entity.businessName,
      businessEmail: entity.businessEmail,
      businessPhone: entity.businessPhone,
      pendingDue: entity.pendingDue,
      favoritedAt: entity.favoritedAt,
      totalTransactions: entity.totalTransactions,
    );
  }
}

/// Model for favorite businesses analytics response
class FavoriteBusinessesAnalyticsModel extends FavoriteBusinessesAnalytics {
  const FavoriteBusinessesAnalyticsModel({
    required super.favoriteBusinesses,
    required super.totalFavorites,
  });

  factory FavoriteBusinessesAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final favoriteBusinessesJson = data['favorite_businesses'] as List<dynamic>;

    final favoriteBusinesses = favoriteBusinessesJson
        .map(
          (item) =>
              FavoriteBusinessModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return FavoriteBusinessesAnalyticsModel(
      favoriteBusinesses: favoriteBusinesses,
      totalFavorites: data['total_favorites'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'favorite_businesses': favoriteBusinesses
            .map((business) => (business as FavoriteBusinessModel).toJson())
            .toList(),
        'total_favorites': totalFavorites,
      },
    };
  }

  /// Convert entity to model
  factory FavoriteBusinessesAnalyticsModel.fromEntity(
    FavoriteBusinessesAnalytics entity,
  ) {
    return FavoriteBusinessesAnalyticsModel(
      favoriteBusinesses: entity.favoriteBusinesses
          .map((business) => FavoriteBusinessModel.fromEntity(business))
          .toList(),
      totalFavorites: entity.totalFavorites,
    );
  }
}

/// Model for total transactions analytics response
class TotalTransactionsAnalyticsModel extends TotalTransactionsAnalytics {
  const TotalTransactionsAnalyticsModel({
    required super.totalTransactions,
    required super.userType,
  });

  factory TotalTransactionsAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TotalTransactionsAnalyticsModel(
      totalTransactions: data['total_transactions'] as int,
      userType: data['user_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {'total_transactions': totalTransactions, 'user_type': userType},
    };
  }

  /// Convert entity to model
  factory TotalTransactionsAnalyticsModel.fromEntity(
    TotalTransactionsAnalytics entity,
  ) {
    return TotalTransactionsAnalyticsModel(
      totalTransactions: entity.totalTransactions,
      userType: entity.userType,
    );
  }
}

/// Model for total amount analytics response
class TotalAmountAnalyticsModel extends TotalAmountAnalytics {
  const TotalAmountAnalyticsModel({
    required super.totalAmount,
    required super.userType,
  });

  factory TotalAmountAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TotalAmountAnalyticsModel(
      totalAmount: double.parse(data['total_amount'].toString()),
      userType: data['user_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {'total_amount': totalAmount, 'user_type': userType},
    };
  }

  /// Convert entity to model
  factory TotalAmountAnalyticsModel.fromEntity(TotalAmountAnalytics entity) {
    return TotalAmountAnalyticsModel(
      totalAmount: entity.totalAmount,
      userType: entity.userType,
    );
  }
}
