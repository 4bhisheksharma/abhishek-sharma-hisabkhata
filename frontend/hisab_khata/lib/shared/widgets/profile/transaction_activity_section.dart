import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/config/route/app_router.dart';
import 'package:hisab_khata/core/data/base_remote_data_source.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import 'package:intl/intl.dart';

/// Model for a user involved in transactions on a given day
class TransactionDayUser {
  final int relationshipId;
  final int userId;
  final String displayName;
  final String? profilePicture;
  final bool isBusiness;
  final double amountTotal;
  final int transactionCount;

  const TransactionDayUser({
    required this.relationshipId,
    required this.userId,
    required this.displayName,
    this.profilePicture,
    required this.isBusiness,
    required this.amountTotal,
    required this.transactionCount,
  });

  factory TransactionDayUser.fromJson(Map<String, dynamic> json) {
    return TransactionDayUser(
      relationshipId: json['relationship_id'] as int,
      userId: json['user_id'] as int,
      displayName: json['display_name'] as String,
      profilePicture: json['profile_picture'] as String?,
      isBusiness: json['is_business'] as bool,
      amountTotal: double.parse(json['amount_total'].toString()),
      transactionCount: json['transaction_count'] as int,
    );
  }
}

/// Model for a single day of transaction activity
class TransactionDay {
  final DateTime date;
  final double totalAmount;
  final int transactionCount;
  final List<TransactionDayUser> users;

  const TransactionDay({
    required this.date,
    required this.totalAmount,
    required this.transactionCount,
    required this.users,
  });

  factory TransactionDay.fromJson(Map<String, dynamic> json) {
    return TransactionDay(
      date: DateTime.parse(json['date'] as String),
      totalAmount: double.parse(json['total_amount'].toString()),
      transactionCount: json['transaction_count'] as int,
      users: (json['users'] as List<dynamic>)
          .map((u) => TransactionDayUser.fromJson(u as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Data source for fetching transaction activity
class TransactionActivityDataSource extends BaseRemoteDataSource {
  TransactionActivityDataSource();

  Future<List<TransactionDay>> getTransactionActivity({int days = 30}) async {
    final response = await get(
      'transaction/activity/',
      queryParameters: {'days': days.toString()},
    );

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((json) => TransactionDay.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Widget showing transaction activity days in the profile screen.
/// Each day shows who the user transacted with and tapping navigates
/// to the connected user details screen.
class TransactionActivitySection extends StatefulWidget {
  final bool isCustomerView;

  const TransactionActivitySection({super.key, required this.isCustomerView});

  @override
  State<TransactionActivitySection> createState() =>
      _TransactionActivitySectionState();
}

class _TransactionActivitySectionState
    extends State<TransactionActivitySection> {
  final _dataSource = TransactionActivityDataSource();
  List<TransactionDay>? _activityDays;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _dataSource.getTransactionActivity(days: 30);
      if (mounted) {
        setState(() {
          _activityDays = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final loc = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return loc.today;
    if (diff == 1) return loc.yesterday;
    if (diff < 7) return loc.thisWeek;
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10, top: 2),
          child: Text(
            loc.transactionActivity.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
        ),

        // Content card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildContent(context, loc),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations loc) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
              const SizedBox(height: 8),
              Text(
                loc.error,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadActivity, child: Text(loc.retry)),
            ],
          ),
        ),
      );
    }

    if (_activityDays == null || _activityDays!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Colors.grey[400],
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                loc.noTransactionActivity,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                loc.noTransactionActivitySubtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < _activityDays!.length; i++) ...[
          _buildDaySection(context, _activityDays![i]),
          if (i < _activityDays!.length - 1)
            Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
        ],
      ],
    );
  }

  Widget _buildDaySection(BuildContext context, TransactionDay day) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(context, day.date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rs. ${day.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // User tiles for this day
        for (final user in day.users) _buildUserTile(context, user, loc),

        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    TransactionDayUser user,
    AppLocalizations loc,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.connectedUserDetails,
            arguments: ConnectedUserDetailsArgs(
              relationshipId: user.relationshipId,
              isCustomerView: widget.isCustomerView,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 20,
                backgroundColor: user.isBusiness
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFF3E5F5),
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(
                        ImageUtils.getFullImageUrl(user.profilePicture!) ?? '',
                      )
                    : null,
                child: user.profilePicture == null
                    ? Icon(
                        user.isBusiness
                            ? Icons.store_rounded
                            : Icons.person_rounded,
                        size: 20,
                        color: user.isBusiness
                            ? const Color(0xFF4A90E2)
                            : const Color(0xFF9C27B0),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Name and transaction count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.transactionCount} ${user.transactionCount == 1 ? loc.transactionSingular : loc.transactions}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${user.amountTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
