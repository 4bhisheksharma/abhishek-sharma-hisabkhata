import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/utils/image_utils.dart';
import '../../../../shared/widgets/my_snackbar.dart';
import '../../domain/entities/connection_request.dart';
import '../bloc/connection_request_bloc.dart';
import '../bloc/connection_request_event.dart';
import '../bloc/connection_request_state.dart';

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
    context.read<ConnectionRequestBloc>().add(
      UpdateRequestStatusEvent(requestId: requestId, status: 'rejected'),
    );
  }

  void _cancelRequest(int requestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
          'Are you sure you want to cancel this connection request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ConnectionRequestBloc>().add(
                CancelConnectionRequestEvent(requestId: requestId),
              );
            },
            child: const Text('Yes, Cancel'),
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
    return 'Just now';
  }

  Widget _buildAvatar(String? profilePicture, String name) {
    final imageUrl = ImageUtils.getFullImageUrl(profilePicture);
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppTheme.primaryBlue,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
        label = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
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
            color: color.withOpacity(0.15),
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
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
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
        title: 'No Received Requests',
        subtitle:
            'When someone sends you a connection request, it will appear here.',
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
              'Pending Requests',
              pending.length,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            ...pending.map(_buildReceivedCard),
            const SizedBox(height: 16),
          ],
          if (others.isNotEmpty) ...[
            _buildSectionHeader('Past Requests', others.length, Colors.grey),
            const SizedBox(height: 8),
            ...others.map(_buildReceivedCard),
          ],
        ],
      ),
    );
  }

  Widget _buildReceivedCard(ConnectionRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.senderEmail,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (request.senderPhone != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          request.senderPhone!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
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
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                      label: const Text('Reject'),
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
                      label: const Text('Accept'),
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
        title: 'No Sent Requests',
        subtitle: 'Connection requests you send will appear here.',
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
              'Awaiting Response',
              pending.length,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            ...pending.map(_buildSentCard),
            const SizedBox(height: 16),
          ],
          if (others.isNotEmpty) ...[
            _buildSectionHeader('Past Requests', others.length, Colors.grey),
            const SizedBox(height: 8),
            ...others.map(_buildSentCard),
          ],
        ],
      ),
    );
  }

  Widget _buildSentCard(ConnectionRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.receiverEmail,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if (request.receiverPhone != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          request.receiverPhone!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
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
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                  label: const Text('Cancel Request'),
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
                  color: Colors.black.withOpacity(0.05),
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
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 18),
                      SizedBox(width: 6),
                      Text('Received'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 18),
                      SizedBox(width: 6),
                      Text('Sent'),
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
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                  );
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
                          child: const Text('Retry'),
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

                // Initial / unknown state — show loader
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
