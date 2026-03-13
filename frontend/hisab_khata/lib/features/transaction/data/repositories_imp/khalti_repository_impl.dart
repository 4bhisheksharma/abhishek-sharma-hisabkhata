import '../../domain/entities/khalti_entities.dart';
import '../../domain/repositories/khalti_repository.dart';
import '../datasources/khalti_remote_data_source.dart';

class KhaltiRepositoryImpl implements KhaltiRepository {
  final KhaltiRemoteDataSource remoteDataSource;

  KhaltiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BusinessKhaltiAccount?> getBusinessKhaltiAccount() async {
    final data = await remoteDataSource.getBusinessKhaltiAccount();
    if (data == null) return null;
    return BusinessKhaltiAccount.fromJson(data);
  }

  @override
  Future<BusinessKhaltiAccount> linkKhaltiAccount({
    required String khaltiId,
    required String accountName,
  }) async {
    final data = await remoteDataSource.linkKhaltiAccount(
      khaltiId: khaltiId,
      accountName: accountName,
    );
    return BusinessKhaltiAccount.fromJson(data);
  }

  @override
  Future<BusinessKhaltiAccount> updateKhaltiAccount({
    String? khaltiId,
    String? accountName,
  }) async {
    final data = await remoteDataSource.updateKhaltiAccount(
      khaltiId: khaltiId,
      accountName: accountName,
    );
    return BusinessKhaltiAccount.fromJson(data);
  }

  @override
  Future<void> unlinkKhaltiAccount() async {
    await remoteDataSource.unlinkKhaltiAccount();
  }

  @override
  Future<BusinessKhaltiStatus> checkBusinessKhaltiStatus(
    int relationshipId,
  ) async {
    final data = await remoteDataSource.checkBusinessKhaltiStatus(
      relationshipId,
    );
    return BusinessKhaltiStatus.fromJson(data);
  }

  @override
  Future<KhaltiPaymentInitiation> initiateKhaltiPayment({
    required int relationshipId,
    required double amount,
    String? description,
  }) async {
    final data = await remoteDataSource.initiateKhaltiPayment(
      relationshipId: relationshipId,
      amount: amount,
      description: description,
    );
    return KhaltiPaymentInitiation.fromJson(data);
  }

  @override
  Future<bool> verifyKhaltiPayment({
    required int paymentRecordId,
    required String pidx,
    String? transactionId,
    String? totalAmount,
    String? status,
    Map<String, dynamic>? khaltiResponse,
  }) async {
    final response = await remoteDataSource.verifyKhaltiPayment(
      paymentRecordId: paymentRecordId,
      pidx: pidx,
      transactionId: transactionId,
      totalAmount: totalAmount,
      status: status,
      khaltiResponse: khaltiResponse,
    );
    return response['status'] == 200;
  }
}
