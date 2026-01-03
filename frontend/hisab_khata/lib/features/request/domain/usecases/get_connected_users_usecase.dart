import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/connected_user.dart';
import '../repositories/connection_request_repository.dart';

class GetConnectedUsersUseCase {
  final ConnectionRequestRepository repository;

  GetConnectedUsersUseCase(this.repository);

  Future<Either<Failure, List<ConnectedUser>>> call() async {
    return await repository.getConnectedUsers();
  }
}
