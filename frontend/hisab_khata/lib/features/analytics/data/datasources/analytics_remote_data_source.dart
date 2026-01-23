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
  /// GET /api/analytics/favorite-customers/
  Future<FavoriteCustomersAnalyticsModel> getFavoriteCustomers() async {
    final response = await get('analytics/favorite-customers/');
    return FavoriteCustomersAnalyticsModel.fromJson(
      response as Map<String, dynamic>,
    );
  }

  /// Get favorite businesses analytics data (for customers)
  /// GET /api/analytics/favorite-businesses/
  Future<FavoriteBusinessesAnalyticsModel> getFavoriteBusinesses() async {
    final response = await get('analytics/favorite-businesses/');
    return FavoriteBusinessesAnalyticsModel.fromJson(
      response as Map<String, dynamic>,
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
}
