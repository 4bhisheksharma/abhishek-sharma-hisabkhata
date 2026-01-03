import 'dart:io';
import 'package:hisab_khata/core/data/base_remote_data_source.dart';
import 'package:hisab_khata/core/constants/api_endpoints.dart';
import 'package:hisab_khata/features/users/shared/data/models/recent_connection_model.dart';
import '../models/customer_dashboard_model.dart';
import '../models/customer_profile_model.dart';

/// Abstract class defining customer remote data source contract
abstract class CustomerRemoteDataSource {
  /// Get customer dashboard data
  Future<CustomerDashboardModel> getDashboard();

  /// Get customer profile
  Future<CustomerProfileModel> getProfile();

  /// Update customer profile
  Future<CustomerProfileModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    File? profilePicture,
  });

  /// Get recently added businesses for this customer
  Future<List<RecentConnectionModel>> getRecentBusinesses({int limit = 10});
}

/// Implementation of CustomerRemoteDataSource using BaseRemoteDataSource
class CustomerRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CustomerRemoteDataSource {
  CustomerRemoteDataSourceImpl({super.client});

  @override
  Future<CustomerDashboardModel> getDashboard() async {
    final response = await get(
      ApiEndpoints.customerDashboard,
      includeAuth: true,
    );

    return CustomerDashboardModel.fromJson(response['data']);
  }

  @override
  Future<CustomerProfileModel> getProfile() async {
    final response = await get(ApiEndpoints.customerProfile, includeAuth: true);

    return CustomerProfileModel.fromJson(response['data']);
  }

  @override
  Future<CustomerProfileModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    File? profilePicture,
  }) async {
    if (profilePicture != null) {
      // Use multipart request for file upload
      final fields = <String, String>{};
      if (fullName != null) fields['full_name'] = fullName;
      if (phoneNumber != null) fields['phone_number'] = phoneNumber;

      final files = <String, File>{'profile_picture': profilePicture};

      final response = await multipart(
        ApiEndpoints.customerProfile,
        'PATCH',
        fields: fields,
        files: files,
        includeAuth: true,
      );

      return CustomerProfileModel.fromJson(response['data']);
    } else {
      // Regular JSON request
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;

      final response = await patch(
        ApiEndpoints.customerProfile,
        body: body,
        includeAuth: true,
      );

      return CustomerProfileModel.fromJson(response['data']);
    }
  }

  @override
  Future<List<RecentConnectionModel>> getRecentBusinesses({int limit = 10}) async {
    final response = await get(
      '${ApiEndpoints.recentBusinesses}?limit=$limit',
      includeAuth: true,
    );

    final List<dynamic> data = response['data'] ?? [];
    return data
        .map((json) => RecentConnectionModel.fromBusinessJson(json))
        .toList();
  }
}
