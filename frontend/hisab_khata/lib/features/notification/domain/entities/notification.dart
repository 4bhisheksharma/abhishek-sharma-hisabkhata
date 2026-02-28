import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final int notificationId;
  final int sender;
  final String senderEmail;
  final String senderName;
  final int receiver;
  final String receiverEmail;
  final String receiverName;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notification({
    required this.notificationId,
    required this.sender,
    required this.senderEmail,
    required this.senderName,
    required this.receiver,
    required this.receiverEmail,
    required this.receiverName,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  // --- Connection types ---
  bool get isConnectionRequest => type == 'connection_request';
  bool get isConnectionAccepted =>
      type == 'connection_request_accepted' || type == 'request_accepted';
  bool get isConnectionRejected =>
      type == 'connection_request_rejected' || type == 'request_rejected';
  bool get isConnectionDeleted => type == 'connection_deleted';
  bool get isConnectionCancelled => type == 'connection_request_cancelled';

  // --- Transaction types ---
  bool get isTransactionAdded => type == 'transaction_added';
  bool get isPaymentReceived => type == 'payment_received';

  // --- Reminder / limit types ---
  bool get isDueReminder => type == 'due_reminder';
  bool get isMonthlyLimitExceeded => type == 'monthly_limit_exceeded';
  bool get isBulkPaymentReminder => type == 'bulk_payment_reminder';

  // --- Favorite / loyalty types ---
  bool get isFavoriteAdded => type == 'favorite_added';
  bool get isLoyaltyPoints => type == 'loyalty_points';

  // --- Verification types ---
  bool get isVerificationApproved => type == 'verification_approved';
  bool get isVerificationRejected => type == 'verification_rejected';

  // --- System / broadcast ---
  bool get isBroadcast => type == 'broadcast';
  bool get isSystem => type == 'system';

  // --- Helper to check if it's a system-generated notification (no real sender) ---
  bool get isSystemGenerated => senderEmail == 'system' || sender == 0;

  Notification copyWith({
    int? notificationId,
    int? sender,
    String? senderEmail,
    String? senderName,
    int? receiver,
    String? receiverEmail,
    String? receiverName,
    String? title,
    String? message,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      notificationId: notificationId ?? this.notificationId,
      sender: sender ?? this.sender,
      senderEmail: senderEmail ?? this.senderEmail,
      senderName: senderName ?? this.senderName,
      receiver: receiver ?? this.receiver,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      receiverName: receiverName ?? this.receiverName,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    notificationId,
    sender,
    senderEmail,
    senderName,
    receiver,
    receiverEmail,
    receiverName,
    title,
    message,
    type,
    data,
    isRead,
    createdAt,
    updatedAt,
  ];
}
