import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_event.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_state.dart';
import '../bloc/connected_user_details_bloc.dart';
import '../bloc/connected_user_details_event.dart';
import '../bloc/connected_user_details_state.dart';
import '../widgets/profile_card_with_badge.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/payment_ratio_bar.dart';
import '../widgets/transactions_list.dart';
import '../../domain/entities/connected_user_details.dart';
import '../../domain/entities/transaction.dart';
import 'add_transaction_screen.dart';

/// Page showing connected user details with transactions
class ConnectedUserDetailsPage extends StatelessWidget {
  final int relationshipId;
  final bool
  isCustomerView; // true if current user is customer viewing business

  const ConnectedUserDetailsPage({
    super.key,
    required this.relationshipId,
    this.isCustomerView = true,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ConnectedUserDetailsBloc, ConnectedUserDetailsState>(
          listener: (context, state) {
            // Handle connected user details state changes if needed
          },
        ),
        BlocListener<ConnectionRequestBloc, ConnectionRequestState>(
          listener: (context, state) {
            if (state is ConnectionDeletedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            } else if (state is ConnectionRequestError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ConnectedUserDetailsBloc, ConnectedUserDetailsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(context, state),
            body: _buildBody(context, state),
            bottomNavigationBar: isCustomerView
                ? _buildPayDueButton(context, state)
                : null,
            floatingActionButton: !isCustomerView
                ? _buildAddTransactionFab(context, state)
                : null,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ConnectedUserDetailsState state,
  ) {
    String title = 'User Details';
    ConnectedUserDetails? userDetails;
    if (state is ConnectedUserDetailsLoaded) {
      title = state.userDetails.displayName;
      userDetails = state.userDetails;
    } else if (state is ConnectedUserDetailsFavoriteToggling) {
      title = state.userDetails.displayName;
      userDetails = state.userDetails;
    } else if (state is ConnectedUserDetailsTransactionCreating) {
      title = state.userDetails.displayName;
      userDetails = state.userDetails;
    }

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      centerTitle: true,
      actions: userDetails != null
          ? [
              _buildChatButton(context, userDetails),
              _buildDeleteButton(context, userDetails),
            ]
          : null,
    );
  }

  Widget _buildBody(BuildContext context, ConnectedUserDetailsState state) {
    if (state is ConnectedUserDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ConnectedUserDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ConnectedUserDetailsBloc>().add(
                  LoadConnectedUserDetails(relationshipId),
                );
              },
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    ConnectedUserDetails? userDetails;
    bool isFavoriteToggling = false;

    if (state is ConnectedUserDetailsLoaded) {
      userDetails = state.userDetails;
    } else if (state is ConnectedUserDetailsFavoriteToggling) {
      userDetails = state.userDetails;
      isFavoriteToggling = true;
    } else if (state is ConnectedUserDetailsTransactionCreating) {
      userDetails = state.userDetails;
    }

    if (userDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ConnectedUserDetailsBloc>().add(
          RefreshConnectedUserDetails(relationshipId),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header section with gradient background
            _buildHeaderSection(context, userDetails, isFavoriteToggling),
            // Content section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment ratio bar
                  PaymentRatioBar(
                    toPay: userDetails.toPay,
                    totalPaid: userDetails.totalPaid,
                    isCustomerView: isCustomerView,
                  ),
                  const SizedBox(height: 24),
                  // Transactions list
                  TransactionsList(
                    transactions: userDetails.transactions,
                    isCustomerView: isCustomerView,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    ConnectedUserDetails userDetails,
    bool isFavoriteToggling,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial summary (left side)
          Expanded(
            child: FinancialSummaryCard(
              toPay: userDetails.toPay,
              totalPaid: userDetails.totalPaid,
              isCustomerView: isCustomerView,
            ),
          ),
          const SizedBox(width: 20),
          // Profile picture with favorite badge (right side)
          ProfileCardWithBadge(
            profilePicture: userDetails.profilePicture,
            showFavorite: isCustomerView && userDetails.isBusiness,
            isFavorite: userDetails.isFavorite,
            isLoading: isFavoriteToggling,
            onFavoriteTap: () {
              if (userDetails.businessId != null) {
                context.read<ConnectedUserDetailsBloc>().add(
                  ToggleFavorite(
                    businessId: userDetails.businessId!,
                    currentStatus: userDetails.isFavorite,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPayDueButton(
    BuildContext context,
    ConnectedUserDetailsState state,
  ) {
    final isLoading = state is ConnectedUserDetailsTransactionCreating;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () => _showPayDueDialog(context, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Pay Due',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTransactionFab(
    BuildContext context,
    ConnectedUserDetailsState state,
  ) {
    ConnectedUserDetails? userDetails;
    if (state is ConnectedUserDetailsLoaded) {
      userDetails = state.userDetails;
    } else if (state is ConnectedUserDetailsFavoriteToggling) {
      userDetails = state.userDetails;
    } else if (state is ConnectedUserDetailsTransactionCreating) {
      userDetails = state.userDetails;
    }

    return FloatingActionButton(
      onPressed: () => _navigateToAddTransaction(context, userDetails),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _navigateToAddTransaction(
    BuildContext context,
    ConnectedUserDetails? userDetails,
  ) async {
    if (userDetails == null) return;

    final bloc = context.read<ConnectedUserDetailsBloc>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AddTransactionPage(
            relationshipId: relationshipId,
            customerName: userDetails.displayName,
          ),
        ),
      ),
    );

    // Refresh if transaction was added
    if (result == true) {
      bloc.add(RefreshConnectedUserDetails(relationshipId));
    }
  }

  void _showPayDueDialog(
    BuildContext context,
    ConnectedUserDetailsState state,
  ) {
    ConnectedUserDetails? userDetails;

    if (state is ConnectedUserDetailsLoaded) {
      userDetails = state.userDetails;
    } else if (state is ConnectedUserDetailsFavoriteToggling) {
      userDetails = state.userDetails;
    }

    if (userDetails == null || userDetails.toPay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noPendingDuesToPay),
        ),
      );
      return;
    }

    // Show simple pay due dialog
    showDialog(
      context: context,
      builder: (dialogContext) => _PayDueDialog(
        currentDue: userDetails!.toPay,
        onPay: (amount, description) {
          Navigator.pop(dialogContext);
          context.read<ConnectedUserDetailsBloc>().add(
            CreateTransaction(
              relationshipId: relationshipId,
              amount: amount,
              type: TransactionType.payment,
              description: description,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment of Rs. ${amount.toStringAsFixed(2)} recorded',
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatButton(
    BuildContext context,
    ConnectedUserDetails userDetails,
  ) {
    return IconButton(
      icon: const Icon(Icons.chat_bubble_outline),
      tooltip: 'Chat',
      onPressed: () => _navigateToChat(context),
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    ConnectedUserDetails userDetails,
  ) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Delete Connection',
      onPressed: () => _showDeleteConfirmation(context, userDetails),
    );
  }

  void _navigateToChat(BuildContext context) {
    // Get the other user's name from the loaded state
    final bloc = context.read<ConnectedUserDetailsBloc>();
    String? otherUserName;
    if (bloc.state is ConnectedUserDetailsLoaded) {
      final state = bloc.state as ConnectedUserDetailsLoaded;
      otherUserName = state.userDetails.displayName;
    }

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChatRoomWrapperScreen(
    //       relationshipId: relationshipId,
    //       otherUserName: otherUserName,
    //     ),
    //   ),
    // );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ConnectedUserDetails userDetails,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.deleteConnection),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(
                context,
              )!.deleteConnectionMessage(userDetails.displayName),
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            if (userDetails.toPay > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.pendingDue(
                          userDetails.toPay.abs().toStringAsFixed(2),
                        ),
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.settleBeforeDelete,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.noPendingDues,
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (userDetails.toPay <= 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Delete the connection using BLoC
                context.read<ConnectionRequestBloc>().add(
                  DeleteConnectionEvent(userId: userDetails.userId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

/// Simple dialog for customer to pay dues
class _PayDueDialog extends StatefulWidget {
  final double currentDue;
  final Function(double amount, String? description) onPay;

  const _PayDueDialog({required this.currentDue, required this.onPay});

  @override
  State<_PayDueDialog> createState() => _PayDueDialogState();
}

class _PayDueDialogState extends State<_PayDueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _payFullAmount() {
    _amountController.text = widget.currentDue.toStringAsFixed(2);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final note = _noteController.text.trim();
      widget.onPay(amount, note.isEmpty ? null : note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.payment,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay Due',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Current due: Rs. ${widget.currentDue.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: TextButton(
                    onPressed: _payFullAmount,
                    child: Text(AppLocalizations.of(context)!.payFull),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterAmount;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return AppLocalizations.of(context)!.pleaseEnterValidAmount;
                  }
                  if (amount > widget.currentDue) {
                    return AppLocalizations.of(
                      context,
                    )!.amountCannotExceedDueAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Note field (optional)
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: AppLocalizations.of(context)!.transactionNoteHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.payNow),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
