import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/business/domain/entities/business_dashboard.dart';
import 'package:hisab_khata/features/users/business/domain/repositories/business_repository.dart';

/// Use case for getting business dashboard data
class GetBusinessDashboard {
  final BusinessRepository repository;

  GetBusinessDashboard(this.repository);

  Future<Either<String, BusinessDashboard>> call() async {
    return await repository.getDashboard();
  }
}
