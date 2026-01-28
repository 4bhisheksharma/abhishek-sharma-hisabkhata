import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

class MonthlyTrendLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> trendData;

  const MonthlyTrendLineChart({super.key, required this.trendData});

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
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
        child: Center(
          child: Text(AppLocalizations.of(context)!.noTransactionData),
        ),
      );
    }

    final spots = <FlSpot>[];
    double maxY = 0;

    for (int i = 0; i < trendData.length; i++) {
      final amount = (trendData[i]['totalAmount'] as num).toDouble().abs();
      spots.add(FlSpot(i.toDouble(), amount));
      if (amount > maxY) maxY = amount;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final chartHeight = screenWidth < 400 ? 220.0 : 250.0;
        final cardPadding = screenWidth < 400 ? 12.0 : 16.0;

        return Container(
          padding: EdgeInsets.all(cardPadding),
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
                'Monthly Transaction Trend',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: chartHeight,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 0
                          ? (maxY / 5).clamp(1.0, double.infinity)
                          : 1.0,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < trendData.length) {
                              final month = trendData[value.toInt()]['month']
                                  .toString()
                                  .split(' ')[0];
                              // Show every 2nd month to avoid crowding
                              if (value.toInt() % 2 == 0) {
                                return Text(
                                  month,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxY > 0 ? maxY / 5 : 1,
                          reservedSize: 50,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300),
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    minX: 0,
                    maxX: (trendData.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: 0.5),
                            AppTheme.primaryBlue,
                          ],
                        ),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.primaryBlue,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue.withValues(alpha: 0.2),
                              AppTheme.primaryBlue.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.grey[800]!,
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final month =
                                trendData[touchedSpot.x.toInt()]['month'];
                            final amount =
                                trendData[touchedSpot.x.toInt()]['totalAmount'];
                            final count =
                                trendData[touchedSpot.x
                                    .toInt()]['transactionCount'];
                            return LineTooltipItem(
                              '$month\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Rs. ${amount.toStringAsFixed(2)}\n',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: '$count transactions',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
