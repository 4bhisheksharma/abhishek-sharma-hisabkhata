import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';

/// Reusable transaction list item widget
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final String currency;
  final bool isCustomerView;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.currency = 'Rs.',
    this.isCustomerView = true,
    this.onTap,
  });

  Color get _iconBackgroundColor {
    switch (transaction.transactionType) {
      case TransactionType.purchase:
        return const Color(0xFFFF7043); // Orange-red for purchase (debt added)
      case TransactionType.payment:
        return const Color(0xFF66BB6A); // Green for payment (debt reduced)
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
        return Icons.payments_outlined;
      case TransactionType.credit:
        return Icons.credit_card;
      case TransactionType.refund:
        return Icons.replay;
      case TransactionType.adjustment:
        return Icons.tune;
    }
  }

  /// Get display text based on transaction type and view
  String get _displayText {
    if (transaction.description.isNotEmpty) {
      return transaction.description;
    }
    // Provide contextual labels
    if (isCustomerView) {
      switch (transaction.transactionType) {
        case TransactionType.purchase:
          return 'Purchase from business';
        case TransactionType.payment:
          return 'Payment made';
        case TransactionType.credit:
          return 'Credit received';
        case TransactionType.refund:
          return 'Refund received';
        case TransactionType.adjustment:
          return 'Adjustment';
      }
    } else {
      // Business view
      switch (transaction.transactionType) {
        case TransactionType.purchase:
          return 'Sale to customer';
        case TransactionType.payment:
          return 'Payment received';
        case TransactionType.credit:
          return 'Credit given';
        case TransactionType.refund:
          return 'Refund given';
        case TransactionType.adjustment:
          return 'Adjustment';
      }
    }
  }

  /// Amount color based on transaction effect
  /// For Customer: Purchase/Credit = Red (owes more), Payment/Refund = Green (owes less)
  /// For Business: Purchase/Credit = Green (receives more), Payment/Refund = Green (received)
  Color get _amountColor {
    if (isCustomerView) {
      return transaction.isDebit ? Colors.red.shade700 : Colors.green.shade700;
    } else {
      // Business view - all incoming is good
      return transaction.isDebit ? Colors.green.shade700 : Colors.blue.shade700;
    }
  }

  /// Amount prefix based on transaction type
  String get _amountPrefix {
    if (isCustomerView) {
      return transaction.isDebit ? '+' : '-'; // + means owes more, - means paid
    } else {
      return transaction.isDebit ? '+' : ''; // + means customer owes more
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm - MMM dd');

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
                    _displayText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.transactionDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // Amount with prefix
            Text(
              '$_amountPrefix$currency ${_formatAmount(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _amountColor,
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
