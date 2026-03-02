import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/realtime_chat/presentation/bloc/chat_provider.dart';
import 'package:hisab_khata/features/realtime_chat/presentation/screens/chat_detail_screen.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_event.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_state.dart';
import 'package:hisab_khata/core/di/dependency_injection.dart';
import '../bloc/connected_user_details_bloc.dart';
import '../bloc/connected_user_details_event.dart';
import '../bloc/connected_user_details_state.dart';
import '../bloc/esewa_payment_bloc.dart';
import '../bloc/esewa_payment_event.dart';
import '../widgets/profile_card_with_badge.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/payment_ratio_bar.dart';
import '../widgets/transactions_list.dart';
import '../widgets/pay_due_with_esewa_dialog.dart';
import '../../domain/entities/connected_user_details.dart';
import '../../domain/entities/transaction.dart';
import 'add_transaction_screen.dart';
import 'package:hisab_khata/shared/widgets/shimmer/shimmer_widgets.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';

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
              MySnackbar.showSuccess(context, state.message);
              Navigator.of(context).pop();
            } else if (state is ConnectionRequestError) {
              MySnackbar.showError(context, state.message);
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
                : _buildClearDueButton(context, state),
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
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
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
      return const UserDetailsShimmer();
    }

    if (state is ConnectedUserDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(color: AppTheme.textSecondary),
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
      return const UserDetailsShimmer();
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
        color: AppTheme.surfaceGrey,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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

  /// Bottom bar for business to clear a customer's due (cash payment)
  Widget _buildClearDueButton(
    BuildContext context,
    ConnectedUserDetailsState state,
  ) {
    final isLoading = state is ConnectedUserDetailsTransactionCreating;

    // Extract user details
    ConnectedUserDetails? userDetails;
    if (state is ConnectedUserDetailsLoaded) {
      userDetails = state.userDetails;
    } else if (state is ConnectedUserDetailsFavoriteToggling) {
      userDetails = state.userDetails;
    } else if (state is ConnectedUserDetailsTransactionCreating) {
      userDetails = state.userDetails;
    }

    // Only show if there's pending due
    final hasDue = userDetails != null && userDetails.toPay > 0;

    if (!hasDue) return const SizedBox.shrink();

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
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () => _showClearDueDialog(context, state),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.payments_outlined, size: 20),
            label: Text(
              isLoading ? 'Processing...' : 'Clear Due (Cash)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  void _showClearDueDialog(
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
      MySnackbar.showInfo(context, 'No pending dues to clear');
      return;
    }

    final bloc = context.read<ConnectedUserDetailsBloc>();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Clear Due (Cash)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pending: Rs. ${userDetails!.toPay.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppTheme.primaryDark,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Record cash payment received from ${userDetails.displayName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Amount field
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Amount Received',
                      prefixText: 'Rs. ',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      suffixIcon: TextButton(
                        onPressed: () {
                          amountController.text = userDetails!.toPay
                              .toStringAsFixed(2);
                        },
                        child: const Text('Full'),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterAmount;
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return AppLocalizations.of(
                          context,
                        )!.pleaseEnterValidAmount;
                      }
                      if (amount > userDetails!.toPay) {
                        return AppLocalizations.of(
                          context,
                        )!.amountCannotExceedDueAmount;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Note field
                  TextFormField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      hintText: 'e.g. Cash received',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
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
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            final amount = double.parse(amountController.text);
                            final note = noteController.text.trim();

                            bloc.add(
                              CreateTransaction(
                                relationshipId: relationshipId,
                                amount: amount,
                                type: TransactionType.payment,
                                description: note.isEmpty
                                    ? 'Cash payment received'
                                    : note,
                              ),
                            );
                            Navigator.pop(dialogContext);
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text(
                            'Clear Due',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      MySnackbar.showInfo(
        context,
        AppLocalizations.of(context)!.noPendingDuesToPay,
      );
      return;
    }

    final detailsBloc = context.read<ConnectedUserDetailsBloc>();

    // Show eSewa-enabled pay due dialog — status tracking is internal
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: detailsBloc),
          BlocProvider<EsewaPaymentBloc>(
            create: (_) =>
                DependencyInjection().createEsewaPaymentBloc()
                  ..add(CheckEsewaStatus(relationshipId)),
          ),
        ],
        child: PayDueWithEsewaDialog(
          currentDue: userDetails!.toPay,
          relationshipId: relationshipId,
        ),
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
    // Get the other user's info from the loaded state
    final bloc = context.read<ConnectedUserDetailsBloc>();
    int? otherUserId;
    String? otherUserName;

    if (bloc.state is ConnectedUserDetailsLoaded) {
      final state = bloc.state as ConnectedUserDetailsLoaded;
      otherUserId = state.userDetails.userId;
      otherUserName = state.userDetails.displayName;
    } else if (bloc.state is ConnectedUserDetailsFavoriteToggling) {
      final state = bloc.state as ConnectedUserDetailsFavoriteToggling;
      otherUserId = state.userDetails.userId;
      otherUserName = state.userDetails.displayName;
    } else if (bloc.state is ConnectedUserDetailsTransactionCreating) {
      final state = bloc.state as ConnectedUserDetailsTransactionCreating;
      otherUserId = state.userDetails.userId;
      otherUserName = state.userDetails.displayName;
    }

    if (otherUserId == null) {
      MySnackbar.showError(context, 'Unable to open chat. Please try again.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatProvider(
          child: ChatDetailScreen(
            chatRoomId: 0, // Will be created/fetched when screen loads
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          ),
        ),
      ),
    );
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
              style: const TextStyle(
                color: AppTheme.textSecondary,
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
