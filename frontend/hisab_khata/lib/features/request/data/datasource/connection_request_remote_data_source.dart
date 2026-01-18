import '../../../../core/data/base_remote_data_source.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/bulk_send_request_response_model.dart';
import '../models/connection_request_model.dart';
import '../models/connected_user_model.dart';
import '../models/user_search_result_model.dart';

/// Abstract class defining connection request remote data source contract
abstract class ConnectionRequestRemoteDataSource {
  Future<List<UserSearchResultModel>> searchUsers(String query);
  Future<ConnectionRequestModel> sendRequest({
    String? receiverEmail,
    int? receiverId,
  });
  Future<BulkSendRequestResponseModel> bulkSendRequest({
    required List<int> receiverIds,
  });
  Future<List<ConnectionRequestModel>> getSentRequests();
  Future<List<ConnectionRequestModel>> getReceivedRequests();
  Future<List<ConnectionRequestModel>> getPendingReceivedRequests();
  Future<List<ConnectedUserModel>> getConnectedUsers();
  Future<ConnectionRequestModel> updateRequestStatus({
    required int requestId,
    required String status,
  });
  Future<Map<String, dynamic>> deleteConnection({int? userId, int? requestId});
}

/// Implementation of ConnectionRequestRemoteDataSource using BaseRemoteDataSource
class ConnectionRequestRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ConnectionRequestRemoteDataSource {
  ConnectionRequestRemoteDataSourceImpl({super.client});

  @override
  Future<List<UserSearchResultModel>> searchUsers(String query) async {
    final response = await get(
      ApiEndpoints.searchUsers,
      queryParameters: {'search': query},
    );

    final List<dynamic> data = response;
    return data.map((json) => UserSearchResultModel.fromJson(json)).toList();
  }

  @override
  Future<ConnectionRequestModel> sendRequest({
    String? receiverEmail,
    int? receiverId,
  }) async {
    final body = {
      if (receiverEmail != null) 'receiver_email': receiverEmail,
      if (receiverId != null) 'receiver_id': receiverId,
    };

    final response = await post(ApiEndpoints.sendRequest, body: body);

    return ConnectionRequestModel.fromJson(response['request']);
  }

  @override
  Future<BulkSendRequestResponseModel> bulkSendRequest({
    required List<int> receiverIds,
  }) async {
    // Convert receiver IDs to the format backend expects
    final receivers = receiverIds.map((id) => {'user_id': id}).toList();

    final body = {'receivers': receivers};

    final response = await post(ApiEndpoints.bulkSendRequest, body: body);

    return BulkSendRequestResponseModel.fromJson(response);
  }

  @override
  Future<List<ConnectionRequestModel>> getSentRequests() async {
    final response = await get(ApiEndpoints.sentRequests);

    final List<dynamic> data = response;
    return data.map((json) => ConnectionRequestModel.fromJson(json)).toList();
  }

  @override
  Future<List<ConnectionRequestModel>> getReceivedRequests() async {
    final response = await get(ApiEndpoints.receivedRequests);

    final List<dynamic> data = response;
    return data.map((json) => ConnectionRequestModel.fromJson(json)).toList();
  }

  @override
  Future<List<ConnectionRequestModel>> getPendingReceivedRequests() async {
    final response = await get(ApiEndpoints.pendingReceivedRequests);

    final List<dynamic> data = response;
    return data.map((json) => ConnectionRequestModel.fromJson(json)).toList();
  }

  @override
  Future<List<ConnectedUserModel>> getConnectedUsers() async {
    final response = await get(ApiEndpoints.connectedUsers);

    final List<dynamic> data = response;
    return data.map((json) => ConnectedUserModel.fromJson(json)).toList();
  }

  @override
  Future<ConnectionRequestModel> updateRequestStatus({
    required int requestId,
    required String status,
  }) async {
    final body = {'status': status};

    final response = await patch(
      ApiEndpoints.updateRequestStatus(requestId),
      body: body,
    );

    return ConnectionRequestModel.fromJson(response['request']);
  }

  @override
  Future<Map<String, dynamic>> deleteConnection({
    int? userId,
    int? requestId,
  }) async {
    final body = {
      if (userId != null) 'user_id': userId,
      if (requestId != null) 'request_id': requestId,
    };

    final response = await delete(ApiEndpoints.deleteConnection, body: body);

    return response;
  }
}
