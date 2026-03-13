import '../entities/khalti_entities.dart';

abstract class KhaltiRepository {
  // Business side
  Future<BusinessKhaltiAccount?> getBusinessKhaltiAccount();

  Future<BusinessKhaltiAccount> linkKhaltiAccount({
    required String khaltiId,
    required String accountName,
  });

  Future<BusinessKhaltiAccount> updateKhaltiAccount({
    String? khaltiId,
    String? accountName,
  });

  Future<void> unlinkKhaltiAccount();

  // Customer side
  Future<BusinessKhaltiStatus> checkBusinessKhaltiStatus(int relationshipId);

  Future<KhaltiPaymentInitiation> initiateKhaltiPayment({
    required int relationshipId,
    required double amount,
    String? description,
  });

  Future<bool> verifyKhaltiPayment({
    required int paymentRecordId,
    required String pidx,
    String? transactionId,
    String? totalAmount,
    String? status,
    Map<String, dynamic>? khaltiResponse,
  });
}
