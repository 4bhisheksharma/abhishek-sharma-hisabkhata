import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/shared/domain/entities/recent_connection_entity.dart';
import '../entities/business_dashboard.dart';
import '../entities/business_profile.dart';
import '../entities/verification_request.dart';

abstract class BusinessRepository {
  Future<Either<String, BusinessDashboard>> getDashboard();
  Future<Either<String, BusinessProfile>> getProfile();
  Future<Either<String, BusinessProfile>> updateProfile({
    String? businessName,
    String? fullName,
    String? phoneNumber,
    String? profilePicturePath,
    String? preferredLanguage,
  });
  Future<Either<String, BusinessProfile>> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  });
  Future<Either<String, List<RecentConnectionEntity>>> getRecentCustomers({
    int limit = 10,
  });
  Future<Either<String, VerificationRequest>> submitVerificationRequest({
    required String documentPath,
    String documentType,
    String? note,
  });
  Future<Either<String, VerificationStatus>> getVerificationStatus();
  Future<Either<String, List<VerificationRequest>>> getVerificationRequests();
}
