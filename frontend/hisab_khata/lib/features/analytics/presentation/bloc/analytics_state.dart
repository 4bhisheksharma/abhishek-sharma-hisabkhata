import 'package:equatable/equatable.dart';

sealed class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

final class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// Loading state for analytics operations
final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

/// Error state for analytics operations
final class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Success state for paid vs to pay analytics
final class PaidVsToPayLoaded extends AnalyticsState {
  final double paid;
  final double toPay;

  const PaidVsToPayLoaded({required this.paid, required this.toPay});

  @override
  List<Object?> get props => [paid, toPay];
}

/// Success state for monthly transaction trend analytics
final class MonthlyTransactionTrendLoaded extends AnalyticsState {
  final List<Map<String, dynamic>> trendData;

  const MonthlyTransactionTrendLoaded({required this.trendData});

  @override
  List<Object?> get props => [trendData];
}

/// Success state for favorite customers analytics
final class FavoriteCustomersLoaded extends AnalyticsState {
  final List<Map<String, dynamic>> favoriteCustomers;
  final int totalFavorites;

  const FavoriteCustomersLoaded({
    required this.favoriteCustomers,
    required this.totalFavorites,
  });

  @override
  List<Object?> get props => [favoriteCustomers, totalFavorites];
}

/// Success state for favorite businesses analytics
final class FavoriteBusinessesLoaded extends AnalyticsState {
  final List<Map<String, dynamic>> favoriteBusinesses;
  final int totalFavorites;

  const FavoriteBusinessesLoaded({
    required this.favoriteBusinesses,
    required this.totalFavorites,
  });

  @override
  List<Object?> get props => [favoriteBusinesses, totalFavorites];
}

/// Success state for total transactions analytics
final class TotalTransactionsLoaded extends AnalyticsState {
  final int totalTransactions;
  final String userType;

  const TotalTransactionsLoaded({
    required this.totalTransactions,
    required this.userType,
  });

  @override
  List<Object?> get props => [totalTransactions, userType];
}

/// Success state for total amount analytics
final class TotalAmountLoaded extends AnalyticsState {
  final double totalAmount;
  final String userType;

  const TotalAmountLoaded({required this.totalAmount, required this.userType});

  @override
  List<Object?> get props => [totalAmount, userType];
}

/// Composite state holding all analytics data
final class AnalyticsDataLoaded extends AnalyticsState {
  final double? paid;
  final double? toPay;
  final List<Map<String, dynamic>>? trendData;
  final List<Map<String, dynamic>>? favoriteBusinesses;
  final List<Map<String, dynamic>>? favoriteCustomers;
  final int? totalTransactions;
  final double? totalAmount;
  final double? monthlySpent;
  final double? monthlyLimit;
  final double? remainingBudget;
  final bool? isOverBudget;
  final String? spendingMonth;
  final int? spendingDaysRemaining;
  final int? totalFavorites;

  const AnalyticsDataLoaded({
    this.paid,
    this.toPay,
    this.trendData,
    this.favoriteBusinesses,
    this.favoriteCustomers,
    this.totalTransactions,
    this.totalAmount,
    this.monthlySpent,
    this.monthlyLimit,
    this.remainingBudget,
    this.isOverBudget,
    this.spendingMonth,
    this.spendingDaysRemaining,
    this.totalFavorites,
  });

  AnalyticsDataLoaded copyWith({
    double? paid,
    double? toPay,
    List<Map<String, dynamic>>? trendData,
    List<Map<String, dynamic>>? favoriteBusinesses,
    List<Map<String, dynamic>>? favoriteCustomers,
    int? totalTransactions,
    double? totalAmount,
    double? monthlySpent,
    double? monthlyLimit,
    double? remainingBudget,
    bool? isOverBudget,
    String? spendingMonth,
    int? spendingDaysRemaining,
    int? totalFavorites,
  }) {
    return AnalyticsDataLoaded(
      paid: paid ?? this.paid,
      toPay: toPay ?? this.toPay,
      trendData: trendData ?? this.trendData,
      favoriteBusinesses: favoriteBusinesses ?? this.favoriteBusinesses,
      favoriteCustomers: favoriteCustomers ?? this.favoriteCustomers,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlySpent: monthlySpent ?? this.monthlySpent,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      remainingBudget: remainingBudget ?? this.remainingBudget,
      isOverBudget: isOverBudget ?? this.isOverBudget,
      spendingMonth: spendingMonth ?? this.spendingMonth,
      spendingDaysRemaining:
          spendingDaysRemaining ?? this.spendingDaysRemaining,
      totalFavorites: totalFavorites ?? this.totalFavorites,
    );
  }

  @override
  List<Object?> get props => [
    paid,
    toPay,
    trendData,
    favoriteBusinesses,
    favoriteCustomers,
    totalTransactions,
    totalAmount,
    monthlySpent,
    monthlyLimit,
    remainingBudget,
    isOverBudget,
    spendingMonth,
    spendingDaysRemaining,
    totalFavorites,
  ];
}
