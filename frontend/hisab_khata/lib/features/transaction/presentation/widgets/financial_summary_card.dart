import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';

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
              ? (isCustomerView ? AppTheme.errorRed : AppTheme.successGreen)
              : AppTheme.textSecondary,
          isLarge: true,
        ),
        const SizedBox(height: 12),
        // Secondary amount (Paid/Received)
        _buildAmountRow(
          context,
          icon: Icons.check_circle_outline,
          label: isCustomerView ? 'You Paid' : 'Received',
          amount: totalPaid,
          color: AppTheme.textSecondary,
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
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: isLarge ? 16 : 14, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isLarge ? 13 : 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$currency ${_formatAmount(amount)}',
          style: TextStyle(
            fontSize: isLarge ? 30 : 20,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.5,
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
