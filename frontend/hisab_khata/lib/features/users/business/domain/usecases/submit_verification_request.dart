import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/business/domain/entities/verification_request.dart';
import 'package:hisab_khata/features/users/business/domain/repositories/business_repository.dart';

/// Use case for submitting a business verification request
class SubmitVerificationRequest {
  final BusinessRepository repository;

  SubmitVerificationRequest(this.repository);

  Future<Either<String, VerificationRequest>> call({
    required String documentPath,
    String documentType = 'business_registration',
    String? note,
  }) async {
    return await repository.submitVerificationRequest(
      documentPath: documentPath,
      documentType: documentType,
      note: note,
    );
  }
}
