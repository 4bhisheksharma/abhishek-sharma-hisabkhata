import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_dashboard_entity.dart';
import 'package:hisab_khata/features/users/customer/domain/repositories/customer_repository.dart';

/// Use case for getting customer dashboard data
class GetCustomerDashboard {
  final CustomerRepository repository;

  GetCustomerDashboard(this.repository);

  Future<Either<String, CustomerDashboardEntity>> call() async {
    return await repository.getDashboard();
  }
}
