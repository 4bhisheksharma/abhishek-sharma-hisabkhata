import '../../../../core/data/base_remote_data_source.dart';

/// Remote data source for eSewa-related API calls
class EsewaRemoteDataSource extends BaseRemoteDataSource {
  EsewaRemoteDataSource({super.client});

  // ─── Business eSewa Account ─────────────────────────────────────────

  /// GET /transaction/esewa/account/
  Future<Map<String, dynamic>?> getBusinessEsewaAccount() async {
    final response = await get('transaction/esewa/account/');
    final data = response as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>?;
  }

  /// POST /transaction/esewa/account/
  Future<Map<String, dynamic>> linkEsewaAccount({
    required String esewaId,
    required String accountName,
  }) async {
    final response = await post(
      'transaction/esewa/account/',
      body: {'esewa_id': esewaId, 'account_name': accountName},
    );
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  /// PATCH /transaction/esewa/account/
  Future<Map<String, dynamic>> updateEsewaAccount({
    String? esewaId,
    String? accountName,
  }) async {
    final body = <String, dynamic>{};
    if (esewaId != null) body['esewa_id'] = esewaId;
    if (accountName != null) body['account_name'] = accountName;

    final response = await patch('transaction/esewa/account/', body: body);
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  /// DELETE /transaction/esewa/account/
  Future<void> unlinkEsewaAccount() async {
    await delete('transaction/esewa/account/', body: {});
  }

  // ─── Customer eSewa Payment ─────────────────────────────────────────

  /// GET /transaction/esewa/status/{relationship_id}/
  Future<Map<String, dynamic>> checkBusinessEsewaStatus(
    int relationshipId,
  ) async {
    final response = await get('transaction/esewa/status/$relationshipId/');
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  /// POST /transaction/esewa/initiate/
  Future<Map<String, dynamic>> initiateEsewaPayment({
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

    final response = await post('transaction/esewa/initiate/', body: body);
    return (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  /// POST /transaction/esewa/verify/
  Future<Map<String, dynamic>> verifyEsewaPayment({
    required int paymentRecordId,
    required String esewaRefId,
    required String esewaProductId,
    required String totalAmount,
    required String status,
    Map<String, dynamic>? esewaResponse,
  }) async {
    final body = <String, dynamic>{
      'payment_record_id': paymentRecordId,
      'esewa_ref_id': esewaRefId,
      'esewa_product_id': esewaProductId,
      'total_amount': totalAmount,
      'status': status,
    };
    if (esewaResponse != null) {
      body['esewa_response'] = esewaResponse;
    }

    final response = await post('transaction/esewa/verify/', body: body);
    return response as Map<String, dynamic>;
  }
}
