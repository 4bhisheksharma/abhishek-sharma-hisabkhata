import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<void> generateAndPreviewAnalyticsPdf(
    AnalyticsDataLoaded data, {
    required bool isBusiness,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(isBusiness),
            pw.SizedBox(height: 20),
            _buildOverviewCards(data, isBusiness),
            pw.SizedBox(height: 20),
            _buildRevenueSection(data),
            if (!isBusiness) ...[
              pw.SizedBox(height: 20),
              _buildSpendingLimitSection(data),
            ],
            pw.SizedBox(height: 20),
            _buildTrendSection(data),
            pw.SizedBox(height: 20),
            _buildFavoritesSection(data, isBusiness),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final String timestamp = DateFormat(
      'yyyyMMdd_HHmmss',
    ).format(DateTime.now());
    final String fileName = isBusiness
        ? 'business_analytics_$timestamp.pdf'
        : 'customer_analytics_$timestamp.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  static pw.Widget _buildHeader(bool isBusiness) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Hisab Khata',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          isBusiness
              ? 'Business Analytics Report'
              : 'Customer Analytics Report',
          style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated on: ${DateFormat('MMMM dd, yyyy - HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _buildOverviewCards(
    AnalyticsDataLoaded data,
    bool isBusiness,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          'Total Transactions',
          '${data.totalTransactions ?? 0}',
          PdfColors.blue,
        ),
        _buildStatCard(
          isBusiness ? 'Total Revenue' : 'Total Spent',
          'Rs. ${data.totalAmount?.toStringAsFixed(2) ?? "0.00"}',
          PdfColors.green,
        ),
      ],
    );
  }

  static pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        margin: const pw.EdgeInsets.only(right: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          color: PdfColors.grey100,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildRevenueSection(AnalyticsDataLoaded data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Revenue Overview',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Text('Paid', style: const pw.TextStyle(fontSize: 14)),
                  pw.Text(
                    'Rs. ${data.paid?.toStringAsFixed(2) ?? "0.00"}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'To Pay/Due',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Rs. ${data.toPay?.toStringAsFixed(2) ?? "0.00"}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSpendingLimitSection(AnalyticsDataLoaded data) {
    if (data.monthlyLimit == null || data.monthlyLimit == 0) {
      return pw.SizedBox();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Monthly Spending Progress (${data.spendingMonth ?? "-"})',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Limit: Rs. ${data.monthlyLimit?.toStringAsFixed(2) ?? "0.00"}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Spent: Rs. ${data.monthlySpent?.toStringAsFixed(2) ?? "0.00"}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Remaining: Rs. ${data.remainingBudget?.toStringAsFixed(2) ?? "0.00"}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Days remaining: ${data.spendingDaysRemaining ?? "-"}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              if (data.isOverBudget == true)
                pw.Text(
                  '⚠️ Over Budget!',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.red,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTrendSection(AnalyticsDataLoaded data) {
    final trendData = data.trendData;
    if (trendData == null || trendData.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Monthly Trend',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Month', 'Amount (Rs.)', 'Transactions'],
          data: trendData
              .map(
                (e) => [
                  e['month'].toString(),
                  e['totalAmount'].toString(),
                  e['transactionCount'].toString(),
                ],
              )
              .toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
          cellAlignment: pw.Alignment.center,
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
        ),
      ],
    );
  }

  static pw.Widget _buildFavoritesSection(
    AnalyticsDataLoaded data,
    bool isBusiness,
  ) {
    final favorites = isBusiness
        ? data.favoriteCustomers
        : data.favoriteBusinesses;
    if (favorites == null || favorites.isEmpty) {
      return pw.SizedBox();
    }

    final title = isBusiness ? 'Favorite Customers' : 'Favorite Businesses';
    final nameKey = isBusiness ? 'customerName' : 'businessName';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Name', 'Pending Due (Rs.)', 'Total Txns'],
          data: favorites
              .map(
                (e) => [
                  e[nameKey]?.toString() ?? 'Unknown',
                  e['pendingDue']?.toString() ?? '0.00',
                  e['totalTransactions']?.toString() ?? '0',
                ],
              )
              .toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
          cellAlignment: pw.Alignment.center,
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
        ),
      ],
    );
  }
}
