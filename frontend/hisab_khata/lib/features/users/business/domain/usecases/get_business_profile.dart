import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/business/domain/entities/business_profile.dart';
import 'package:hisab_khata/features/users/business/domain/repositories/business_repository.dart';

/// Use case for getting business profile data
class GetBusinessProfile {
  final BusinessRepository repository;

  GetBusinessProfile(this.repository);

  Future<Either<String, BusinessProfile>> call() async {
    return await repository.getProfile();
  }
}
