import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/bulk_send_request_response.dart';
import '../../domain/entities/connection_request.dart';
import '../../domain/entities/connected_user.dart';
import '../../domain/entities/paginated_users_response.dart';
import '../../domain/entities/user_search_result.dart';
import '../../domain/repositories/connection_request_repository.dart';
import '../datasource/connection_request_remote_data_source.dart';

class ConnectionRequestRepositoryImpl implements ConnectionRequestRepository {
  final ConnectionRequestRemoteDataSource remoteDataSource;

  ConnectionRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserSearchResult>>> searchUsers(
    String query,
  ) async {
    try {
      final result = await remoteDataSource.searchUsers(query);
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedUsersResponse>> fetchPaginatedUsers({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await remoteDataSource.fetchPaginatedUsers(
        search: search,
        page: page,
        pageSize: pageSize,
      );
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConnectionRequest>> sendRequest({
    String? receiverEmail,
    int? receiverId,
  }) async {
    try {
      final result = await remoteDataSource.sendRequest(
        receiverEmail: receiverEmail,
        receiverId: receiverId,
      );
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BulkSendRequestResponse>> bulkSendRequest({
    required List<int> receiverIds,
  }) async {
    try {
      final result = await remoteDataSource.bulkSendRequest(
        receiverIds: receiverIds,
      );
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConnectionRequest>>> getSentRequests() async {
    try {
      final result = await remoteDataSource.getSentRequests();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConnectionRequest>>> getReceivedRequests() async {
    try {
      final result = await remoteDataSource.getReceivedRequests();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConnectionRequest>>>
  getPendingReceivedRequests() async {
    try {
      final result = await remoteDataSource.getPendingReceivedRequests();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConnectedUser>>> getConnectedUsers() async {
    try {
      final result = await remoteDataSource.getConnectedUsers();
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConnectionRequest>> updateRequestStatus({
    required int requestId,
    required String status,
  }) async {
    try {
      final result = await remoteDataSource.updateRequestStatus(
        requestId: requestId,
        status: status,
      );
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteConnection({
    int? userId,
    int? requestId,
  }) async {
    try {
      final result = await remoteDataSource.deleteConnection(
        userId: userId,
        requestId: requestId,
      );
      return Right(result);
    } on UnauthenticatedException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
