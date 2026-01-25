import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/core/usecases/usecase.dart';
import 'package:hisab_khata/features/analytics/domain/entities/analytics.dart';
import 'package:hisab_khata/features/analytics/domain/repositories/analytics_repository.dart';

/// Usecase for getting paid vs to pay analytics
class GetPaidVsToPay extends Usecase<PaidVsToPay, NoParams> {
  final AnalyticsRepository repository;

  GetPaidVsToPay(this.repository);

  @override
  Future<Either<Failure, PaidVsToPay>> call(NoParams params) async {
    try {
      final result = await repository.getPaidVsToPay();
      return Right(result);
    } catch (e) {
      return Left(
        Failure('Failed to get paid vs to pay analytics: ${e.toString()}'),
      );
    }
  }
}

/// Usecase for getting monthly transaction trend analytics
class GetMonthlyTransactionTrend
    extends Usecase<MonthlyTransactionTrend, NoParams> {
  final AnalyticsRepository repository;

  GetMonthlyTransactionTrend(this.repository);

  @override
  Future<Either<Failure, MonthlyTransactionTrend>> call(NoParams params) async {
    try {
      final result = await repository.getMonthlyTransactionTrend();
      return Right(result);
    } catch (e) {
      return Left(
        Failure('Failed to get monthly transaction trend: ${e.toString()}'),
      );
    }
  }
}

/// Usecase for getting favorite customers analytics (business only)
class GetFavoriteCustomers
    extends Usecase<FavoriteCustomersAnalytics, NoParams> {
  final AnalyticsRepository repository;

  GetFavoriteCustomers(this.repository);

  @override
  Future<Either<Failure, FavoriteCustomersAnalytics>> call(
    NoParams params,
  ) async {
    try {
      final result = await repository.getFavoriteCustomers();
      return Right(result);
    } catch (e) {
      return Left(Failure('Failed to get favorite customers: ${e.toString()}'));
    }
  }
}

/// Usecase for getting favorite businesses analytics (customer only)
class GetFavoriteBusinesses
    extends Usecase<FavoriteBusinessesAnalytics, NoParams> {
  final AnalyticsRepository repository;

  GetFavoriteBusinesses(this.repository);

  @override
  Future<Either<Failure, FavoriteBusinessesAnalytics>> call(
    NoParams params,
  ) async {
    try {
      final result = await repository.getFavoriteBusinesses();
      return Right(result);
    } catch (e) {
      return Left(
        Failure('Failed to get favorite businesses: ${e.toString()}'),
      );
    }
  }
}

/// Usecase for getting total transactions analytics
class GetTotalTransactions
    extends Usecase<TotalTransactionsAnalytics, NoParams> {
  final AnalyticsRepository repository;

  GetTotalTransactions(this.repository);

  @override
  Future<Either<Failure, TotalTransactionsAnalytics>> call(
    NoParams params,
  ) async {
    try {
      final result = await repository.getTotalTransactions();
      return Right(result);
    } catch (e) {
      return Left(Failure('Failed to get total transactions: ${e.toString()}'));
    }
  }
}

/// Usecase for getting total amount analytics
class GetTotalAmount extends Usecase<TotalAmountAnalytics, NoParams> {
  final AnalyticsRepository repository;

  GetTotalAmount(this.repository);

  @override
  Future<Either<Failure, TotalAmountAnalytics>> call(NoParams params) async {
    try {
      final result = await repository.getTotalAmount();
      return Right(result);
    } catch (e) {
      return Left(Failure('Failed to get total amount: ${e.toString()}'));
    }
  }
}

/// Usecase for getting monthly spending limit analytics (customer only)
class GetMonthlySpendingLimit extends Usecase<MonthlySpendingLimit, NoParams> {
  final AnalyticsRepository repository;

  GetMonthlySpendingLimit(this.repository);

  @override
  Future<Either<Failure, MonthlySpendingLimit>> call(NoParams params) async {
    try {
      final result = await repository.getMonthlySpendingLimit();
      return Right(result);
    } catch (e) {
      return Left(
        Failure('Failed to get monthly spending limit: ${e.toString()}'),
      );
    }
  }
}

/// Parameters for SetMonthlyLimit usecase
class SetMonthlyLimitParams {
  final double monthlyLimit;

  SetMonthlyLimitParams({required this.monthlyLimit});
}

/// Usecase for setting monthly spending limit (customer only)
class SetMonthlyLimit extends Usecase<void, SetMonthlyLimitParams> {
  final AnalyticsRepository repository;

  SetMonthlyLimit(this.repository);

  @override
  Future<Either<Failure, void>> call(SetMonthlyLimitParams params) async {
    try {
      await repository.setMonthlyLimit(params.monthlyLimit);
      return const Right(null);
    } catch (e) {
      return Left(
        Failure('Failed to set monthly spending limit: ${e.toString()}'),
      );
    }
  }
}
