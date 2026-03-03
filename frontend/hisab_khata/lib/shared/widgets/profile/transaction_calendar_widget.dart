import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/config/route/app_router.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import 'package:hisab_khata/shared/widgets/profile/transaction_activity_section.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

// Short weekday labels (Sun-first order)
const _kWeekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

// Nepali month names in English
const _kNepaliMonths = [
  'Baisakh',
  'Jestha',
  'Ashadh',
  'Shrawan',
  'Bhadra',
  'Ashwin',
  'Kartik',
  'Mangsir',
  'Poush',
  'Magh',
  'Falgun',
  'Chaitra',
];

/// A fully custom Nepali calendar widget showing transaction history.
/// Dates with transactions are marked with a dot. Selecting a date
/// reveals the transactions for that day. Tapping a user navigates
/// to the ConnectedUserDetails screen.
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

  late NepaliDateTime _today;
  late NepaliDateTime _selectedDate;
  late int _displayedYear;
  late int _displayedMonth;

  /// Map of "yyyy-MM-dd" -> TransactionDay
  Map<String, TransactionDay> _transactionsByDate = {};

  @override
  void initState() {
    super.initState();
    _today = NepaliDateTime.now();
    _selectedDate = _today;
    _displayedYear = _today.year;
    _displayedMonth = _today.month;
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _dataSource.getTransactionActivity(days: 180);
      if (mounted) {
        setState(() {
          _activityDays = data;
          _transactionsByDate = {
            for (final day in data) _gregorianToKey(day.date): day,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
    }
  }

  String _gregorianToKey(DateTime date) {
    final n = date.toNepaliDateTime();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String _nepaliDateKey(NepaliDateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _dateHasTransactions(int y, int m, int d) =>
      _transactionsByDate.containsKey(
        '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}',
      );

  TransactionDay? get _selectedDayData =>
      _transactionsByDate[_nepaliDateKey(_selectedDate)];

  void _prevMonth() {
    setState(() {
      if (_displayedMonth == 1) {
        _displayedMonth = 12;
        _displayedYear--;
      } else {
        _displayedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_displayedMonth == 12) {
        _displayedMonth = 1;
        _displayedYear++;
      } else {
        _displayedMonth++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildSectionLabel(loc), _buildCard(context, loc)],
    );
  }

  Widget _buildSectionLabel(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            loc.transactionCalendar,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          if (_activityDays != null && _activityDays!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${_activityDays!.length} days',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Calendar header gradient
          _buildCalendarHeader(),
          // Day labels
          _buildWeekdayHeaders(),
          // Calendar grid
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _error != null
              ? _buildErrorState(loc)
              : _buildCalendarGrid(),
          // Divider
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
          // Transaction panel
          _buildTransactionPanel(context, loc),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final monthName = _kNepaliMonths[_displayedMonth - 1];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavButton(icon: Icons.chevron_left_rounded, onTap: _prevMonth),
            Column(
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '$_displayedYear BS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            _NavButton(icon: Icons.chevron_right_rounded, onTap: _nextMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: _kWeekDays.map((day) {
          final isSun = day == 'Su';
          final isSat = day == 'Sa';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSun || isSat
                      ? AppTheme.primaryBlue.withValues(alpha: 0.6)
                      : Colors.grey[400],
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = NepaliDateTime(
      _displayedYear,
      _displayedMonth,
    ).totalDays;
    // NepaliDateTime.weekday: 1=Mon...7=Sun; we want Sun=0 offset in grid
    final firstWeekday = NepaliDateTime(
      _displayedYear,
      _displayedMonth,
      1,
    ).weekday;
    // Convert to Sunday-first offset: Sun=7 -> 0, Mon=1 -> 1, ..., Sat=6 -> 6
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day = cellIndex - startOffset + 1;
              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox.shrink());
              }
              return Expanded(child: _buildDayCell(day));
            }),
          );
        }),
      ),
    );
  }

  Widget _buildDayCell(int day) {
    final isSelected =
        _selectedDate.year == _displayedYear &&
        _selectedDate.month == _displayedMonth &&
        _selectedDate.day == day;
    final isToday =
        _today.year == _displayedYear &&
        _today.month == _displayedMonth &&
        _today.day == day;
    final hasTransactions = _dateHasTransactions(
      _displayedYear,
      _displayedMonth,
      day,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = NepaliDateTime(_displayedYear, _displayedMonth, day);
        });
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue
                : hasTransactions
                ? const Color(0xFFE8F0FB)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isToday && !isSelected
                ? Border.all(color: AppTheme.primaryBlue, width: 1.5)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected || hasTransactions
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? AppTheme.primaryBlue
                      : hasTransactions
                      ? AppTheme.primaryDark
                      : Colors.grey[700],
                ),
              ),
              if (hasTransactions && !isSelected)
                Positioned(
                  bottom: 5,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            loc.error,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadActivity,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(loc.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionPanel(BuildContext context, AppLocalizations loc) {
    final dayData = _selectedDayData;

    if (dayData == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_outlined, size: 20, color: Colors.grey[300]),
            const SizedBox(width: 8),
            Text(
              loc.noTransactionsOnDate,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
    }

    final nepDateStr =
        '${_kNepaliMonths[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';

    return Column(
      children: [
        // Date bar
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF4FF), Color(0xFFF5F0FF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nepDateStr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Rs. ${dayData.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        // User list
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
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.connectedUserDetails,
          arguments: ConnectedUserDetailsArgs(
            relationshipId: user.relationshipId,
            isCustomerView: widget.isCustomerView,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: user.isBusiness
                        ? const Color(0xFFE3F2FD)
                        : const Color(0xFFF3E5F5),
                    backgroundImage: user.profilePicture != null
                        ? NetworkImage(
                            ImageUtils.getFullImageUrl(user.profilePicture!) ??
                                '',
                          )
                        : null,
                    child: user.profilePicture == null
                        ? Icon(
                            user.isBusiness
                                ? Icons.store_rounded
                                : Icons.person_rounded,
                            size: 22,
                            color: user.isBusiness
                                ? const Color(0xFF4A90E2)
                                : const Color(0xFF9C27B0),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: user.isBusiness
                            ? const Color(0xFF4A90E2)
                            : const Color(0xFF9C27B0),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(
                        user.isBusiness ? Icons.store : Icons.person,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.transactionCount} ${user.transactionCount == 1 ? loc.transactionSingular : loc.transactions}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rs. ${user.amountTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFFBBBBBB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small circular navigation button for month prev/next
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
