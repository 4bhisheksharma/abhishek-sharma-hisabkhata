import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/route/app_router.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/features/request/domain/entities/connected_user.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_event.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_state.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/shared/widgets/shimmer/shimmer_widgets.dart';

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
    return BlocConsumer<ConnectionRequestBloc, ConnectionRequestState>(
      listener: (context, state) {
        if (state is ConnectionRequestError) {
          MySnackbar.showError(context, state.message);
        }
      },
      buildWhen: (previous, current) {
        // Only rebuild for states relevant to this widget
        return current is ConnectionRequestLoading ||
            current is ConnectionRequestError ||
            current is ConnectedUsersLoaded;
      },
      builder: (context, state) {
        if (state is ConnectionRequestLoading) {
          return const ConnectedUsersListShimmer();
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

        // Initial/unrelated state - trigger load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadConnectedUsers();
        });
        return const ConnectedUsersListShimmer();
      },
    );
  }

  Widget _buildEmptyState() {
    final emptyMessage = widget.filterBusinesses
        ? AppLocalizations.of(context)!.noConnectedBusinesses
        : AppLocalizations.of(context)!.noConnectedCustomers;
    final emptyIcon = widget.filterBusinesses
        ? Icons.store_mall_directory_outlined
        : Icons.people_alt_outlined;
    final emptySubtitle = widget.filterBusinesses
        ? AppLocalizations.of(context)!.connectWithBusinesses
        : AppLocalizations.of(context)!.connectWithCustomers;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyIcon,
                size: 80,
                color: AppTheme.primaryBlue.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 20,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              emptySubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addConnection);
              },
              icon: const Icon(Icons.person_add_rounded),
              label: Text(AppLocalizations.of(context)!.addConnection),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 80,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.failedToLoadConnections,
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadConnectedUsers,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
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
      color: AppTheme.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(
                  widget.filterBusinesses
                      ? Icons.store_outlined
                      : Icons.people_outlined,
                  size: 20,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.filterBusinesses
                      ? AppLocalizations.of(context)!.connectedBusinesses
                      : AppLocalizations.of(context)!.connectedCustomers,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${users.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildEnhancedUserCard(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedUserCard(ConnectedUser user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      child: InkWell(
        onTap: () {
          if (widget.onUserTap != null) {
            widget.onUserTap!(user);
          } else {
            Navigator.pushNamed(
              context,
              AppRoutes.connectedUserDetails,
              arguments: ConnectedUserDetailsArgs(
                relationshipId: user.relationshipId,
                isCustomerView: widget.filterBusinesses,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile Image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.8),
                      AppTheme.primaryBlue,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user.profilePicture != null
                      ? Image.network(
                          ImageUtils.getFullImageUrl(user.profilePicture)!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar(user.displayName);
                          },
                        )
                      : _buildDefaultAvatar(user.displayName),
                ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isBusiness) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 12,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(context)!.business,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            user.contactInfo,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Arrow Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.8),
            AppTheme.primaryBlue,
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
