import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/business/domain/entities/verification_request.dart';
import 'package:hisab_khata/features/users/business/domain/repositories/business_repository.dart';

/// Use case for getting business verification status
class GetVerificationStatus {
  final BusinessRepository repository;

  GetVerificationStatus(this.repository);

  Future<Either<String, VerificationStatus>> call() async {
    return await repository.getVerificationStatus();
  }
}
