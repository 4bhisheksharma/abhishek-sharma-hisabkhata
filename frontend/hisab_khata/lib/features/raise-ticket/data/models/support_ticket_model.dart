import 'package:hisab_khata/features/raise-ticket/domain/entities/support_ticket_entity.dart';

class SupportTicketModel {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? adminResponse;
  final int? resolvedById;
  final String? resolvedByName;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.adminResponse,
    this.resolvedById,
    this.resolvedByName,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'] as int,
      userId: json['user'] as int,
      userName: json['user_name'] as String,
      userEmail: json['user_email'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      adminResponse: json['admin_response'] as String?,
      resolvedById: json['resolved_by'] as int?,
      resolvedByName: json['resolved_by_name'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'user_name': userName,
      'user_email': userEmail,
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'admin_response': adminResponse,
      'resolved_by': resolvedById,
      'resolved_by_name': resolvedByName,
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SupportTicketEntity toEntity() {
    return SupportTicketEntity(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      subject: subject,
      description: description,
      category: category,
      priority: priority,
      status: status,
      adminResponse: adminResponse,
      resolvedById: resolvedById,
      resolvedByName: resolvedByName,
      resolvedAt: resolvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
