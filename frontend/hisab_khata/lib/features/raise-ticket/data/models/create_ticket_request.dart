class CreateTicketRequest {
  final String subject;
  final String description;
  final String category;
  final String priority;

  CreateTicketRequest({
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
    };
  }
}
