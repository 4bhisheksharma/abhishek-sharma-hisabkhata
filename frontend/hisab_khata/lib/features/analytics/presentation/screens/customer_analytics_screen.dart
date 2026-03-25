import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/paid_vs_to_pay_bar_chart.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/monthly_trend_line_chart.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/monthly_spending_progress_widget.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/analytics_stat_card.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/pdf_generator.dart';
import 'package:hisab_khata/shared/widgets/shimmer/shimmer_widgets.dart';
import 'package:hisab_khata/shared/widgets/profile/transaction_activity_section.dart';
import 'package:hisab_khata/shared/widgets/profile/transaction_calendar_widget.dart';

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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.analytics),
        actions: [
          BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              if (state is AnalyticsDataLoaded) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Download PDF Report',
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    
                    try {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Generating PDF...')),
                      );
                      await PdfGenerator.generateAndPreviewAnalyticsPdf(
                        state,
                        isBusiness: false,
                      );
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Failed to generate PDF: $e')),
                      );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadAnalytics();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final horizontalPadding = screenWidth < 600 ? 12.0 : 16.0;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
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
                      const SizedBox(height: 24),

                      // Transaction Activity
                      const TransactionActivitySection(isCustomerView: true),
                      const SizedBox(height: 24),

                      // Transaction Calendar
                      const TransactionCalendarWidget(isCustomerView: true),
                    ],
                  ),
                );
              },
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

      return LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.overview,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              isSmallScreen
                  ? Column(
                      children: [
                        AnalyticsStatCard(
                          title: AppLocalizations.of(
                            context,
                          )!.totalTransactions,
                          value: '$totalTransactions',
                          icon: Icons.receipt_long_rounded,
                          iconColor: AppTheme.primaryBlue,
                        ),
                        const SizedBox(height: 12),
                        AnalyticsStatCard(
                          title: AppLocalizations.of(context)!.totalSpent,
                          value: AppLocalizations.of(
                            context,
                          )!.rsAmount(totalAmount.toStringAsFixed(0)),
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: Colors.orange,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: AnalyticsStatCard(
                            title: AppLocalizations.of(
                              context,
                            )!.totalTransactions,
                            value: '$totalTransactions',
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnalyticsStatCard(
                            title: AppLocalizations.of(context)!.totalSpent,
                            value: AppLocalizations.of(
                              context,
                            )!.rsAmount(totalAmount.toStringAsFixed(0)),
                            icon: Icons.account_balance_wallet_rounded,
                            iconColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
            ],
          );
        },
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
              AppLocalizations.of(
                context,
              )!.favoriteBusinesses('${state.totalFavorites ?? 0}'),
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
                    AppLocalizations.of(context)!.favoritedOn(
                      DateTime.parse(
                        business['favoritedAt'],
                      ).toLocal().toString().split(' ')[0],
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.favorite, color: Colors.red),
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
    return const AnalyticsCardShimmer();
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
