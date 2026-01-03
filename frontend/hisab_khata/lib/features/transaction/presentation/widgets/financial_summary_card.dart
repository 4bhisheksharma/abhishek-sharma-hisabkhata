import 'package:flutter/material.dart';

/// Reusable financial summary widget showing amounts based on user view
/// For Customer: Shows "Your Due" (what they owe) and "You Paid"
/// For Business: Shows "To Receive" (what customer owes) and "Received"
class FinancialSummaryCard extends StatelessWidget {
  final double toPay;
  final double totalPaid;
  final String currency;
  final bool isCustomerView;

  const FinancialSummaryCard({
    super.key,
    required this.toPay,
    required this.totalPaid,
    this.currency = 'Rs.',
    this.isCustomerView = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary amount (Due/To Receive)
        _buildAmountRow(
          context,
          icon: isCustomerView
              ? Icons.account_balance_wallet_outlined
              : Icons.account_balance_outlined,
          label: isCustomerView ? 'Your Due' : 'To Receive',
          amount: toPay,
          color: toPay > 0
              ? (isCustomerView ? Colors.red.shade600 : Colors.green.shade600)
              : Colors.grey.shade600,
          isLarge: true,
        ),
        const SizedBox(height: 12),
        // Secondary amount (Paid/Received)
        _buildAmountRow(
          context,
          icon: Icons.check_circle_outline,
          label: isCustomerView ? 'You Paid' : 'Received',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: isLarge ? 18 : 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isLarge ? 14 : 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$currency ${_formatAmount(amount)}',
          style: TextStyle(
            fontSize: isLarge ? 32 : 22,
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
