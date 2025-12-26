import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class DeleteAllReadNotificationsUseCase {
  final NotificationRepository repository;

  DeleteAllReadNotificationsUseCase(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.deleteAllRead();
  }
}
