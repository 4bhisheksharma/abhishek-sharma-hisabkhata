import '../../../../core/data/base_remote_data_source.dart';
import '../models/transaction_model.dart';
import '../models/connected_user_details_model.dart';
import '../models/favorite_business_model.dart';
import '../../domain/entities/transaction.dart';

/// Remote data source for transaction-related API calls
class TransactionRemoteDataSource extends BaseRemoteDataSource {
  TransactionRemoteDataSource({super.client});

  /// Get connected user details with transactions
  /// GET /transaction/connection-details/{relationship_id}/
  Future<ConnectedUserDetailsModel> getConnectedUserDetails(
    int relationshipId,
  ) async {
    final response = await get(
      'transaction/connection-details/$relationshipId/',
    );
    return ConnectedUserDetailsModel.fromJson(response as Map<String, dynamic>);
  }

  /// Get transactions for a specific relationship
  /// GET /transaction/transactions/by_relationship/?relationship_id=X
  Future<List<TransactionModel>> getTransactionsByRelationship(
    int relationshipId,
  ) async {
    final response = await get(
      'transaction/transactions/by_relationship/',
      queryParameters: {'relationship_id': relationshipId.toString()},
    );

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create a new transaction
  /// POST /transaction/transactions/
  Future<TransactionModel> createTransaction({
    required int relationshipId,
    required double amount,
    required TransactionType type,
    String? description,
  }) async {
    final response = await post(
      'transaction/transactions/',
      body: {
        'relationship_id': relationshipId,
        'amount': amount.toString(),
        'transaction_type': type.name,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );

    return TransactionModel.fromJson(response as Map<String, dynamic>);
  }

  /// Add a business to favorites
  /// POST /transaction/favorites/
  Future<FavoriteBusinessModel> addToFavorites(int businessId) async {
    final response = await post(
      'transaction/favorites/',
      body: {'business_id': businessId},
    );

    return FavoriteBusinessModel.fromJson(response as Map<String, dynamic>);
  }

  /// Remove a business from favorites by business ID
  /// DELETE /transaction/favorites/by-business/{business_id}/
  Future<void> removeFromFavorites(int businessId) async {
    await delete('transaction/favorites/by-business/$businessId/');
  }

  /// Check if a business is favorited
  /// GET /transaction/favorites/check/?business_id=X
  Future<bool> isFavorite(int businessId) async {
    final response = await get(
      'transaction/favorites/check/',
      queryParameters: {'business_id': businessId.toString()},
    );

    return (response as Map<String, dynamic>)['is_favorite'] as bool? ?? false;
  }

  /// Get all favorite businesses
  /// GET /transaction/favorites/
  Future<List<FavoriteBusinessModel>> getFavorites() async {
    final response = await get('transaction/favorites/');

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map(
          (json) =>
              FavoriteBusinessModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
