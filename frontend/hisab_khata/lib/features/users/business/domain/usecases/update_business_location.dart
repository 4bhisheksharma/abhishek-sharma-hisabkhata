import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/business/domain/entities/business_profile.dart';
import 'package:hisab_khata/features/users/business/domain/repositories/business_repository.dart';

/// Use case for updating business location
class UpdateBusinessLocation {
  final BusinessRepository repository;

  UpdateBusinessLocation(this.repository);

  Future<Either<String, BusinessProfile>> call({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    return await repository.updateLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}
