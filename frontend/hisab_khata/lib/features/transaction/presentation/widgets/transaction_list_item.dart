import 'package:flutter/material.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
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
        return Icons.shopping_bag_rounded;
      case TransactionType.payment:
        return Icons.payments_rounded;
      case TransactionType.credit:
        return Icons.credit_card_rounded;
      case TransactionType.refund:
        return Icons.replay_rounded;
      case TransactionType.adjustment:
        return Icons.tune_rounded;
    }
  }

  /// Get display text based on transaction type and view
  String _displayText(BuildContext context) {
    if (transaction.description.isNotEmpty) {
      return transaction.description;
    }
    final l10n = AppLocalizations.of(context)!;
    if (isCustomerView) {
      switch (transaction.transactionType) {
        case TransactionType.purchase:
          return l10n.purchaseFromBusiness;
        case TransactionType.payment:
          return l10n.paymentMade;
        case TransactionType.credit:
          return l10n.creditReceived;
        case TransactionType.refund:
          return l10n.refundReceived;
        case TransactionType.adjustment:
          return l10n.adjustment;
      }
    } else {
      switch (transaction.transactionType) {
        case TransactionType.purchase:
          return l10n.saleToCustomer;
        case TransactionType.payment:
          return l10n.paymentReceived;
        case TransactionType.credit:
          return l10n.creditGiven;
        case TransactionType.refund:
          return l10n.refundGiven;
        case TransactionType.adjustment:
          return l10n.adjustment;
      }
    }
  }

  /// Amount color based on transaction effect
  /// For Customer: Purchase/Credit = Red (owes more), Payment/Refund = Green (owes less)
  /// For Business: Purchase/Credit = Green (receives more), Payment/Refund = Green (received)
  Color get _amountColor {
    if (isCustomerView) {
      return transaction.isDebit ? AppTheme.errorRed : AppTheme.successGreen;
    } else {
      // Business view - all incoming is good
      return transaction.isDebit ? AppTheme.successGreen : AppTheme.infoBlue;
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
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBackgroundColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _iconBackgroundColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Description and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayText(context),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateFormat.format(transaction.transactionDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
            // Amount with prefix
            Text(
              '$_amountPrefix$currency ${_formatAmount(transaction.amount)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
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
