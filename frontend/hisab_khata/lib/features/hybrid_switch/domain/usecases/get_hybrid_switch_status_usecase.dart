import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/core/usecases/usecase.dart';

import '../entities/hybrid_switch_status_entity.dart';
import '../repositories/hybrid_switch_request_repository.dart';

class GetHybridSwitchStatusUseCase
    implements Usecase<HybridSwitchStatusEntity, NoParams> {
  final HybridSwitchRequestRepository repository;

  GetHybridSwitchStatusUseCase(this.repository);

  @override
  Future<Either<Failure, HybridSwitchStatusEntity>> call(NoParams params) {
    return repository.getStatus();
  }
}
