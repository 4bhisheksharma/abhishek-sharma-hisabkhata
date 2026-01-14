import 'package:equatable/equatable.dart';

class BulkRequestResult extends Equatable {
  final int receiverId;
  final String receiverEmail;
  final String? receiverName;
  final String? error;

  const BulkRequestResult({
    required this.receiverId,
    required this.receiverEmail,
    this.receiverName,
    this.error,
  });

  bool get isSuccessful => error == null;

  @override
  List<Object?> get props => [receiverId, receiverEmail, receiverName, error];
}
