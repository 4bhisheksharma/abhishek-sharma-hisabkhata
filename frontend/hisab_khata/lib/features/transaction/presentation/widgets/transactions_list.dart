import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_list_item.dart';

/// Reusable transactions list with header and filter
class TransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final String currency;
  final bool isCustomerView;
  final VoidCallback? onFilterTap;

  const TransactionsList({
    super.key,
    required this.transactions,
    this.currency = 'Rs.',
    this.isCustomerView = true,
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
            Text(
              AppLocalizations.of(context)!.transactions,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: onFilterTap,
              icon: const Icon(Icons.filter_list),
              tooltip: AppLocalizations.of(context)!.filterTransactions,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Transaction list
        if (transactions.isEmpty)
          _buildEmptyState(context)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppTheme.dividerColor),
            itemBuilder: (context, index) {
              return TransactionListItem(
                transaction: transactions[index],
                currency: currency,
                isCustomerView: isCustomerView,
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noTransactionsYet,
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            isCustomerView
                ? AppLocalizations.of(context)!.transactionsWillAppearHere
                : AppLocalizations.of(context)!.addTransactionsForCustomer,
            style: const TextStyle(fontSize: 13, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}
