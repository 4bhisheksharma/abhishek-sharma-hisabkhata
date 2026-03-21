import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/exceptions.dart';
import 'package:hisab_khata/core/errors/failures.dart';

import '../../domain/entities/hybrid_switch_request_entity.dart';
import '../../domain/entities/hybrid_switch_status_entity.dart';
import '../../domain/repositories/hybrid_switch_request_repository.dart';
import '../datasources/hybrid_switch_remote_datasource.dart';

class HybridSwitchRepositoryImpl implements HybridSwitchRequestRepository {
  final HybridSwitchRemoteDatasource remoteDatasource;

  HybridSwitchRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, HybridSwitchStatusEntity>> getStatus() async {
    try {
      final model = await remoteDatasource.getStatus();
      return Right(model);
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HybridSwitchRequestEntity>> uploadCitizenship({
    required File citizenshipFile,
  }) async {
    try {
      final model = await remoteDatasource.uploadCitizenship(
        citizenshipFile: citizenshipFile,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HybridSwitchRequestEntity>> submitRequest({
    int? hybridRequestId,
  }) async {
    try {
      final model = await remoteDatasource.submitRequest(
        hybridRequestId: hybridRequestId,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HybridSwitchRequestEntity>>>
  getMyRequests() async {
    try {
      final models = await remoteDatasource.getMyRequests();
      return Right(models);
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
