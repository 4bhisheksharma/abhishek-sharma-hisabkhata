import 'package:flutter/material.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

/// Reusable payment ratio progress bar
class PaymentRatioBar extends StatelessWidget {
  final double toPay;
  final double totalPaid;
  final String currency;
  final bool isCustomerView;

  const PaymentRatioBar({
    super.key,
    required this.toPay,
    required this.totalPaid,
    this.currency = 'Rs.',
    this.isCustomerView = true,
  });

  double get _paidPercentage {
    final total = toPay + totalPaid;
    if (total <= 0) return 0;
    return (totalPaid / total * 100).clamp(0, 100);
  }

  String _ratioMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isCustomerView) {
      if (toPay <= 0) {
        return l10n.allDuesCleared;
      } else if (_paidPercentage >= 80) {
        return l10n.almostAllDuesPaid;
      } else if (_paidPercentage >= 50) {
        return l10n.considerClearingDues;
      } else {
        return l10n.outstandingBalance;
      }
    } else {
      if (toPay <= 0) {
        return l10n.allPaymentsCollected;
      } else if (_paidPercentage >= 80) {
        return l10n.goodCollectionRate;
      } else if (_paidPercentage >= 50) {
        return l10n.moderateCollection;
      } else {
        return l10n.pendingCollection;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Progress bar
        Container(
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppTheme.dividerColor,
          ),
          child: Stack(
            children: [
              // Paid portion (left side - green)
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _paidPercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: primaryColor,
                  ),
                  alignment: Alignment.center,
                  child: _paidPercentage > 15
                      ? Text(
                          '${_paidPercentage.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
              ),
              // To Pay amount (right side)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    '$currency${_formatAmount(toPay)}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Ratio message
        Text(
          _ratioMessage(context),
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
