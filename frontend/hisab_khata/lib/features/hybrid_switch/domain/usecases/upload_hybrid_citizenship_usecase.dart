import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/core/usecases/usecase.dart';

import '../entities/hybrid_switch_request_entity.dart';
import '../repositories/hybrid_switch_request_repository.dart';

class UploadHybridCitizenshipUseCase
    implements
        Usecase<HybridSwitchRequestEntity, UploadHybridCitizenshipParams> {
  final HybridSwitchRequestRepository repository;

  UploadHybridCitizenshipUseCase(this.repository);

  @override
  Future<Either<Failure, HybridSwitchRequestEntity>> call(
    UploadHybridCitizenshipParams params,
  ) {
    return repository.uploadCitizenship(
      citizenshipFile: params.citizenshipFile,
    );
  }
}

class UploadHybridCitizenshipParams extends Equatable {
  final File citizenshipFile;

  const UploadHybridCitizenshipParams({required this.citizenshipFile});

  @override
  List<Object?> get props => [citizenshipFile.path];
}
