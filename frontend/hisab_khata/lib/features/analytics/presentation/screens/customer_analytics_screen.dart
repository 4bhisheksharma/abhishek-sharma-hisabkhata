import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/paid_vs_to_pay_bar_chart.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/monthly_trend_line_chart.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/monthly_spending_progress_widget.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/analytics_stat_card.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  State<CustomerAnalyticsScreen> createState() =>
      _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final bloc = context.read<AnalyticsBloc>();
    bloc.add(const GetPaidVsToPayEvent());
    bloc.add(const GetMonthlyTransactionTrendEvent());
    bloc.add(const GetTotalTransactionsEvent());
    bloc.add(const GetTotalAmountEvent());
    bloc.add(const GetMonthlySpendingLimitEvent());
    bloc.add(const GetFavoriteBusinessesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadAnalytics();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Stats
                  _buildOverviewStats(state),
                  const SizedBox(height: 24),

                  // Paid vs To Pay Bar Chart
                  _buildPaidVsToPayChart(state),
                  const SizedBox(height: 24),

                  // Monthly Spending Progress
                  _buildMonthlySpendingProgress(state),
                  const SizedBox(height: 24),

                  // Monthly Transaction Trend
                  _buildMonthlyTrendChart(state),
                  const SizedBox(height: 24),

                  // Favorite Businesses
                  _buildFavoriteBusinesses(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewStats(AnalyticsState state) {
    if (state is AnalyticsDataLoaded) {
      final totalTransactions = state.totalTransactions ?? 0;
      final totalAmount = state.totalAmount ?? 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnalyticsStatCard(
                  title: 'Total Transactions',
                  value: '$totalTransactions',
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnalyticsStatCard(
                  title: 'Total Spent',
                  value: 'Rs. ${totalAmount.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPaidVsToPayChart(AnalyticsState state) {
    if (state is AnalyticsDataLoaded &&
        state.paid != null &&
        state.toPay != null) {
      return PaidVsToPayBarChart(paid: state.paid!, toPay: state.toPay!);
    }

    if (state is AnalyticsLoading) {
      return _buildLoadingCard();
    }

    if (state is AnalyticsError) {
      return _buildErrorCard(state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildMonthlySpendingProgress(AnalyticsState state) {
    if (state is AnalyticsDataLoaded &&
        state.monthlySpent != null &&
        state.monthlyLimit != null &&
        state.remainingBudget != null &&
        state.isOverBudget != null &&
        state.spendingMonth != null &&
        state.spendingDaysRemaining != null) {
      return MonthlySpendingProgressWidget(
        totalSpent: state.monthlySpent!,
        monthlyLimit: state.monthlyLimit!,
        remainingBudget: state.remainingBudget!,
        isOverBudget: state.isOverBudget!,
        month: state.spendingMonth!,
        daysRemaining: state.spendingDaysRemaining!,
      );
    }

    if (state is AnalyticsLoading) {
      return _buildLoadingCard();
    }

    return const SizedBox.shrink();
  }

  Widget _buildMonthlyTrendChart(AnalyticsState state) {
    if (state is AnalyticsDataLoaded && state.trendData != null) {
      return MonthlyTrendLineChart(trendData: state.trendData!);
    }

    if (state is AnalyticsLoading) {
      return _buildLoadingCard();
    }

    if (state is AnalyticsError) {
      return _buildErrorCard(state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildFavoriteBusinesses(AnalyticsState state) {
    if (state is AnalyticsDataLoaded && state.favoriteBusinesses != null) {
      if (state.favoriteBusinesses!.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favorite Businesses (${state.totalFavorites ?? 0})',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.favoriteBusinesses!.length > 5
                  ? 5
                  : state.favoriteBusinesses!.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final business = state.favoriteBusinesses![index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.lightBlue,
                    child: Text(
                      business['businessName'][0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    business['businessName'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${business['totalTransactions']} transactions',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    'Rs. ${business['pendingDue'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: business['pendingDue'] > 0
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
