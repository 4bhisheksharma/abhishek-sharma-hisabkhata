import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import '../entities/user_search_result.dart';
import '../repositories/connection_request_repository.dart';

class SearchUsersUseCase {
  final ConnectionRequestRepository repository;

  SearchUsersUseCase(this.repository);

  Future<Either<Failure, List<UserSearchResult>>> call(String query) async {
    return await repository.searchUsers(query);
  }
}
