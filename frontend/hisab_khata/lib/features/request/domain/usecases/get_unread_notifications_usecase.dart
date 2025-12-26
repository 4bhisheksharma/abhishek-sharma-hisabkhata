import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetUnreadNotificationsUseCase {
  final NotificationRepository repository;

  GetUnreadNotificationsUseCase(this.repository);

  Future<Either<Failure, List<Notification>>> call() async {
    return await repository.getUnreadNotifications();
  }
}
