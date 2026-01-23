import '../../domain/entities/analytics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

/// Implementation of AnalyticsRepository
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;

  AnalyticsRepositoryImpl({required AnalyticsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<PaidVsToPay> getPaidVsToPay() async {
    return await _remoteDataSource.getPaidVsToPay();
  }

  @override
  Future<MonthlyTransactionTrend> getMonthlyTransactionTrend() async {
    return await _remoteDataSource.getMonthlyTransactionTrend();
  }

  @override
  Future<FavoriteCustomersAnalytics> getFavoriteCustomers() async {
    return await _remoteDataSource.getFavoriteCustomers();
  }

  @override
  Future<FavoriteBusinessesAnalytics> getFavoriteBusinesses() async {
    return await _remoteDataSource.getFavoriteBusinesses();
  }

  @override
  Future<TotalTransactionsAnalytics> getTotalTransactions() async {
    return await _remoteDataSource.getTotalTransactions();
  }

  @override
  Future<TotalAmountAnalytics> getTotalAmount() async {
    return await _remoteDataSource.getTotalAmount();
  }
}
