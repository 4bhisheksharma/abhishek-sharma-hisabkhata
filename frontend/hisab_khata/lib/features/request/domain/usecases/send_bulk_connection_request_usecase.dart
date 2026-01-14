import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/bulk_send_request_response.dart';
import '../repositories/connection_request_repository.dart';

class SendBulkConnectionRequestUseCase {
  final ConnectionRequestRepository repository;

  SendBulkConnectionRequestUseCase(this.repository);

  Future<Either<Failure, BulkSendRequestResponse>> call({
    required List<int> receiverIds,
  }) async {
    return await repository.bulkSendRequest(receiverIds: receiverIds);
  }
}
