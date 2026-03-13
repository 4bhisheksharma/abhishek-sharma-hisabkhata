import '../../../../core/data/base_remote_data_source.dart';

class KhaltiRemoteDataSource extends BaseRemoteDataSource {
  KhaltiRemoteDataSource({super.client});

  // Business Khalti account
  Future<Map<String, dynamic>?> getBusinessKhaltiAccount() async {
    final response = await get('transaction/khalti/account/');
    final data = response as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> linkKhaltiAccount({
    required String khaltiId,
    required String accountName,
  }) async {
    final response = await post(
      'transaction/khalti/account/',
      body: {'khalti_id': khaltiId, 'account_name': accountName},
    );
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateKhaltiAccount({
    String? khaltiId,
    String? accountName,
  }) async {
    final body = <String, dynamic>{};
    if (khaltiId != null) body['khalti_id'] = khaltiId;
    if (accountName != null) body['account_name'] = accountName;

    final response = await patch('transaction/khalti/account/', body: body);
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  Future<void> unlinkKhaltiAccount() async {
    await delete('transaction/khalti/account/', body: {});
  }

  // Customer Khalti payment
  Future<Map<String, dynamic>> checkBusinessKhaltiStatus(int relationshipId) async {
    final response = await get('transaction/khalti/status/$relationshipId/');
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> initiateKhaltiPayment({
    required int relationshipId,
    required double amount,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'relationship_id': relationshipId,
      'amount': amount.toStringAsFixed(2),
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    final response = await post('transaction/khalti/initiate/', body: body);
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyKhaltiPayment({
    required int paymentRecordId,
    required String pidx,
    String? transactionId,
    String? totalAmount,
    String? status,
    Map<String, dynamic>? khaltiResponse,
  }) async {
    final body = <String, dynamic>{
      'payment_record_id': paymentRecordId,
      'pidx': pidx,
      'transaction_id': transactionId ?? '',
      'total_amount': totalAmount ?? '',
      'status': status ?? '',
    };
    if (khaltiResponse != null) {
      body['khalti_response'] = khaltiResponse;
    }

    final response = await post('transaction/khalti/verify/', body: body);
    return response as Map<String, dynamic>;
  }
}
