import '../entities/business_dashboard.dart';
import '../entities/business_profile.dart';

abstract class BusinessRepository {
  Future<BusinessDashboard> getDashboard();
  Future<BusinessProfile> getProfile();
  Future<BusinessProfile> updateProfile({
    String? businessName,
    String? fullName,
    String? phoneNumber,
    String? profilePicture,
  });
}
