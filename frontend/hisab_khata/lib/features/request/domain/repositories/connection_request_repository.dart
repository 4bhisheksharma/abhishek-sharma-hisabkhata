import 'package:dartz/dartz.dart';

import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/connection_request.dart';
import '../entities/user_search_result.dart';

abstract class ConnectionRequestRepository {
  /// Search users by email or phone number
  Future<Either<Failure, List<UserSearchResult>>> searchUsers(String query);

  /// Send connection request to user by email or user ID
  Future<Either<Failure, ConnectionRequest>> sendRequest({
    String? receiverEmail,
    int? receiverId,
  });

  /// Get all requests sent by current user
  Future<Either<Failure, List<ConnectionRequest>>> getSentRequests();

  /// Get all requests received by current user
  Future<Either<Failure, List<ConnectionRequest>>> getReceivedRequests();

  /// Get pending requests received by current user
  Future<Either<Failure, List<ConnectionRequest>>> getPendingReceivedRequests();

  /// Get all connected users (accepted connections)
  Future<Either<Failure, List<ConnectionRequest>>> getConnectedUsers();

  /// Update request status (accept or reject)
  Future<Either<Failure, ConnectionRequest>> updateRequestStatus({
    required int requestId,
    required String status, // 'accepted' or 'rejected'
  });
}
