import 'package:equatable/equatable.dart';

class ConnectionRequest extends Equatable {
  final int businessCustomerRequestId;
  final int sender;
  final String senderEmail;
  final String senderName;
  final String? senderPhone;
  final String? senderProfilePicture;
  final int receiver;
  final String receiverEmail;
  final String receiverName;
  final String? receiverPhone;
  final String? receiverProfilePicture;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConnectionRequest({
    required this.businessCustomerRequestId,
    required this.sender,
    required this.senderEmail,
    required this.senderName,
    this.senderPhone,
    this.senderProfilePicture,
    required this.receiver,
    required this.receiverEmail,
    required this.receiverName,
    this.receiverPhone,
    this.receiverProfilePicture,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [
    businessCustomerRequestId,
    sender,
    senderEmail,
    senderName,
    senderPhone,
    senderProfilePicture,
    receiver,
    receiverEmail,
    receiverName,
    receiverPhone,
    receiverProfilePicture,
    status,
    createdAt,
    updatedAt,
  ];
}
