import '../../domain/entities/connected_user_details.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';

/// Implementation of TransactionRepository
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<ConnectedUserDetails> getConnectedUserDetails(int relationshipId) async {
    return await _remoteDataSource.getConnectedUserDetails(relationshipId);
  }

  @override
  Future<List<Transaction>> getTransactionsByRelationship(int relationshipId) async {
    return await _remoteDataSource.getTransactionsByRelationship(relationshipId);
  }

  @override
  Future<Transaction> createTransaction({
    required int relationshipId,
    required double amount,
    required TransactionType type,
    String? description,
  }) async {
    return await _remoteDataSource.createTransaction(
      relationshipId: relationshipId,
      amount: amount,
      type: type,
      description: description,
    );
  }

  @override
  Future<void> addToFavorites(int businessId) async {
    await _remoteDataSource.addToFavorites(businessId);
  }

  @override
  Future<void> removeFromFavorites(int businessId) async {
    await _remoteDataSource.removeFromFavorites(businessId);
  }

  @override
  Future<bool> isFavorite(int businessId) async {
    return await _remoteDataSource.isFavorite(businessId);
  }

  @override
  Future<List<FavoriteBusiness>> getFavorites() async {
    return await _remoteDataSource.getFavorites();
  }
}
