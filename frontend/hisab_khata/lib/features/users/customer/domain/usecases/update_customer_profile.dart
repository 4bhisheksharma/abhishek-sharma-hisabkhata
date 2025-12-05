import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_profile_entity.dart';
import 'package:hisab_khata/features/users/customer/domain/repositories/customer_repository.dart';

/// Use case for updating customer profile
class UpdateCustomerProfile {
  final CustomerRepository repository;

  UpdateCustomerProfile(this.repository);

  Future<Either<String, CustomerProfileEntity>> call({
    String? fullName,
    String? phoneNumber,
    String? profilePicturePath,
  }) async {
    return await repository.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      profilePicturePath: profilePicturePath,
    );
  }
}
