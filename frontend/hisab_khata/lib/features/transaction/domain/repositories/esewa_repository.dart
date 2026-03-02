import '../entities/esewa_entities.dart';

/// Repository interface for eSewa-related operations
abstract class EsewaRepository {
  // ─── Business side ────────────────────────────────────────────────

  /// Get the current business's linked eSewa account (null if not linked)
  Future<BusinessEsewaAccount?> getBusinessEsewaAccount();

  /// Link an eSewa account to the business
  Future<BusinessEsewaAccount> linkEsewaAccount({
    required String esewaId,
    required String accountName,
  });

  /// Update the linked eSewa account
  Future<BusinessEsewaAccount> updateEsewaAccount({
    String? esewaId,
    String? accountName,
  });

  /// Unlink the eSewa account
  Future<void> unlinkEsewaAccount();

  // ─── Customer side ────────────────────────────────────────────────

  /// Check if the business in a relationship has eSewa linked
  Future<BusinessEsewaStatus> checkBusinessEsewaStatus(int relationshipId);

  /// Initiate an eSewa payment (creates a backend record, returns SDK params)
  Future<EsewaPaymentInitiation> initiateEsewaPayment({
    required int relationshipId,
    required double amount,
    String? description,
  });

  /// Verify an eSewa payment after SDK success callback
  Future<bool> verifyEsewaPayment({
    required int paymentRecordId,
    required String esewaRefId,
    required String esewaProductId,
    required String totalAmount,
    required String status,
    Map<String, dynamic>? esewaResponse,
  });
}
