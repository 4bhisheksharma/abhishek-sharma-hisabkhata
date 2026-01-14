import '../../domain/entities/bulk_request_result.dart';

class BulkRequestResultModel extends BulkRequestResult {
  const BulkRequestResultModel({
    required super.receiverId,
    required super.receiverEmail,
    super.receiverName,
    super.error,
  });

  factory BulkRequestResultModel.fromJson(Map<String, dynamic> json) {
    return BulkRequestResultModel(
      receiverId: json['user_id'] as int,
      receiverEmail: json['email'] as String,
      receiverName: json['full_name'] as String?,
      error: (json['error'] ?? json['reason']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
      'receiver_email': receiverEmail,
      'receiver_name': receiverName,
      'error': error,
    };
  }
}
