import '../../domain/entities/paginated_users_response.dart';
import '../models/user_search_result_model.dart';

class PaginatedUsersResponseModel extends PaginatedUsersResponse {
  const PaginatedUsersResponseModel({
    required super.count,
    super.next,
    super.previous,
    required super.results,
  });

  factory PaginatedUsersResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultsList = json['results'] ?? [];
    return PaginatedUsersResponseModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: resultsList
          .map((item) => UserSearchResultModel.fromJson(item))
          .toList(),
    );
  }
}
