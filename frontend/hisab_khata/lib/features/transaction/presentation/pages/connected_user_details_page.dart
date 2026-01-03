import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/connected_user_details_bloc.dart';
import '../bloc/connected_user_details_event.dart';
import '../bloc/connected_user_details_state.dart';
import '../widgets/profile_card_with_badge.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/payment_ratio_bar.dart';
import '../widgets/transactions_list.dart';
import '../../domain/entities/connected_user_details.dart';

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
    return BlocBuilder<ConnectedUserDetailsBloc, ConnectedUserDetailsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
          bottomNavigationBar: isCustomerView
              ? _buildPayDueButton(context, state)
              : null,
          floatingActionButton: !isCustomerView
              ? _buildMessageFab(context)
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ConnectedUserDetailsState state,
  ) {
    String title = 'User Details';
    if (state is ConnectedUserDetailsLoaded) {
      title = state.userDetails.displayName;
    } else if (state is ConnectedUserDetailsFavoriteToggling) {
      title = state.userDetails.displayName;
    } else if (state is ConnectedUserDetailsTransactionCreating) {
      title = state.userDetails.displayName;
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
              child: const Text('Retry'),
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
                  ),
                  const SizedBox(height: 24),
                  // Transactions list
                  TransactionsList(transactions: userDetails.transactions),
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
            color: Colors.black.withOpacity(0.05),
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
            onPressed: isLoading ? null : () => _showPayDueDialog(context),
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

  Widget _buildMessageFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Open messaging/chat
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.message, color: Colors.white),
    );
  }

  void _showPayDueDialog(BuildContext context) {
    // TODO: Implement pay due dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pay Due feature coming soon!')),
    );
  }
}
