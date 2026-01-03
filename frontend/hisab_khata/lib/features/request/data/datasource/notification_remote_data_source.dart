import '../../../../core/data/base_remote_data_source.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../notification/data/models/notification_model.dart';

/// Abstract class defining notification remote data source contract
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getAllNotifications();
  Future<List<NotificationModel>> getUnreadNotifications();
  Future<int> getUnreadCount();
  Future<NotificationModel> markAsRead(int notificationId);
  Future<int> markAllAsRead();
  Future<void> deleteNotification(int notificationId);
  Future<int> deleteAllRead();
}

/// Implementation of NotificationRemoteDataSource using BaseRemoteDataSource
class NotificationRemoteDataSourceImpl extends BaseRemoteDataSource
    implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({super.client});

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    final response = await get(ApiEndpoints.allNotifications);

    final List<dynamic> data = response;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final response = await get(ApiEndpoints.unreadNotifications);

    final List<dynamic> data = response;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await get(ApiEndpoints.unreadCount);

    return response['unread_count'];
  }

  @override
  Future<NotificationModel> markAsRead(int notificationId) async {
    final response = await patch(
      ApiEndpoints.markNotificationAsRead(notificationId),
    );

    return NotificationModel.fromJson(response['notification']);
  }

  @override
  Future<int> markAllAsRead() async {
    final response = await patch(ApiEndpoints.markAllNotificationsAsRead);

    return response['updated_count'];
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    await delete(ApiEndpoints.deleteNotification(notificationId));
  }

  @override
  Future<int> deleteAllRead() async {
    final response = await delete(ApiEndpoints.deleteAllReadNotifications);

    return response['deleted_count'];
  }
}
