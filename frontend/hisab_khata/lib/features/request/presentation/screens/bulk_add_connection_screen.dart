import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_event.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_state.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import '../../../../config/storage/storage_service.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/utils/image_utils.dart';
import '../../../../shared/widgets/my_button.dart';
import '../../../../shared/widgets/my_snackbar.dart';
import '../../domain/entities/user_search_result.dart';

class BulkAddConnectionScreen extends StatefulWidget {
  const BulkAddConnectionScreen({super.key});

  @override
  State<BulkAddConnectionScreen> createState() =>
      _BulkAddConnectionScreenState();
}

class _BulkAddConnectionScreenState extends State<BulkAddConnectionScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final Set<int> _selectedUserIds = {};
  String _userRole = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _scrollController.addListener(_onScroll);

    // Load first page of all users immediately
    context.read<ConnectionRequestBloc>().add(const FetchPaginatedUsersEvent());
  }

  Future<void> _loadUserRole() async {
    final user = await StorageService.getUserData();
    setState(() {
      _userRole = user?.roles.isNotEmpty == true ? user!.roles.first : '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String get _appBarTitle {
    if (_userRole.toLowerCase() == 'business') {
      return 'Add Multiple Customers';
    } else if (_userRole.toLowerCase() == 'customer') {
      return 'Add Multiple Businesses';
    }
    return 'Add Multiple Connections';
  }

  /// Triggers loading the next page when scrolled near the bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ConnectionRequestBloc>().state;
      if (state is PaginatedUsersLoaded &&
          state.hasMore &&
          !state.isLoadingMore) {
        context.read<ConnectionRequestBloc>().add(const LoadMoreUsersEvent());
      }
    }
  }

  /// Debounced search — waits 400ms after the user stops typing
  void _handleSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final trimmedQuery = query.trim();
      context.read<ConnectionRequestBloc>().add(
        FetchPaginatedUsersEvent(
          search: trimmedQuery.isEmpty ? null : trimmedQuery,
        ),
      );
    });
  }

  void _toggleUserSelection(int userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _handleSendBulkRequests() {
    if (_selectedUserIds.isEmpty) {
      MySnackbar.showError(
        context,
        'Please select at least one user to send connection requests.',
      );
      return;
    }

    context.read<ConnectionRequestBloc>().add(
      SendBulkConnectionRequestEvent(receiverIds: _selectedUserIds.toList()),
    );
  }

  void _showBulkResultDialog(BulkConnectionRequestSuccess state) {
    final response = state.response;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bulkRequestResults),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                response.message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (response.successful.isNotEmpty) ...[
                Text(
                  '✓ ${AppLocalizations.of(context)!.successful} (${response.successful.length}):',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...response.successful.map(
                  (result) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text(
                      '• ${result.receiverName ?? result.receiverEmail}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (response.skipped.isNotEmpty) ...[
                Text(
                  '⊘ ${AppLocalizations.of(context)!.skipped} (${response.skipped.length}):',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...response.skipped.map(
                  (result) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${result.receiverName ?? result.receiverEmail}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (result.error != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              result.error!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (response.failed.isNotEmpty) ...[
                Text(
                  '✗ ${AppLocalizations.of(context)!.failed} (${response.failed.length}):',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...response.failed.map(
                  (result) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${result.receiverName ?? result.receiverEmail}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (result.error != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              result.error!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (response.isFullySuccessful) {
                setState(() {
                  _selectedUserIds.clear();
                });
                Navigator.of(context).pop();
              } else {
                setState(() {
                  for (var result in response.successful) {
                    _selectedUserIds.remove(result.receiverId);
                  }
                  for (var result in response.skipped) {
                    _selectedUserIds.remove(result.receiverId);
                  }
                });
              }
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserSearchResult user) {
    final isSelected = _selectedUserIds.contains(user.userId);
    final canSelect = user.canSendRequest;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          width: 2,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: canSelect
            ? (value) => _toggleUserSelection(user.userId)
            : null,
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (user.connectionStatus != null)
              _buildStatusChip(user.connectionStatus!),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(user.email, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(user.phoneNumber!, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ],
        ),
        secondary: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue,
          backgroundImage:
              user.profilePicture != null &&
                  ImageUtils.getFullImageUrl(user.profilePicture) != null
              ? NetworkImage(ImageUtils.getFullImageUrl(user.profilePicture)!)
              : null,
          child:
              user.profilePicture == null ||
                  ImageUtils.getFullImageUrl(user.profilePicture) == null
              ? Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        activeColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Connected';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionRequestBloc, ConnectionRequestState>(
      listener: (context, state) {
        if (state is BulkConnectionRequestSuccess) {
          _showBulkResultDialog(state);
        } else if (state is ConnectionRequestError) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryBlue,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _appBarTitle,
            style: const TextStyle(
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
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    return TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, or phone...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: value.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _handleSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: _handleSearch,
                    );
                  },
                ),
              ),

              // Selection info bar
              if (_selectedUserIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedUserIds.length} user(s) selected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedUserIds.clear();
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),

              // User list with infinite scroll
              Expanded(
                child: BlocBuilder<ConnectionRequestBloc, ConnectionRequestState>(
                  buildWhen: (previous, current) =>
                      current is PaginatedUsersLoaded ||
                      current is ConnectionRequestLoading ||
                      current is ConnectionRequestError,
                  builder: (context, state) {
                    // Initial loading
                    if (state is ConnectionRequestLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Error state
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
                              onPressed: () {
                                context.read<ConnectionRequestBloc>().add(
                                  const FetchPaginatedUsersEvent(),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Loaded state
                    if (state is PaginatedUsersLoaded) {
                      if (state.users.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                state.searchQuery != null
                                    ? Icons.search_off
                                    : Icons.people_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.searchQuery != null
                                    ? 'No users found for "${state.searchQuery}"'
                                    : 'No users available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          final search = _searchController.text.trim();
                          context.read<ConnectionRequestBloc>().add(
                            FetchPaginatedUsersEvent(
                              search: search.isEmpty ? null : search,
                            ),
                          );
                          await context
                              .read<ConnectionRequestBloc>()
                              .stream
                              .firstWhere(
                                (s) =>
                                    s is PaginatedUsersLoaded ||
                                    s is ConnectionRequestError,
                              );
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount:
                              state.users.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Loading indicator at the bottom
                            if (index == state.users.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return _buildUserTile(state.users[index]);
                          },
                        ),
                      );
                    }

                    // Default — show loading
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),

              // Total count + Send button
              Container(
                padding: const EdgeInsets.all(16),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show total count
                      BlocBuilder<
                        ConnectionRequestBloc,
                        ConnectionRequestState
                      >(
                        buildWhen: (_, current) =>
                            current is PaginatedUsersLoaded,
                        builder: (context, state) {
                          if (state is PaginatedUsersLoaded) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${state.totalCount} user(s) available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      BlocBuilder<
                        ConnectionRequestBloc,
                        ConnectionRequestState
                      >(
                        builder: (context, state) {
                          final isLoading = state is ConnectionRequestLoading;
                          final canSend =
                              _selectedUserIds.isNotEmpty && !isLoading;

                          return MyButton(
                            text: 'Send Requests (${_selectedUserIds.length})',
                            onPressed: canSend
                                ? _handleSendBulkRequests
                                : () {},
                            isLoading: isLoading,
                            width: double.infinity,
                            height: 50,
                            borderRadius: 12,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
