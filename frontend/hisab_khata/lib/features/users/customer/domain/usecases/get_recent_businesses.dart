import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/customer/domain/repositories/customer_repository.dart';
import 'package:hisab_khata/features/users/shared/domain/entities/recent_connection_entity.dart';

/// Use case for getting recently added businesses for a customer
class GetRecentBusinesses {
  final CustomerRepository repository;

  GetRecentBusinesses(this.repository);

  Future<Either<String, List<RecentConnectionEntity>>> call({int limit = 10}) async {
    return await repository.getRecentBusinesses(limit: limit);
  }
}
