import 'package:dartz/dartz.dart';
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
}
