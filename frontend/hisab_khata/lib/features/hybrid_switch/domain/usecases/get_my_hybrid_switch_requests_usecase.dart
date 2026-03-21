import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/core/usecases/usecase.dart';

import '../entities/hybrid_switch_request_entity.dart';
import '../repositories/hybrid_switch_request_repository.dart';

class GetMyHybridSwitchRequestsUseCase
    implements Usecase<List<HybridSwitchRequestEntity>, NoParams> {
  final HybridSwitchRequestRepository repository;

  GetMyHybridSwitchRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<HybridSwitchRequestEntity>>> call(
    NoParams params,
  ) {
    return repository.getMyRequests();
  }
}
