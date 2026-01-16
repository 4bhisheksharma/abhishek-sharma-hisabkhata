import 'package:equatable/equatable.dart';

class SupportTicketEntity extends Equatable {
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

  const SupportTicketEntity({
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

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';

  bool get isUrgent => priority == 'urgent';
  bool get isHighPriority => priority == 'high';

  String get statusDisplay {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  String get categoryDisplay {
    switch (category) {
      case 'account':
        return 'Account Issue';
      case 'app':
        return 'App Issue';
      case 'system':
        return 'System Issue';
      case 'feature_request':
        return 'Feature Request';
      case 'bug_report':
        return 'Bug Report';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userEmail,
        subject,
        description,
        category,
        priority,
        status,
        adminResponse,
        resolvedById,
        resolvedByName,
        resolvedAt,
        createdAt,
        updatedAt,
      ];
}
