import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/request/domain/entities/connected_user.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_event.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_state.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import 'package:hisab_khata/shared/widgets/user_list_item.dart';

/// A reusable widget that displays the list of connected users
/// Handles loading, empty, and error states automatically
class ConnectedUsersList extends StatefulWidget {
  final bool
  filterBusinesses; // true = show only businesses, false = show only customers
  final Function(ConnectedUser)? onUserTap;

  const ConnectedUsersList({
    super.key,
    required this.filterBusinesses,
    this.onUserTap,
  });

  @override
  State<ConnectedUsersList> createState() => _ConnectedUsersListState();
}

class _ConnectedUsersListState extends State<ConnectedUsersList> {
  @override
  void initState() {
    super.initState();
    _loadConnectedUsers();
  }

  void _loadConnectedUsers() {
    context.read<ConnectionRequestBloc>().add(const GetConnectedUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionRequestBloc, ConnectionRequestState>(
      builder: (context, state) {
        if (state is ConnectionRequestLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is ConnectionRequestError) {
          return _buildErrorState(state.message);
        }

        if (state is ConnectedUsersLoaded) {
          // Filter users based on whether we want businesses or customers
          final filteredUsers = state.connectedUsers.where((user) {
            return widget.filterBusinesses ? user.isBusiness : !user.isBusiness;
          }).toList();

          if (filteredUsers.isEmpty) {
            return _buildEmptyState();
          }

          return _buildUsersList(filteredUsers);
        }

        // Initial state - trigger load
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final emptyMessage = widget.filterBusinesses
        ? 'No connected businesses yet'
        : 'No connected customers yet';
    final emptyIcon = widget.filterBusinesses
        ? Icons.store_outlined
        : Icons.people_outline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Send connection requests to add new connections',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load connections',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadConnectedUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(List<ConnectedUser> users) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadConnectedUsers();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return UserListItem(
            name: user.displayName,
            subtitle: user.contactInfo,
            profileImageUrl: ImageUtils.getFullImageUrl(user.profilePicture),
            showBadge: user.isBusiness,
            badgeText: user.isBusiness ? 'Business' : null,
            badgeColor: AppTheme.primaryBlue,
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () {
              if (widget.onUserTap != null) {
                widget.onUserTap!(user);
              } else {
                debugPrint('Navigate to user details: ${user.userId}');
              }
            },
          );
        },
      ),
    );
  }
}
