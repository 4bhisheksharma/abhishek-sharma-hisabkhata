import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_dashboard_entity.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_profile_entity.dart';

/// Customer Repository
/// Defines the contract for customer-related operations
abstract class CustomerRepository {
  /// Get customer dashboard data
  Future<Either<String, CustomerDashboardEntity>> getDashboard();

  /// Get customer profile
  Future<Either<String, CustomerProfileEntity>> getProfile();

  /// Update customer profile
  Future<Either<String, CustomerProfileEntity>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profilePicturePath,
  });
}
