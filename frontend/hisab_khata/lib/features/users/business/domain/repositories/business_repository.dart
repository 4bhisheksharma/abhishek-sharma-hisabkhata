import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/shared/domain/entities/recent_connection_entity.dart';
import '../entities/business_dashboard.dart';
import '../entities/business_profile.dart';

abstract class BusinessRepository {
  Future<Either<String, BusinessDashboard>> getDashboard();
  Future<Either<String, BusinessProfile>> getProfile();
  Future<Either<String, BusinessProfile>> updateProfile({
    String? businessName,
    String? fullName,
    String? phoneNumber,
    String? profilePicturePath,
  });
  Future<Either<String, List<RecentConnectionEntity>>> getRecentCustomers({
    int limit = 10,
  });
}
