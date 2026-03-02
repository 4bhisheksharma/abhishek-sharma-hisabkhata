import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/customer/data/models/nearby_business_model.dart';
import 'package:hisab_khata/features/users/customer/domain/repositories/customer_repository.dart';

/// Use case for getting nearby businesses with location
class GetNearbyBusinesses {
  final CustomerRepository repository;

  GetNearbyBusinesses(this.repository);

  Future<Either<String, List<NearbyBusinessModel>>> call() async {
    return await repository.getNearbyBusinesses();
  }
}
