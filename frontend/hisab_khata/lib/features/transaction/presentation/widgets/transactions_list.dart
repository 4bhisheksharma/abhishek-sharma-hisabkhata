import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_list_item.dart';

/// Reusable transactions list with header and filter
class TransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final String currency;
  final VoidCallback? onFilterTap;

  const TransactionsList({
    super.key,
    required this.transactions,
    this.currency = 'Rs.',
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: onFilterTap,
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter transactions',
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Transaction list
        if (transactions.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              return TransactionListItem(
                transaction: transactions[index],
                currency: currency,
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
