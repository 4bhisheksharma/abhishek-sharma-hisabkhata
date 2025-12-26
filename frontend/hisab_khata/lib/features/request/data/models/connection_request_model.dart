import '../../domain/entities/connection_request.dart';

class ConnectionRequestModel extends ConnectionRequest {
  const ConnectionRequestModel({
    required super.businessCustomerRequestId,
    required super.sender,
    required super.senderEmail,
    required super.senderName,
    super.senderPhone,
    required super.receiver,
    required super.receiverEmail,
    required super.receiverName,
    super.receiverPhone,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestModel(
      businessCustomerRequestId: json['business_customer_request_id'],
      sender: json['sender'],
      senderEmail: json['sender_email'],
      senderName: json['sender_name'],
      senderPhone: json['sender_phone'],
      receiver: json['receiver'],
      receiverEmail: json['receiver_email'],
      receiverName: json['receiver_name'],
      receiverPhone: json['receiver_phone'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_customer_request_id': businessCustomerRequestId,
      'sender': sender,
      'sender_email': senderEmail,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'receiver': receiver,
      'receiver_email': receiverEmail,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
