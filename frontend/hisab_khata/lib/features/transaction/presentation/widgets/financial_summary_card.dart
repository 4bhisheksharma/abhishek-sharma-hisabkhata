import 'package:flutter/material.dart';

/// Reusable financial summary widget showing To Pay and Paid amounts
class FinancialSummaryCard extends StatelessWidget {
  final double toPay;
  final double totalPaid;
  final String currency;

  const FinancialSummaryCard({
    super.key,
    required this.toPay,
    required this.totalPaid,
    this.currency = 'रु',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // To Pay
        _buildAmountRow(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'To Pay',
          amount: toPay,
          color: Theme.of(context).colorScheme.primary,
          isLarge: true,
        ),
        const SizedBox(height: 8),
        // Paid
        _buildAmountRow(
          context,
          icon: Icons.check_circle_outline,
          label: 'Paid',
          amount: totalPaid,
          color: Colors.grey.shade600,
          isLarge: false,
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required bool isLarge,
  }) {
    return Row(
      children: [
        Icon(icon, size: isLarge ? 20 : 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: isLarge ? 14 : 13, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          '$currency ${_formatAmount(amount)}',
          style: TextStyle(
            fontSize: isLarge ? 28 : 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
