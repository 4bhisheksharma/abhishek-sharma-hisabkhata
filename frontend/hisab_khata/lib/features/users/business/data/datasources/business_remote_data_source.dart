import 'dart:io';
import 'package:hisab_khata/core/data/base_remote_data_source.dart';
import 'package:hisab_khata/core/constants/api_endpoints.dart';
import 'package:hisab_khata/features/users/shared/data/models/recent_connection_model.dart';
import '../models/business_dashboard_model.dart';
import '../models/business_profile_model.dart';

/// Abstract class defining business remote data source contract
abstract class BusinessRemoteDataSource {
  /// Get business dashboard data
  Future<BusinessDashboardModel> getDashboard();

  /// Get business profile
  Future<BusinessProfileModel> getProfile();

  /// Update business profile
  Future<BusinessProfileModel> updateProfile({
    String? businessName,
    String? fullName,
    String? phoneNumber,
    File? profilePicture,
    String? preferredLanguage,
  });

  /// Get recently added customers for this business
  Future<List<RecentConnectionModel>> getRecentCustomers({int limit = 10});
}

/// Implementation of BusinessRemoteDataSource using BaseRemoteDataSource
class BusinessRemoteDataSourceImpl extends BaseRemoteDataSource
    implements BusinessRemoteDataSource {
  BusinessRemoteDataSourceImpl({super.client});

  @override
  Future<BusinessDashboardModel> getDashboard() async {
    final response = await get(
      ApiEndpoints.businessDashboard,
      includeAuth: true,
    );

    return BusinessDashboardModel.fromJson(response['data']);
  }

  @override
  Future<BusinessProfileModel> getProfile() async {
    final response = await get(ApiEndpoints.businessProfile, includeAuth: true);

    return BusinessProfileModel.fromJson(response['data']);
  }

  @override
  Future<BusinessProfileModel> updateProfile({
    String? businessName,
    String? fullName,
    String? phoneNumber,
    File? profilePicture,
    String? preferredLanguage,
  }) async {
    if (profilePicture != null) {
      // Use multipart request for file upload
      final fields = <String, String>{};
      if (businessName != null) fields['business_name'] = businessName;
      if (fullName != null) fields['full_name'] = fullName;
      if (phoneNumber != null) fields['phone_number'] = phoneNumber;
      if (preferredLanguage != null)
        fields['preferred_language'] = preferredLanguage;

      final files = <String, File>{'profile_picture': profilePicture};

      final response = await multipart(
        ApiEndpoints.businessProfile,
        'PATCH',
        fields: fields,
        files: files,
        includeAuth: true,
      );

      return BusinessProfileModel.fromJson(response['data']);
    } else {
      // Regular JSON request
      final body = <String, dynamic>{};
      if (businessName != null) body['business_name'] = businessName;
      if (fullName != null) body['full_name'] = fullName;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (preferredLanguage != null)
        body['preferred_language'] = preferredLanguage;

      final response = await patch(
        ApiEndpoints.businessProfile,
        body: body,
        includeAuth: true,
      );

      return BusinessProfileModel.fromJson(response['data']);
    }
  }

  @override
  Future<List<RecentConnectionModel>> getRecentCustomers({
    int limit = 10,
  }) async {
    final response = await get(
      '${ApiEndpoints.recentCustomers}?limit=$limit',
      includeAuth: true,
    );

    final List<dynamic> data = response['data'] ?? [];
    return data
        .map((json) => RecentConnectionModel.fromCustomerJson(json))
        .toList();
  }
}
