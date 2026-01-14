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
    // Backend returns results nested in 'results' object
    final results = json['results'] as Map<String, dynamic>;
    final summary = json['summary'] as Map<String, dynamic>;

    return BulkSendRequestResponseModel(
      successful: (results['successful'] as List<dynamic>)
          .map(
            (e) => BulkRequestResultModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      failed: (results['failed'] as List<dynamic>)
          .map(
            (e) => BulkRequestResultModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      skipped: (results['skipped'] as List<dynamic>)
          .map(
            (e) => BulkRequestResultModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      totalProcessed: json['total_requested'] as int,
      message: summary['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'successful': successful
          .map((e) => (e as BulkRequestResultModel).toJson())
          .toList(),
      'failed': failed
          .map((e) => (e as BulkRequestResultModel).toJson())
          .toList(),
      'skipped': skipped
          .map((e) => (e as BulkRequestResultModel).toJson())
          .toList(),
      'total_processed': totalProcessed,
      'message': message,
    };
  }
}
