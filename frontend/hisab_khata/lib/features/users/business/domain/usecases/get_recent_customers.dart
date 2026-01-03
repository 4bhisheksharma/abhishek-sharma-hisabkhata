import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/business/domain/repositories/business_repository.dart';
import 'package:hisab_khata/features/users/shared/domain/entities/recent_connection_entity.dart';

/// Use case for getting recently added customers for a business
class GetRecentCustomers {
  final BusinessRepository repository;

  GetRecentCustomers(this.repository);

  Future<Either<String, List<RecentConnectionEntity>>> call({
    int limit = 10,
  }) async {
    return await repository.getRecentCustomers(limit: limit);
  }
}
