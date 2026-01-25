import 'package:bloc/bloc.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:hisab_khata/core/usecases/usecase.dart';
import '../../domain/usecases/analytics_usecases.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetPaidVsToPay getPaidVsToPay;
  final GetMonthlyTransactionTrend getMonthlyTransactionTrend;
  final GetFavoriteCustomers getFavoriteCustomers;
  final GetFavoriteBusinesses getFavoriteBusinesses;
  final GetTotalTransactions getTotalTransactions;
  final GetTotalAmount getTotalAmount;
  final GetMonthlySpendingLimit getMonthlySpendingLimit;
  final SetMonthlyLimit setMonthlyLimit;

  AnalyticsDataLoaded _currentData = const AnalyticsDataLoaded();

  AnalyticsBloc({
    required this.getPaidVsToPay,
    required this.getMonthlyTransactionTrend,
    required this.getFavoriteCustomers,
    required this.getFavoriteBusinesses,
    required this.getTotalTransactions,
    required this.getTotalAmount,
    required this.getMonthlySpendingLimit,
    required this.setMonthlyLimit,
  }) : super(const AnalyticsInitial()) {
    on<GetPaidVsToPayEvent>(_onGetPaidVsToPay);
    on<GetMonthlyTransactionTrendEvent>(_onGetMonthlyTransactionTrend);
    on<GetFavoriteCustomersEvent>(_onGetFavoriteCustomers);
    on<GetFavoriteBusinessesEvent>(_onGetFavoriteBusinesses);
    on<GetTotalTransactionsEvent>(_onGetTotalTransactions);
    on<GetTotalAmountEvent>(_onGetTotalAmount);
    on<GetMonthlySpendingLimitEvent>(_onGetMonthlySpendingLimit);
    on<SetMonthlyLimitEvent>(_onSetMonthlyLimit);
  }

  Future<void> _onGetPaidVsToPay(
    GetPaidVsToPayEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await getPaidVsToPay.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) {
        _currentData = _currentData.copyWith(
          paid: analytics.paid,
          toPay: analytics.toPay,
        );
        emit(_currentData);
      },
    );
  }

  Future<void> _onGetMonthlyTransactionTrend(
    GetMonthlyTransactionTrendEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await getMonthlyTransactionTrend.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) {
        _currentData = _currentData.copyWith(
          trendData: analytics.trendData
              .map(
                (data) => {
                  'month': data.month,
                  'totalAmount': data.totalAmount,
                  'transactionCount': data.transactionCount,
                },
              )
              .toList(),
        );
        emit(_currentData);
      },
    );
  }

  Future<void> _onGetFavoriteCustomers(
    GetFavoriteCustomersEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await getFavoriteCustomers.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) {
        _currentData = _currentData.copyWith(
          favoriteCustomers: analytics.favoriteCustomers
              .map(
                (customer) => {
                  'relationshipId': customer.relationshipId,
                  'customerId': customer.customerId,
                  'customerName': customer.customerName,
                  'customerEmail': customer.customerEmail,
                  'customerPhone': customer.customerPhone,
                  'pendingDue': customer.pendingDue,
                  'favoritedAt': customer.favoritedAt.toIso8601String(),
                  'totalTransactions': customer.totalTransactions,
                },
              )
              .toList(),
          totalFavorites: analytics.totalFavorites,
        );
        emit(_currentData);
      },
    );
  }

  Future<void> _onGetFavoriteBusinesses(
    GetFavoriteBusinessesEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await getFavoriteBusinesses.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) {
        _currentData = _currentData.copyWith(
          favoriteBusinesses: analytics.favoriteBusinesses
              .map(
                (business) => {
                  'relationshipId': business.relationshipId,
                  'businessId': business.businessId,
                  'businessName': business.businessName,
                  'businessEmail': business.businessEmail,
                  'businessPhone': business.businessPhone,
                  'pendingDue': business.pendingDue,
                  'favoritedAt': business.favoritedAt.toIso8601String(),
                  'totalTransactions': business.totalTransactions,
                },
              )
              .toList(),
          totalFavorites: analytics.totalFavorites,
        );
        emit(_currentData);
      },
    );
  }

  Future<void> _onGetTotalTransactions(
    GetTotalTransactionsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await getTotalTransactions.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) {
        _currentData = _currentData.copyWith(
          totalTransactions: analytics.totalTransactions,
        );
        emit(_currentData);
      },
    );
  }

  Future<void> _onGetTotalAmount(
    GetTotalAmountEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await getTotalAmount.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) {
        _currentData = _currentData.copyWith(
          totalAmount: analytics.totalAmount,
        );
        emit(_currentData);
      },
    );
  }

  Future<void> _onGetMonthlySpendingLimit(
    GetMonthlySpendingLimitEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    final result = await getMonthlySpendingLimit.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) {
        _currentData = _currentData.copyWith(
          monthlySpent: analytics.totalSpent,
          monthlyLimit: analytics.monthlyLimit,
          remainingBudget: analytics.remainingBudget,
          isOverBudget: analytics.isOverBudget,
          spendingMonth: analytics.month,
          spendingDaysRemaining: analytics.daysRemaining,
        );
        emit(_currentData);
      },
    );
  }

  Future<void> _onSetMonthlyLimit(
    SetMonthlyLimitEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());

    final result = await setMonthlyLimit.call(
      SetMonthlyLimitParams(monthlyLimit: event.monthlyLimit),
    );

    await result.fold(
      (failure) async {
        emit(AnalyticsError(message: failure.failureMessage));
      },
      (_) async {
        // Reload monthly spending limit after setting
        final limitResult = await getMonthlySpendingLimit.call(NoParams());
        limitResult.fold(
          (failure) => emit(AnalyticsError(message: failure.failureMessage)),
          (analytics) {
            _currentData = _currentData.copyWith(
              monthlySpent: analytics.totalSpent,
              monthlyLimit: analytics.monthlyLimit,
              remainingBudget: analytics.remainingBudget,
              isOverBudget: analytics.isOverBudget,
              spendingMonth: analytics.month,
              spendingDaysRemaining: analytics.daysRemaining,
            );
            emit(_currentData);
          },
        );
      },
    );
  }
}
