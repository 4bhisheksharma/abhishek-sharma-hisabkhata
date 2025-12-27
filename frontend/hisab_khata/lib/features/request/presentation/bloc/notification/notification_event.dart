import 'package:equatable/equatable.dart';

/// Base notification event
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Get all notifications event
class GetAllNotificationsEvent extends NotificationEvent {
  const GetAllNotificationsEvent();
}

/// Get unread notifications event
class GetUnreadNotificationsEvent extends NotificationEvent {
  const GetUnreadNotificationsEvent();
}

/// Get unread count event
class GetUnreadCountEvent extends NotificationEvent {
  const GetUnreadCountEvent();
}

/// Mark notification as read event
class MarkNotificationAsReadEvent extends NotificationEvent {
  final int notificationId;

  const MarkNotificationAsReadEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read event
class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  const MarkAllNotificationsAsReadEvent();
}

/// Delete notification event
class DeleteNotificationEvent extends NotificationEvent {
  final int notificationId;

  const DeleteNotificationEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Delete all read notifications event
class DeleteAllReadNotificationsEvent extends NotificationEvent {
  const DeleteAllReadNotificationsEvent();
}
