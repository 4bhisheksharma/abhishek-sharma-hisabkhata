import 'package:equatable/equatable.dart';
import 'user_search_result.dart';

class PaginatedUsersResponse extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<UserSearchResult> results;

  const PaginatedUsersResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasNextPage => next != null;
  bool get hasPreviousPage => previous != null;

  int get currentPage {
    if (previous == null) return 1;
    final uri = Uri.tryParse(previous!);
    final prevPage = int.tryParse(uri?.queryParameters['page'] ?? '0') ?? 0;
    return prevPage + 1;
  }

  @override
  List<Object?> get props => [count, next, previous, results];
}
