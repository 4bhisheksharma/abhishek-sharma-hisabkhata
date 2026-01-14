import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/my_snackbar.dart';
import '../bloc/connection_request_bloc.dart';
import '../bloc/connection_request_event.dart';
import '../bloc/connection_request_state.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  State<ConnectionRequestsScreen> createState() =>
      _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch pending received requests when screen loads
    context.read<ConnectionRequestBloc>().add(
      const GetPendingReceivedRequestsEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.connectionRequests,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.lightBlue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: BlocConsumer<ConnectionRequestBloc, ConnectionRequestState>(
          listener: (context, state) {
            if (state is ConnectionRequestError) {
              MySnackbar.showError(context, state.message);
            } else if (state is RequestStatusUpdated) {
              MySnackbar.showSuccess(context, state.message);
              // Refresh the list after accepting/rejecting
              context.read<ConnectionRequestBloc>().add(
                const GetPendingReceivedRequestsEvent(),
              );
            }
          },
          builder: (context, state) {
            if (state is ConnectionRequestLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue),
              );
            }

            if (state is PendingReceivedRequestsLoaded) {
              if (state.requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 80, color: Colors.black26),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noPendingRequests,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return _ConnectionRequestCard(
                    senderName: request.senderName,
                    senderEmail: request.senderEmail,
                    createdAt: request.createdAt,
                    onAccept: () {
                      context.read<ConnectionRequestBloc>().add(
                        UpdateRequestStatusEvent(
                          requestId: request.businessCustomerRequestId,
                          status: 'accepted',
                        ),
                      );
                    },
                    onReject: () {
                      context.read<ConnectionRequestBloc>().add(
                        UpdateRequestStatusEvent(
                          requestId: request.businessCustomerRequestId,
                          status: 'rejected',
                        ),
                      );
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ConnectionRequestCard extends StatelessWidget {
  final String senderName;
  final String senderEmail;
  final DateTime createdAt;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ConnectionRequestCard({
    required this.senderName,
    required this.senderEmail,
    required this.createdAt,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      senderEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, size: 20),
                  label: Text(AppLocalizations.of(context)!.accept),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 20),
                  label: Text(AppLocalizations.of(context)!.reject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
