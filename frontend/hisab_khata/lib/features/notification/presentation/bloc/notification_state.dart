import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

/// Base notification state
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// All notifications loaded state
class AllNotificationsLoaded extends NotificationState {
  final List<Notification> notifications;

  const AllNotificationsLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

/// Unread notifications loaded state
class UnreadNotificationsLoaded extends NotificationState {
  final List<Notification> notifications;

  const UnreadNotificationsLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

/// Unread count loaded state
class UnreadCountLoaded extends NotificationState {
  final int count;

  const UnreadCountLoaded({required this.count});

  @override
  List<Object?> get props => [count];
}

/// Notification marked as read state
class NotificationMarkedAsRead extends NotificationState {
  final Notification notification;
  final String message;

  const NotificationMarkedAsRead({
    required this.notification,
    this.message = 'Notification marked as read',
  });

  @override
  List<Object?> get props => [notification, message];
}

/// All notifications marked as read state
class AllNotificationsMarkedAsRead extends NotificationState {
  final int count;
  final String message;

  const AllNotificationsMarkedAsRead({
    required this.count,
    this.message = 'All notifications marked as read',
  });

  @override
  List<Object?> get props => [count, message];
}

/// Notification deleted state
class NotificationDeleted extends NotificationState {
  final String message;

  const NotificationDeleted({
    this.message = 'Notification deleted successfully',
  });

  @override
  List<Object?> get props => [message];
}

/// All read notifications deleted state
class AllReadNotificationsDeleted extends NotificationState {
  final int count;
  final String message;

  const AllReadNotificationsDeleted({
    required this.count,
    this.message = 'All read notifications deleted',
  });

  @override
  List<Object?> get props => [count, message];
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
