import 'package:equatable/equatable.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class CreateTicketEvent extends TicketEvent {
  final String subject;
  final String description;
  final String category;
  final String priority;

  const CreateTicketEvent({
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
  });

  @override
  List<Object?> get props => [subject, description, category, priority];
}

class LoadMyTicketsEvent extends TicketEvent {
  const LoadMyTicketsEvent();
}

class LoadTicketByIdEvent extends TicketEvent {
  final int ticketId;

  const LoadTicketByIdEvent(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class RefreshTicketsEvent extends TicketEvent {
  const RefreshTicketsEvent();
}
