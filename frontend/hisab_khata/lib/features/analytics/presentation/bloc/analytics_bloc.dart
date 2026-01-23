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

  AnalyticsBloc({
    required this.getPaidVsToPay,
    required this.getMonthlyTransactionTrend,
    required this.getFavoriteCustomers,
    required this.getFavoriteBusinesses,
    required this.getTotalTransactions,
    required this.getTotalAmount,
    required this.getMonthlySpendingLimit,
  }) : super(const AnalyticsInitial()) {
    on<GetPaidVsToPayEvent>(_onGetPaidVsToPay);
    on<GetMonthlyTransactionTrendEvent>(_onGetMonthlyTransactionTrend);
    on<GetFavoriteCustomersEvent>(_onGetFavoriteCustomers);
    on<GetFavoriteBusinessesEvent>(_onGetFavoriteBusinesses);
    on<GetTotalTransactionsEvent>(_onGetTotalTransactions);
    on<GetTotalAmountEvent>(_onGetTotalAmount);
    on<GetMonthlySpendingLimitEvent>(_onGetMonthlySpendingLimit);
  }

  Future<void> _onGetPaidVsToPay(
    GetPaidVsToPayEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getPaidVsToPay.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) =>
          emit(PaidVsToPayLoaded(paid: analytics.paid, toPay: analytics.toPay)),
    );
  }

  Future<void> _onGetMonthlyTransactionTrend(
    GetMonthlyTransactionTrendEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getMonthlyTransactionTrend.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) => emit(
        MonthlyTransactionTrendLoaded(
          trendData: analytics.trendData
              .map(
                (data) => {
                  'month': data.month,
                  'totalAmount': data.totalAmount,
                  'transactionCount': data.transactionCount,
                },
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _onGetFavoriteCustomers(
    GetFavoriteCustomersEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getFavoriteCustomers.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) => emit(
        FavoriteCustomersLoaded(
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
        ),
      ),
    );
  }

  Future<void> _onGetFavoriteBusinesses(
    GetFavoriteBusinessesEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getFavoriteBusinesses.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) => emit(
        FavoriteBusinessesLoaded(
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
        ),
      ),
    );
  }

  Future<void> _onGetTotalTransactions(
    GetTotalTransactionsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getTotalTransactions.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) => emit(
        TotalTransactionsLoaded(
          totalTransactions: analytics.totalTransactions,
          userType: analytics.userType,
        ),
      ),
    );
  }

  Future<void> _onGetTotalAmount(
    GetTotalAmountEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getTotalAmount.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) => emit(
        TotalAmountLoaded(
          totalAmount: analytics.totalAmount,
          userType: analytics.userType,
        ),
      ),
    );
  }

  Future<void> _onGetMonthlySpendingLimit(
    GetMonthlySpendingLimitEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await getMonthlySpendingLimit.call(NoParams());
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.failureMessage)),
      (analytics) => emit(
        MonthlySpendingLimitLoaded(
          totalSpent: analytics.totalSpent,
          monthlyLimit: analytics.monthlyLimit,
          remainingBudget: analytics.remainingBudget,
          isOverBudget: analytics.isOverBudget,
          businessCount: analytics.businessCount,
          month: analytics.month,
          daysRemaining: analytics.daysRemaining,
        ),
      ),
    );
  }
}
