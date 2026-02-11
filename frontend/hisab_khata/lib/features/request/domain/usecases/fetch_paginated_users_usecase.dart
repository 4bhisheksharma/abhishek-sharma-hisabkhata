import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/paginated_users_response.dart';
import '../repositories/connection_request_repository.dart';

class FetchPaginatedUsersUseCase {
  final ConnectionRequestRepository repository;

  FetchPaginatedUsersUseCase(this.repository);

  Future<Either<Failure, PaginatedUsersResponse>> call({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await repository.fetchPaginatedUsers(
      search: search,
      page: page,
      pageSize: pageSize,
    );
  }
}
