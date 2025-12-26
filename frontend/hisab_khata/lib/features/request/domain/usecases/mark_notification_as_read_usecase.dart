import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<Either<Failure, Notification>> call(int notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
