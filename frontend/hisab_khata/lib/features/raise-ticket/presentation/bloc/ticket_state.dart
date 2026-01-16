import 'package:equatable/equatable.dart';
import 'package:hisab_khata/features/raise-ticket/domain/entities/support_ticket_entity.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {
  const TicketInitial();
}

class TicketLoading extends TicketState {
  const TicketLoading();
}

class TicketCreating extends TicketState {
  const TicketCreating();
}

class TicketCreated extends TicketState {
  final SupportTicketEntity ticket;

  const TicketCreated(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class TicketsLoaded extends TicketState {
  final List<SupportTicketEntity> tickets;

  const TicketsLoaded(this.tickets);

  @override
  List<Object?> get props => [tickets];
}

class TicketDetailLoaded extends TicketState {
  final SupportTicketEntity ticket;

  const TicketDetailLoaded(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class TicketError extends TicketState {
  final String message;

  const TicketError(this.message);

  @override
  List<Object?> get props => [message];
}
