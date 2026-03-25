import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/paid_vs_to_pay_bar_chart.dart';
import 'package:hisab_khata/features/analytics/presentation/widgets/analytics_stat_card.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/pdf_generator.dart';
import 'package:hisab_khata/shared/widgets/shimmer/shimmer_widgets.dart';
import 'package:hisab_khata/shared/widgets/profile/transaction_activity_section.dart';
import 'package:hisab_khata/shared/widgets/profile/transaction_calendar_widget.dart';

class BusinessAnalyticsScreen extends StatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  State<BusinessAnalyticsScreen> createState() =>
      _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends State<BusinessAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final bloc = context.read<AnalyticsBloc>();
    bloc.add(const GetPaidVsToPayEvent());
    bloc.add(const GetTotalTransactionsEvent());
    bloc.add(const GetTotalAmountEvent());
    bloc.add(const GetFavoriteCustomersEvent());
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
                        isBusiness: true,
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

                      // Favorite Customers
                      _buildFavoriteCustomers(state),
                      const SizedBox(height: 24),

                      // Transaction Activity
                      const TransactionActivitySection(isCustomerView: false),
                      const SizedBox(height: 24),

                      // Transaction Calendar
                      const TransactionCalendarWidget(isCustomerView: false),
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
      final totalRevenue = state.totalAmount ?? 0.0;

      return LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.businessOverview,
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
                          title: AppLocalizations.of(context)!.totalRevenue,
                          value: AppLocalizations.of(
                            context,
                          )!.rsAmount(totalRevenue.toStringAsFixed(0)),
                          icon: Icons.trending_up_rounded,
                          iconColor: Colors.green,
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
                            title: AppLocalizations.of(context)!.totalRevenue,
                            value: AppLocalizations.of(
                              context,
                            )!.rsAmount(totalRevenue.toStringAsFixed(0)),
                            icon: Icons.trending_up_rounded,
                            iconColor: Colors.green,
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.revenueAnalytics,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          PaidVsToPayBarChart(paid: state.paid!, toPay: state.toPay!),
        ],
      );
    }

    if (state is AnalyticsLoading) {
      return _buildLoadingCard();
    }

    if (state is AnalyticsError) {
      return _buildErrorCard(state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildFavoriteCustomers(AnalyticsState state) {
    if (state is AnalyticsDataLoaded && state.favoriteCustomers != null) {
      if (state.favoriteCustomers!.isEmpty) {
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
            children: [
              Icon(
                Icons.star_border_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.noFavoriteCustomersYet,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.customersWhoFavorite,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.favoriteCustomers,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${state.totalFavorites ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.favoriteCustomers!.length > 5
                  ? 5
                  : state.favoriteCustomers!.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final customer = state.favoriteCustomers![index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.lightBlue,
                    child: Text(
                      customer['customerName'][0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    customer['customerName'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.favoritedOn(
                      DateTime.parse(
                        customer['favoritedAt'],
                      ).toLocal().toString().split(' ')[0],
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.star_rounded, color: Colors.amber),
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
