import '../../../../core/data/base_remote_data_source.dart';
import '../models/analytics_models.dart';

/// Remote data source for analytics-related API calls
class AnalyticsRemoteDataSource extends BaseRemoteDataSource {
  AnalyticsRemoteDataSource({super.client});

  /// Get paid vs to pay analytics data
  /// GET /api/analytics/paid-vs-to-pay/
  Future<PaidVsToPayModel> getPaidVsToPay() async {
    final response = await get('analytics/paid-vs-to-pay/');
    return PaidVsToPayModel.fromJson(response as Map<String, dynamic>);
  }

  /// Get monthly transaction trend analytics data
  /// GET /api/analytics/monthly-transaction-trend/
  Future<MonthlyTransactionTrendModel> getMonthlyTransactionTrend() async {
    final response = await get('analytics/monthly-transaction-trend/');
    return MonthlyTransactionTrendModel.fromJson(
      response as Map<String, dynamic>,
    );
  }

  /// Get favorite customers analytics data (for businesses)
  /// GET /api/transaction/favorites/
  Future<FavoriteCustomersAnalyticsModel> getFavoriteCustomers() async {
    final response = await get('transaction/favorites/');

    // Convert list response to analytics model format
    final favoriteCustomers = (response as List<dynamic>).map((item) {
      final json = item as Map<String, dynamic>;
      // Create analytics FavoriteCustomerModel from transaction API data
      // For businesses, favorites are customers who favorited them
      return FavoriteCustomerModel(
        relationshipId: json['favorite_id'] as int,
        customerId: json['customer_id'] as int,
        customerName: json['customer_name'] as String,
        customerEmail: '', // Not available in current API
        customerPhone: '', // Not available in current API
        pendingDue: 0.0, // Not available in current API
        favoritedAt: DateTime.parse(json['created_at'] as String),
        totalTransactions: 0, // Not available in current API
      );
    }).toList();

    return FavoriteCustomersAnalyticsModel(
      favoriteCustomers: favoriteCustomers,
      totalFavorites: favoriteCustomers.length,
    );
  }

  /// Get favorite businesses analytics data (for customers)
  /// GET /api/transaction/favorites/
  Future<FavoriteBusinessesAnalyticsModel> getFavoriteBusinesses() async {
    final response = await get('transaction/favorites/');

    // Convert list response to analytics model format
    final favoriteBusinesses = (response as List<dynamic>).map((item) {
      final json = item as Map<String, dynamic>;
      // Create analytics FavoriteBusinessModel from transaction API data
      return FavoriteBusinessModel(
        relationshipId:
            json['favorite_id'] as int, // Use favorite_id as relationship_id
        businessId: json['business_id'] as int,
        businessName: json['business_name'] as String,
        businessEmail: '', // Not available
        businessPhone: null, // Not available
        pendingDue: 0.0, // Not available
        favoritedAt: DateTime.parse(json['created_at'] as String),
        totalTransactions: 0, // Not available
      );
    }).toList();

    return FavoriteBusinessesAnalyticsModel(
      favoriteBusinesses: favoriteBusinesses,
      totalFavorites: favoriteBusinesses.length,
    );
  }

  /// Get total transactions analytics data
  /// GET /api/analytics/total-transactions/
  Future<TotalTransactionsAnalyticsModel> getTotalTransactions() async {
    final response = await get('analytics/total-transactions/');
    return TotalTransactionsAnalyticsModel.fromJson(
      response as Map<String, dynamic>,
    );
  }

  /// Get total amount analytics data
  /// GET /api/analytics/total-amount/
  Future<TotalAmountAnalyticsModel> getTotalAmount() async {
    final response = await get('analytics/total-amount/');
    return TotalAmountAnalyticsModel.fromJson(response as Map<String, dynamic>);
  }

  /// Get monthly spending limit analytics data (for customers)
  /// GET /api/analytics/monthly-spending-limit/
  Future<MonthlySpendingLimitModel> getMonthlySpendingLimit() async {
    final response = await get('analytics/monthly-spending-limit/');
    return MonthlySpendingLimitModel.fromJson(response as Map<String, dynamic>);
  }

  /// Set monthly spending limit (for customers)
  /// POST /api/customer-dashboard/monthly-limit/
  Future<void> setMonthlyLimit(double monthlyLimit) async {
    await post(
      'customer/monthly-limit/',
      body: {'monthly_limit': monthlyLimit},
    );
  }
}
