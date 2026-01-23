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

/// Success state for monthly spending limit analytics
final class MonthlySpendingLimitLoaded extends AnalyticsState {
  final double totalSpent;
  final double? monthlyLimit;
  final double? remainingBudget;
  final bool isOverBudget;
  final int businessCount;
  final String month;
  final int daysRemaining;

  const MonthlySpendingLimitLoaded({
    required this.totalSpent,
    this.monthlyLimit,
    this.remainingBudget,
    required this.isOverBudget,
    required this.businessCount,
    required this.month,
    required this.daysRemaining,
  });

  @override
  List<Object?> get props => [
    totalSpent,
    monthlyLimit,
    remainingBudget,
    isOverBudget,
    businessCount,
    month,
    daysRemaining,
  ];
}
