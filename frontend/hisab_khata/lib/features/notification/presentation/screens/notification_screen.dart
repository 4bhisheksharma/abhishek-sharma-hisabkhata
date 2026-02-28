import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/my_snackbar.dart';
import '../../../../shared/widgets/shimmer/shimmer_widgets.dart';
import '../../domain/entities/notification.dart' as entity;
import '../bloc/bloc.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all notifications when screen loads
    context.read<NotificationBloc>().add(const GetAllNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.notification,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationError) {
              MySnackbar.showError(context, state.message);
            } else if (state is NotificationMarkedAsRead) {
              MySnackbar.showSuccess(context, state.message);
            } else if (state is NotificationDeleted) {
              MySnackbar.showSuccess(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const NotificationListShimmer();
            }

            if (state is AllNotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 56,
                        color: AppTheme.lightGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.noNotificationsYet,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final groupedNotifications = _groupNotificationsByTime(
                state.notifications,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...groupedNotifications.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        ...entry.value.map((notification) {
                          return _NotificationTile(
                            notification: notification,
                            onTap: () {
                              // Mark as read if unread
                              if (!notification.isRead) {
                                context.read<NotificationBloc>().add(
                                  MarkNotificationAsReadEvent(
                                    notificationId: notification.notificationId,
                                  ),
                                );
                              }

                              // Navigate to connection requests screen (tab index 2) if it's a connection request notification
                              if (notification.isConnectionRequest) {
                                Navigator.pop(context, 2);
                              }
                            },
                            onDelete: () {
                              context.read<NotificationBloc>().add(
                                DeleteNotificationEvent(
                                  notificationId: notification.notificationId,
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    );
                  }),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Map<String, List<entity.Notification>> _groupNotificationsByTime(
    List<entity.Notification> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: now.weekday - 1));

    final todayKey = AppLocalizations.of(context)!.today;
    final yesterdayKey = AppLocalizations.of(context)!.yesterday;
    final thisWeekKey = AppLocalizations.of(context)!.thisWeek;
    final earlierKey = AppLocalizations.of(context)!.earlier;

    final Map<String, List<entity.Notification>> grouped = {
      todayKey: [],
      yesterdayKey: [],
      thisWeekKey: [],
      earlierKey: [],
    };

    for (var notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notificationDate.isAtSameMomentAs(today)) {
        grouped[todayKey]!.add(notification);
      } else if (notificationDate.isAtSameMomentAs(yesterday)) {
        grouped[yesterdayKey]!.add(notification);
      } else if (notificationDate.isAfter(thisWeekStart) &&
          notificationDate.isBefore(yesterday)) {
        grouped[thisWeekKey]!.add(notification);
      } else {
        grouped[earlierKey]!.add(notification);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }
}

class _NotificationTile extends StatelessWidget {
  final entity.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconInfo = _getIconInfoForType(notification.type);
    return Dismissible(
      key: Key(notification.notificationId.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppTheme.lightBlue.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notification.isRead
                  ? AppTheme.dividerColor
                  : AppTheme.primaryBlue.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconInfo.$2.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconInfo.$1, color: iconInfo.$2, size: 22),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDateTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getIconInfoForType(String type) {
    switch (type.toLowerCase()) {
      case 'connection_request':
        return (Icons.person_add_rounded, AppTheme.infoBlue);
      case 'connection_request_accepted':
      case 'request_accepted':
        return (Icons.handshake_rounded, AppTheme.successGreen);
      case 'connection_request_rejected':
      case 'request_rejected':
        return (Icons.person_off_rounded, AppTheme.errorRed);
      case 'connection_request_cancelled':
        return (Icons.cancel_outlined, AppTheme.warningOrange);
      case 'connection_deleted':
        return (Icons.link_off_rounded, AppTheme.errorRed);
      case 'transaction_added':
        return (Icons.receipt_long_rounded, AppTheme.primaryBlue);
      case 'payment_received':
        return (Icons.payments_rounded, AppTheme.successGreen);
      case 'due_reminder':
      case 'bulk_payment_reminder':
        return (Icons.alarm_rounded, AppTheme.warningOrange);
      case 'monthly_limit_exceeded':
        return (Icons.trending_up_rounded, AppTheme.errorRed);
      case 'favorite_added':
        return (Icons.star_rounded, const Color(0xFFFFC107));
      case 'verification_approved':
        return (Icons.verified_rounded, AppTheme.successGreen);
      case 'verification_rejected':
        return (Icons.gpp_bad_rounded, AppTheme.errorRed);
      case 'broadcast':
      case 'system':
        return (Icons.campaign_rounded, AppTheme.infoBlue);
      case 'loyalty_points':
        return (Icons.card_giftcard_rounded, AppTheme.primaryBlue);
      case 'reminder':
        return (Icons.notifications_active_rounded, AppTheme.warningOrange);
      case 'update':
        return (Icons.new_releases_rounded, AppTheme.infoBlue);
      default:
        return (Icons.notifications_rounded, AppTheme.primaryBlue);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final time = DateFormat('HH:mm').format(dateTime);
    final date = DateFormat('MMM dd').format(dateTime);
    return '$time - $date';
  }
}
