import '../entities/analytics.dart';

/// Repository interface for analytics-related operations
abstract class AnalyticsRepository {
  /// Get paid vs to pay analytics data
  Future<PaidVsToPay> getPaidVsToPay();

  /// Get monthly transaction trend data
  Future<MonthlyTransactionTrend> getMonthlyTransactionTrend();

  /// Get favorite customers analytics (for businesses)
  Future<FavoriteCustomersAnalytics> getFavoriteCustomers();

  /// Get favorite businesses analytics (for customers)
  Future<FavoriteBusinessesAnalytics> getFavoriteBusinesses();

  /// Get total transactions count analytics
  Future<TotalTransactionsAnalytics> getTotalTransactions();

  /// Get total amount analytics
  Future<TotalAmountAnalytics> getTotalAmount();
}
