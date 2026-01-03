import 'package:flutter/material.dart';

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

  String get _ratioMessage {
    if (isCustomerView) {
      // Customer view - focus on payment status
      if (toPay <= 0) {
        return '✓ All dues cleared!';
      } else if (_paidPercentage >= 80) {
        return '✓ Great! Almost all dues paid';
      } else if (_paidPercentage >= 50) {
        return '⚠ Consider clearing pending dues';
      } else {
        return '⚠ Outstanding balance pending';
      }
    } else {
      // Business view - focus on collection status
      if (toPay <= 0) {
        return '✓ All payments collected';
      } else if (_paidPercentage >= 80) {
        return '✓ Good collection rate';
      } else if (_paidPercentage >= 50) {
        return '📊 Moderate collection';
      } else {
        return '📊 Pending collection';
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
            color: Colors.grey.shade200,
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
                      color: Colors.grey.shade700,
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
          _ratioMessage,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
