import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasource/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Notification>>> getAllNotifications() async {
    try {
      final result = await remoteDataSource.getAllNotifications();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Notification>>> getUnreadNotifications() async {
    try {
      final result = await remoteDataSource.getUnreadNotifications();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final result = await remoteDataSource.getUnreadCount();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Notification>> markAsRead(int notificationId) async {
    try {
      final result = await remoteDataSource.markAsRead(notificationId);
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> markAllAsRead() async {
    try {
      final result = await remoteDataSource.markAllAsRead();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> deleteAllRead() async {
    try {
      final result = await remoteDataSource.deleteAllRead();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
