import '../entities/connected_user_details.dart';
import '../entities/transaction.dart';

/// Repository interface for transaction-related operations
abstract class TransactionRepository {
  /// Get connected user details with transactions
  /// [relationshipId] - The ID of the customer-business relationship
  Future<ConnectedUserDetails> getConnectedUserDetails(int relationshipId);

  /// Get all transactions for a relationship
  /// [relationshipId] - The ID of the customer-business relationship
  Future<List<Transaction>> getTransactionsByRelationship(int relationshipId);

  /// Create a new transaction
  /// [relationshipId] - The ID of the relationship
  /// [amount] - Transaction amount
  /// [type] - Transaction type (purchase, payment, credit, refund, adjustment)
  /// [description] - Optional description
  Future<Transaction> createTransaction({
    required int relationshipId,
    required double amount,
    required TransactionType type,
    String? description,
  });

  /// Add a business to favorites (customer only)
  /// [businessId] - The ID of the business to favorite
  Future<void> addToFavorites(int businessId);

  /// Remove a business from favorites (customer only)
  /// [businessId] - The ID of the business to unfavorite
  Future<void> removeFromFavorites(int businessId);

  /// Check if a business is favorited (customer only)
  /// [businessId] - The ID of the business to check
  Future<bool> isFavorite(int businessId);

  /// Get all favorite businesses (customer only)
  Future<List<FavoriteBusiness>> getFavorites();
}

/// Simple class for favorite business info
class FavoriteBusiness {
  final int favoriteId;
  final int businessId;
  final String businessName;
  final String? businessProfilePicture;
  final DateTime createdAt;

  const FavoriteBusiness({
    required this.favoriteId,
    required this.businessId,
    required this.businessName,
    this.businessProfilePicture,
    required this.createdAt,
  });
}
