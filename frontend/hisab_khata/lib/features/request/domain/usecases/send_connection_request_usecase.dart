import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/connection_request.dart';
import '../repositories/connection_request_repository.dart';

class SendConnectionRequestUseCase {
  final ConnectionRequestRepository repository;

  SendConnectionRequestUseCase(this.repository);

  Future<Either<Failure, ConnectionRequest>> call({
    String? receiverEmail,
    int? receiverId,
  }) async {
    return await repository.sendRequest(
      receiverEmail: receiverEmail,
      receiverId: receiverId,
    );
  }
}
