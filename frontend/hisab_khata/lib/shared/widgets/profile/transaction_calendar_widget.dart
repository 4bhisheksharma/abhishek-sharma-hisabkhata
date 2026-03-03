import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/config/route/app_router.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import 'package:hisab_khata/shared/widgets/profile/transaction_activity_section.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

/// A Nepali calendar widget that shows transaction history.
/// Tapping a date shows the transaction details for that day.
/// Tapping a user navigates to the connected user details screen.
class TransactionCalendarWidget extends StatefulWidget {
  final bool isCustomerView;

  const TransactionCalendarWidget({super.key, required this.isCustomerView});

  @override
  State<TransactionCalendarWidget> createState() =>
      _TransactionCalendarWidgetState();
}

class _TransactionCalendarWidgetState extends State<TransactionCalendarWidget> {
  final _dataSource = TransactionActivityDataSource();
  List<TransactionDay>? _activityDays;
  bool _isLoading = true;
  String? _error;

  NepaliDateTime _selectedDate = NepaliDateTime.now();

  /// Map of date string (yyyy-MM-dd) -> TransactionDay for quick lookup
  Map<String, TransactionDay> _transactionsByDate = {};

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
      // Load 90 days of activity for broader calendar coverage
      final data = await _dataSource.getTransactionActivity(days: 90);
      if (mounted) {
        setState(() {
          _activityDays = data;
          _transactionsByDate = {};
          for (final day in data) {
            final nepDate = day.date.toNepaliDateTime();
            final key =
                '${nepDate.year}-${nepDate.month.toString().padLeft(2, '0')}-${nepDate.day.toString().padLeft(2, '0')}';
            _transactionsByDate[key] = day;
          }
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

  /// Get selected date key
  String get _selectedDateKey {
    return '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  /// Get transactions for selected date
  TransactionDay? get _selectedDayTransactions {
    return _transactionsByDate[_selectedDateKey];
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
            loc.transactionCalendar.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
        ),

        // Calendar card
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

    return Column(
      children: [
        // Nepali Calendar using CalendarDatePicker with NepaliCalendarDelegate
        _buildCalendar(context),

        const Divider(height: 1, thickness: 0.5),

        // Transaction indicators legend
        if (_activityDays != null && _activityDays!.isNotEmpty)
          _buildLegend(context, loc),

        // Selected date transactions
        _buildSelectedDateTransactions(context, loc),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: AppTheme.primaryBlue,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppTheme.textPrimary,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryBlue),
        ),
      ),
      child: CalendarDatePicker(
        initialDate: _selectedDate,
        firstDate: NepaliDateTime(2070, 1, 1),
        lastDate: NepaliDateTime(2100, 12, 30),
        calendarDelegate: const NepaliCalendarDelegate(),
        onDateChanged: (DateTime date) {
          setState(() {
            _selectedDate = date as NepaliDateTime;
          });
        },
      ),
    );
  }

  Widget _buildLegend(BuildContext context, AppLocalizations loc) {
    final selectedHasData = _selectedDayTransactions != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${_activityDays!.length} ${loc.daysWithTransactions}',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const Spacer(),
          if (selectedHasData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Rs. ${_selectedDayTransactions!.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateTransactions(
    BuildContext context,
    AppLocalizations loc,
  ) {
    final dayData = _selectedDayTransactions;

    if (dayData == null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_available_outlined,
                color: Colors.grey[400],
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                loc.noTransactionsOnDate,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Format date header in Nepali
    final nepDateStr =
        '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header with total
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    nepDateStr,
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
                  loc.transactionsOnDate(dayData.transactionCount.toString()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ),

        // User tiles
        for (final user in dayData.users) _buildUserTile(context, user, loc),

        const SizedBox(height: 8),
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
              Text(
                'Rs. ${user.amountTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
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
