import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/raise-ticket/domain/usecases/create_ticket_usecase.dart';
import 'package:hisab_khata/features/raise-ticket/domain/usecases/get_my_tickets_usecase.dart';
import 'package:hisab_khata/features/raise-ticket/domain/usecases/get_ticket_by_id_usecase.dart';
import 'package:hisab_khata/features/raise-ticket/presentation/bloc/ticket_event.dart';
import 'package:hisab_khata/features/raise-ticket/presentation/bloc/ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final CreateTicketUseCase createTicketUseCase;
  final GetMyTicketsUseCase getMyTicketsUseCase;
  final GetTicketByIdUseCase getTicketByIdUseCase;

  TicketBloc({
    required this.createTicketUseCase,
    required this.getMyTicketsUseCase,
    required this.getTicketByIdUseCase,
  }) : super(const TicketInitial()) {
    on<CreateTicketEvent>(_onCreateTicket);
    on<LoadMyTicketsEvent>(_onLoadMyTickets);
    on<LoadTicketByIdEvent>(_onLoadTicketById);
    on<RefreshTicketsEvent>(_onRefreshTickets);
  }

  Future<void> _onCreateTicket(
    CreateTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketCreating());

    final result = await createTicketUseCase(
      subject: event.subject,
      description: event.description,
      category: event.category,
      priority: event.priority,
    );

    result.fold(
      (failure) => emit(TicketError(failure.failureMessage)),
      (ticket) => emit(TicketCreated(ticket)),
    );
  }

  Future<void> _onLoadMyTickets(
    LoadMyTicketsEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());

    final result = await getMyTicketsUseCase();

    result.fold(
      (failure) => emit(TicketError(failure.failureMessage)),
      (tickets) => emit(TicketsLoaded(tickets)),
    );
  }

  Future<void> _onLoadTicketById(
    LoadTicketByIdEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(const TicketLoading());

    final result = await getTicketByIdUseCase(event.ticketId);

    result.fold(
      (failure) => emit(TicketError(failure.failureMessage)),
      (ticket) => emit(TicketDetailLoaded(ticket)),
    );
  }

  Future<void> _onRefreshTickets(
    RefreshTicketsEvent event,
    Emitter<TicketState> emit,
  ) async {
    final result = await getMyTicketsUseCase();

    result.fold(
      (failure) => emit(TicketError(failure.failureMessage)),
      (tickets) => emit(TicketsLoaded(tickets)),
    );
  }
}
