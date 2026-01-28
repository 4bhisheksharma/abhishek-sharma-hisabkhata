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
  final Set<int> _selectedUserIds = {};
  List<UserSearchResult> _filteredUsers = [];
  String _userRole = '';
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
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

  void _handleSearch(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      // Clear results when search is empty
      setState(() {
        _filteredUsers = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _hasSearched = true;
    });

    context.read<ConnectionRequestBloc>().add(
      SearchUsersEvent(query: trimmedQuery),
    );
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
              // Clear selection and go back if fully successful
              if (response.isFullySuccessful) {
                setState(() {
                  _selectedUserIds.clear();
                });
                Navigator.of(context).pop();
              } else {
                // Remove successfully sent users from selection
                setState(() {
                  for (var result in response.successful) {
                    _selectedUserIds.remove(result.receiverId);
                  }
                  // Also remove skipped users
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionRequestBloc, ConnectionRequestState>(
      listener: (context, state) {
        if (state is BulkConnectionRequestSuccess) {
          _showBulkResultDialog(state);
        } else if (state is ConnectionRequestError) {
          MySnackbar.showError(context, state.message);
        } else if (state is UserSearchSuccess) {
          setState(() {
            // Filter out users who are already connected or have pending requests
            _filteredUsers = state.users
                .where((user) => user.canSendRequest)
                .toList();
          });
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

              // Selection info
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

              // User list
              Expanded(
                child: BlocBuilder<ConnectionRequestBloc, ConnectionRequestState>(
                  builder: (context, state) {
                    if (state is ConnectionRequestLoading &&
                        _filteredUsers.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_filteredUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasSearched
                                  ? Icons.search_off
                                  : Icons.person_search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _hasSearched
                                  ? 'No users found'
                                  : 'Search for users',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _hasSearched
                                  ? 'Try searching with a different email or phone number'
                                  : 'Use the search bar above to find users by email or phone number',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        final isSelected = _selectedUserIds.contains(
                          user.userId,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              _toggleUserSelection(user.userId);
                            },
                            title: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        user.email,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.phoneNumber != null) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.phoneNumber!,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            secondary: CircleAvatar(
                              backgroundColor: AppTheme.primaryBlue,
                              backgroundImage:
                                  user.profilePicture != null &&
                                      ImageUtils.getFullImageUrl(
                                            user.profilePicture,
                                          ) !=
                                          null
                                  ? NetworkImage(
                                      ImageUtils.getFullImageUrl(
                                        user.profilePicture,
                                      )!,
                                    )
                                  : null,
                              child:
                                  user.profilePicture == null ||
                                      ImageUtils.getFullImageUrl(
                                            user.profilePicture,
                                          ) ==
                                          null
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
                      },
                    );
                  },
                ),
              ),

              // Send button
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
                  child:
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
