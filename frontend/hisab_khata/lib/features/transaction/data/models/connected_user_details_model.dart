import '../../domain/entities/connected_user_details.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_model.dart';

class ConnectedUserDetailsModel extends ConnectedUserDetails {
  const ConnectedUserDetailsModel({
    required super.userId,
    required super.email,
    super.phoneNumber,
    required super.fullName,
    super.profilePicture,
    required super.isBusiness,
    super.businessId,
    super.businessName,
    super.customerId,
    required super.relationshipId,
    required super.connectedAt,
    required super.toPay,
    required super.totalPaid,
    super.isFavorite = false,
    super.transactions = const [],
  });

  factory ConnectedUserDetailsModel.fromJson(Map<String, dynamic> json) {
    // Parse transactions list
    final transactionsList =
        (json['transactions'] as List<dynamic>?)
            ?.map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
            .toList() ??
        <Transaction>[];

    return ConnectedUserDetailsModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      fullName: json['full_name'] as String,
      profilePicture: json['profile_picture'] as String?,
      isBusiness: json['is_business'] as bool,
      businessId: json['business_id'] as int?,
      businessName: json['business_name'] as String?,
      customerId: json['customer_id'] as int?,
      relationshipId: json['relationship_id'] as int,
      connectedAt: DateTime.parse(json['connected_at'] as String),
      toPay: double.parse(json['to_pay'].toString()),
      totalPaid: double.parse(json['total_paid'].toString()),
      isFavorite: json['is_favorite'] as bool? ?? false,
      transactions: transactionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'profile_picture': profilePicture,
      'is_business': isBusiness,
      'business_id': businessId,
      'business_name': businessName,
      'customer_id': customerId,
      'relationship_id': relationshipId,
      'connected_at': connectedAt.toIso8601String(),
      'to_pay': toPay.toString(),
      'total_paid': totalPaid.toString(),
      'is_favorite': isFavorite,
      'transactions': transactions
          .map((t) => TransactionModel.fromEntity(t).toJson())
          .toList(),
    };
  }

  /// Convert entity to model
  factory ConnectedUserDetailsModel.fromEntity(ConnectedUserDetails entity) {
    return ConnectedUserDetailsModel(
      userId: entity.userId,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      fullName: entity.fullName,
      profilePicture: entity.profilePicture,
      isBusiness: entity.isBusiness,
      businessId: entity.businessId,
      businessName: entity.businessName,
      customerId: entity.customerId,
      relationshipId: entity.relationshipId,
      connectedAt: entity.connectedAt,
      toPay: entity.toPay,
      totalPaid: entity.totalPaid,
      isFavorite: entity.isFavorite,
      transactions: entity.transactions,
    );
  }
}
