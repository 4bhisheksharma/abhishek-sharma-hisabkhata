import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/connection_request.dart';
import '../repositories/connection_request_repository.dart';

class UpdateRequestStatusUseCase {
  final ConnectionRequestRepository repository;

  UpdateRequestStatusUseCase(this.repository);

  Future<Either<Failure, ConnectionRequest>> call({
    required int requestId,
    required String status,
  }) async {
    return await repository.updateRequestStatus(
      requestId: requestId,
      status: status,
    );
  }
}
