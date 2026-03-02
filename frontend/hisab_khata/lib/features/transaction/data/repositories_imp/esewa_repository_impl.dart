import '../../data/datasources/esewa_remote_data_source.dart';
import '../../domain/entities/esewa_entities.dart';
import '../../domain/repositories/esewa_repository.dart';

class EsewaRepositoryImpl implements EsewaRepository {
  final EsewaRemoteDataSource remoteDataSource;

  EsewaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BusinessEsewaAccount?> getBusinessEsewaAccount() async {
    final data = await remoteDataSource.getBusinessEsewaAccount();
    if (data == null) return null;
    return BusinessEsewaAccount.fromJson(data);
  }

  @override
  Future<BusinessEsewaAccount> linkEsewaAccount({
    required String esewaId,
    required String accountName,
  }) async {
    final data = await remoteDataSource.linkEsewaAccount(
      esewaId: esewaId,
      accountName: accountName,
    );
    return BusinessEsewaAccount.fromJson(data);
  }

  @override
  Future<BusinessEsewaAccount> updateEsewaAccount({
    String? esewaId,
    String? accountName,
  }) async {
    final data = await remoteDataSource.updateEsewaAccount(
      esewaId: esewaId,
      accountName: accountName,
    );
    return BusinessEsewaAccount.fromJson(data);
  }

  @override
  Future<void> unlinkEsewaAccount() async {
    await remoteDataSource.unlinkEsewaAccount();
  }

  @override
  Future<BusinessEsewaStatus> checkBusinessEsewaStatus(
    int relationshipId,
  ) async {
    final data = await remoteDataSource.checkBusinessEsewaStatus(
      relationshipId,
    );
    return BusinessEsewaStatus.fromJson(data);
  }

  @override
  Future<EsewaPaymentInitiation> initiateEsewaPayment({
    required int relationshipId,
    required double amount,
    String? description,
  }) async {
    final data = await remoteDataSource.initiateEsewaPayment(
      relationshipId: relationshipId,
      amount: amount,
      description: description,
    );
    return EsewaPaymentInitiation.fromJson(data);
  }

  @override
  Future<bool> verifyEsewaPayment({
    required int paymentRecordId,
    required String esewaRefId,
    required String esewaProductId,
    required String totalAmount,
    required String status,
    Map<String, dynamic>? esewaResponse,
  }) async {
    final response = await remoteDataSource.verifyEsewaPayment(
      paymentRecordId: paymentRecordId,
      esewaRefId: esewaRefId,
      esewaProductId: esewaProductId,
      totalAmount: totalAmount,
      status: status,
      esewaResponse: esewaResponse,
    );
    return response['status'] == 200;
  }
}
