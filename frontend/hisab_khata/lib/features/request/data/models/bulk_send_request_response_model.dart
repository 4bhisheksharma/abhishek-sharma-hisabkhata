import '../../domain/entities/bulk_send_request_response.dart';
import 'bulk_request_result_model.dart';

class BulkSendRequestResponseModel extends BulkSendRequestResponse {
  const BulkSendRequestResponseModel({
    required super.successful,
    required super.failed,
    required super.skipped,
    required super.totalProcessed,
    required super.message,
  });

  factory BulkSendRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return BulkSendRequestResponseModel(
      successful: (json['successful'] as List<dynamic>)
          .map((e) => BulkRequestResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      failed: (json['failed'] as List<dynamic>)
          .map((e) => BulkRequestResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      skipped: (json['skipped'] as List<dynamic>)
          .map((e) => BulkRequestResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalProcessed: json['total_processed'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'successful': successful.map((e) => (e as BulkRequestResultModel).toJson()).toList(),
      'failed': failed.map((e) => (e as BulkRequestResultModel).toJson()).toList(),
      'skipped': skipped.map((e) => (e as BulkRequestResultModel).toJson()).toList(),
      'total_processed': totalProcessed,
      'message': message,
    };
  }
}
