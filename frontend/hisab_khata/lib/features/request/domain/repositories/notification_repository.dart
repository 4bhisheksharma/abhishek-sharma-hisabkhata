import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';

import '../entities/notification.dart';

abstract class NotificationRepository {
  /// Get all notifications for current user
  Future<Either<Failure, List<Notification>>> getAllNotifications();

  /// Get unread notifications
  Future<Either<Failure, List<Notification>>> getUnreadNotifications();

  /// Get count of unread notifications
  Future<Either<Failure, int>> getUnreadCount();

  /// Mark specific notification as read
  Future<Either<Failure, Notification>> markAsRead(int notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, int>> markAllAsRead();

  /// Delete specific notification
  Future<Either<Failure, void>> deleteNotification(int notificationId);

  /// Delete all read notifications
  Future<Either<Failure, int>> deleteAllRead();
}
