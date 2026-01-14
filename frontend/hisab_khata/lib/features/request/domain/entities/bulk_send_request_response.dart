import 'package:equatable/equatable.dart';
import 'bulk_request_result.dart';

class BulkSendRequestResponse extends Equatable {
  final List<BulkRequestResult> successful;
  final List<BulkRequestResult> failed;
  final List<BulkRequestResult> skipped;
  final int totalProcessed;
  final String message;

  const BulkSendRequestResponse({
    required this.successful,
    required this.failed,
    required this.skipped,
    required this.totalProcessed,
    required this.message,
  });

  bool get hasFailures => failed.isNotEmpty;
  bool get hasSuccesses => successful.isNotEmpty;
  bool get hasSkipped => skipped.isNotEmpty;
  bool get isFullySuccessful => successful.length == totalProcessed;
  bool get isPartiallySuccessful => successful.isNotEmpty && (failed.isNotEmpty || skipped.isNotEmpty);

  @override
  List<Object?> get props => [successful, failed, skipped, totalProcessed, message];
}
