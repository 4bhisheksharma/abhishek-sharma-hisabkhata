import 'package:equatable/equatable.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to get paid vs to pay analytics
final class GetPaidVsToPayEvent extends AnalyticsEvent {
  const GetPaidVsToPayEvent();
}

/// Event to get monthly transaction trend analytics
final class GetMonthlyTransactionTrendEvent extends AnalyticsEvent {
  const GetMonthlyTransactionTrendEvent();
}

/// Event to get favorite customers analytics (business only)
final class GetFavoriteCustomersEvent extends AnalyticsEvent {
  const GetFavoriteCustomersEvent();
}

/// Event to get favorite businesses analytics (customer only)
final class GetFavoriteBusinessesEvent extends AnalyticsEvent {
  const GetFavoriteBusinessesEvent();
}

/// Event to get total transactions analytics
final class GetTotalTransactionsEvent extends AnalyticsEvent {
  const GetTotalTransactionsEvent();
}

/// Event to get total amount analytics
final class GetTotalAmountEvent extends AnalyticsEvent {
  const GetTotalAmountEvent();
}

/// Event to get monthly spending limit analytics (customer only)
final class GetMonthlySpendingLimitEvent extends AnalyticsEvent {
  const GetMonthlySpendingLimitEvent();
}
