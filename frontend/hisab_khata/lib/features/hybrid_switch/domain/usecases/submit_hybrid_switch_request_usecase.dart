import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/core/usecases/usecase.dart';

import '../entities/hybrid_switch_request_entity.dart';
import '../repositories/hybrid_switch_request_repository.dart';

class SubmitHybridSwitchRequestUseCase
    implements
        Usecase<HybridSwitchRequestEntity, SubmitHybridSwitchRequestParams> {
  final HybridSwitchRequestRepository repository;

  SubmitHybridSwitchRequestUseCase(this.repository);

  @override
  Future<Either<Failure, HybridSwitchRequestEntity>> call(
    SubmitHybridSwitchRequestParams params,
  ) {
    return repository.submitRequest(hybridRequestId: params.hybridRequestId);
  }
}

class SubmitHybridSwitchRequestParams extends Equatable {
  final int? hybridRequestId;

  const SubmitHybridSwitchRequestParams({this.hybridRequestId});

  @override
  List<Object?> get props => [hybridRequestId];
}
