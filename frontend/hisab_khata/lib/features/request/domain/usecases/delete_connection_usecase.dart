import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../repositories/connection_request_repository.dart';

class DeleteConnectionUseCase {
  final ConnectionRequestRepository repository;

  DeleteConnectionUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    int? userId,
    int? requestId,
  }) async {
    return await repository.deleteConnection(
      userId: userId,
      requestId: requestId,
    );
  }
}
