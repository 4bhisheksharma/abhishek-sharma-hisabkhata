import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';

/// Reusable transaction list item widget
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final String currency;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.currency = 'Rs.',
    this.onTap,
  });

  Color get _iconBackgroundColor {
    switch (transaction.transactionType) {
      case TransactionType.purchase:
        return const Color(0xFF00D09E); // Green for purchase
      case TransactionType.payment:
        return const Color(0xFF4CAF50); // Darker green for payment
      case TransactionType.credit:
        return const Color(0xFFFFA726); // Orange for credit
      case TransactionType.refund:
        return const Color(0xFF42A5F5); // Blue for refund
      case TransactionType.adjustment:
        return const Color(0xFF9E9E9E); // Grey for adjustment
    }
  }

  IconData get _icon {
    switch (transaction.transactionType) {
      case TransactionType.purchase:
        return Icons.shopping_bag_outlined;
      case TransactionType.payment:
        return Icons.payment;
      case TransactionType.credit:
        return Icons.credit_card;
      case TransactionType.refund:
        return Icons.replay;
      case TransactionType.adjustment:
        return Icons.tune;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm - MMMM dd');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            // Description and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : transaction.typeDisplay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.transactionDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '$currency ${_formatAmount(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction.isDebit
                    ? Colors.black87
                    : Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return amount.toStringAsFixed(2);
  }
}
