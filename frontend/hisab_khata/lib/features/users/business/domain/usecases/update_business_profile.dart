import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/business/domain/entities/business_profile.dart';
import 'package:hisab_khata/features/users/business/domain/repositories/business_repository.dart';

/// Use case for updating business profile
class UpdateBusinessProfile {
  final BusinessRepository repository;

  UpdateBusinessProfile(this.repository);

  Future<Either<String, BusinessProfile>> call({
    String? businessName,
    String? fullName,
    String? phoneNumber,
    String? profilePicturePath,
  }) async {
    return await repository.updateProfile(
      businessName: businessName,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profilePicturePath: profilePicturePath,
    );
  }
}
