import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_profile_entity.dart';
import 'package:hisab_khata/features/users/customer/domain/repositories/customer_repository.dart';

/// Use case for getting customer profile
class GetCustomerProfile {
  final CustomerRepository repository;

  GetCustomerProfile(this.repository);

  Future<Either<String, CustomerProfileEntity>> call() async {
    return await repository.getProfile();
  }
}
