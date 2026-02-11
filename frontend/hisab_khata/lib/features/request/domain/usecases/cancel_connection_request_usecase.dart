import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/connection_request_repository.dart';

class CancelConnectionRequestUseCase {
  final ConnectionRequestRepository repository;

  CancelConnectionRequestUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int requestId,
  }) async {
    return await repository.cancelRequest(requestId: requestId);
  }
}
