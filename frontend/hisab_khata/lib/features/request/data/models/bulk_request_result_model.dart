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
      receiverId: json['receiver_id'],
      receiverEmail: json['receiver_email'],
      receiverName: json['receiver_name'],
      error: json['error'],
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
