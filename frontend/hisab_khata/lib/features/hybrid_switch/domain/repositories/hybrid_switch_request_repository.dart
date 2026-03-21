import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';

import '../entities/hybrid_switch_request_entity.dart';
import '../entities/hybrid_switch_status_entity.dart';

abstract class HybridSwitchRequestRepository {
  Future<Either<Failure, HybridSwitchStatusEntity>> getStatus();

  Future<Either<Failure, HybridSwitchRequestEntity>> uploadCitizenship({
    required File citizenshipFile,
  });

  Future<Either<Failure, HybridSwitchRequestEntity>> submitRequest({
    int? hybridRequestId,
  });

  Future<Either<Failure, List<HybridSwitchRequestEntity>>> getMyRequests();
}
