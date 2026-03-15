import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/image_utils.dart';
import '../../../../shared/widgets/my_snackbar.dart';
import '../../domain/entities/connection_request.dart';
import '../bloc/connection_request_bloc.dart';
import '../bloc/connection_request_event.dart';
import '../bloc/connection_request_state.dart';
import '../../../../shared/widgets/shimmer/shimmer_widgets.dart';

/// Tabbed screen showing Received and Sent connection requests.
/// Embedded directly inside the home screen's IndexedStack (nav index 2).
class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  State<ConnectionRequestsScreen> createState() =>
      _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRequests() {
    context.read<ConnectionRequestBloc>().add(
      const FetchAllConnectionRequestsEvent(),
    );
  }

  void _acceptRequest(int requestId) {
    context.read<ConnectionRequestBloc>().add(
      UpdateRequestStatusEvent(requestId: requestId, status: 'accepted'),
    );
  }

  void _rejectRequest(int requestId) {
    // Rejecting a request deletes it from the backend, allowing the sender to send again
    context.read<ConnectionRequestBloc>().add(
      UpdateRequestStatusEvent(requestId: requestId, status: 'rejected'),
    );
  }

  void _cancelRequest(int requestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.cancelRequest),
        content: Text(AppLocalizations.of(ctx)!.cancelRequestConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(ctx)!.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ConnectionRequestBloc>().add(
                CancelConnectionRequestEvent(requestId: requestId),
              );
            },
            child: Text(AppLocalizations.of(ctx)!.yesCancel),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return AppLocalizations.of(context)!.justNow;
  }

  Widget _buildAvatar(String? profilePicture, String name) {
    final imageUrl = ImageUtils.getFullImageUrl(profilePicture);
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppTheme.lightBlue,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            )
          : null,
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color color;
    final String label;
    final IconData icon;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = AppLocalizations.of(context)!.pending;
        icon = Icons.hourglass_empty;
        break;
      case 'accepted':
        color = Colors.green;
        label = AppLocalizations.of(context)!.accepted;
        icon = Icons.check_circle_outline;
        break;
      case 'rejected': // Should not occur as rejected requests are deleted
        color = Colors.red;
        label = AppLocalizations.of(context)!.rejected;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.primaryBlue.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Received Tab ───────────────────────────────────────────────────────

  Widget _buildReceivedTab(List<ConnectionRequest> requests) {
    final pending = requests.where((r) => r.status == 'pending').toList();
    final others = requests.where((r) => r.status != 'pending').toList();

    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: AppLocalizations.of(context)!.noReceivedRequests,
        subtitle: AppLocalizations.of(context)!.whenSomeoneSendsRequest,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadRequests();
        await context.read<ConnectionRequestBloc>().stream.firstWhere(
          (s) =>
              s is AllConnectionRequestsLoaded || s is ConnectionRequestError,
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            _buildSectionHeader(
              AppLocalizations.of(context)!.pendingRequests,
              pending.length,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            ...pending.map(_buildReceivedCard),
            const SizedBox(height: 16),
          ],
          if (others.isNotEmpty) ...[
            _buildSectionHeader(
              AppLocalizations.of(context)!.pastRequests,
              others.length,
              Colors.grey,
            ),
            const SizedBox(height: 8),
            ...others.map(_buildReceivedCard),
          ],
        ],
      ),
    );
  }

  Widget _buildReceivedCard(ConnectionRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(request.senderProfilePicture, request.senderName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.senderEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (request.senderPhone != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          request.senderPhone!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(request.status),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(request.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (request.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _rejectRequest(request.businessCustomerRequestId),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(AppLocalizations.of(context)!.reject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _acceptRequest(request.businessCustomerRequestId),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(AppLocalizations.of(context)!.accept),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Sent Tab ───────────────────────────────────────────────────────────

  Widget _buildSentTab(List<ConnectionRequest> requests) {
    final pending = requests.where((r) => r.status == 'pending').toList();
    final others = requests.where((r) => r.status != 'pending').toList();

    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_outlined,
        title: AppLocalizations.of(context)!.noSentRequests,
        subtitle: AppLocalizations.of(context)!.sentRequestsWillAppear,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadRequests();
        await context.read<ConnectionRequestBloc>().stream.firstWhere(
          (s) =>
              s is AllConnectionRequestsLoaded || s is ConnectionRequestError,
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            _buildSectionHeader(
              AppLocalizations.of(context)!.awaitingResponse,
              pending.length,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            ...pending.map(_buildSentCard),
            const SizedBox(height: 16),
          ],
          if (others.isNotEmpty) ...[
            _buildSectionHeader(
              AppLocalizations.of(context)!.pastRequests,
              others.length,
              Colors.grey,
            ),
            const SizedBox(height: 8),
            ...others.map(_buildSentCard),
          ],
        ],
      ),
    );
  }

  Widget _buildSentCard(ConnectionRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(
                  request.receiverProfilePicture,
                  request.receiverName,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.receiverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.receiverEmail,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (request.receiverPhone != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          request.receiverPhone!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(request.status),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(request.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (request.isPending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _cancelRequest(request.businessCustomerRequestId),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(AppLocalizations.of(context)!.cancelRequest),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionRequestBloc, ConnectionRequestState>(
      listener: (context, state) {
        if (state is RequestStatusUpdated) {
          MySnackbar.showSuccess(context, state.message);
          _loadRequests();
        } else if (state is ConnectionRequestError) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 18),
                      SizedBox(width: 6),
                      Text(AppLocalizations.of(context)!.received),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 18),
                      SizedBox(width: 6),
                      Text(AppLocalizations.of(context)!.sent),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: BlocBuilder<ConnectionRequestBloc, ConnectionRequestState>(
              buildWhen: (previous, current) =>
                  current is AllConnectionRequestsLoaded ||
                  current is ConnectionRequestLoading ||
                  current is ConnectionRequestError,
              builder: (context, state) {
                if (state is ConnectionRequestLoading) {
                  return const ConnectionRequestsShimmer();
                }

                if (state is ConnectionRequestError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.red[400]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRequests,
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AllConnectionRequestsLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReceivedTab(state.receivedRequests),
                      _buildSentTab(state.sentRequests),
                    ],
                  );
                }

                // Initial / unknown state — trigger load
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _loadRequests();
                });
                return const ConnectionRequestsShimmer();
              },
            ),
          ),
        ],
      ),
    );
  }
}
