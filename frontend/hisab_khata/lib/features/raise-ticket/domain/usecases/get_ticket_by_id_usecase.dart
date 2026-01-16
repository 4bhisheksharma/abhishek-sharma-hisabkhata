import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/features/raise-ticket/domain/entities/support_ticket_entity.dart';
import 'package:hisab_khata/features/raise-ticket/domain/repositories/ticket_repository.dart';

class GetTicketByIdUseCase {
  final TicketRepository repository;

  GetTicketByIdUseCase(this.repository);

  Future<Either<Failure, SupportTicketEntity>> call(int ticketId) async {
    return await repository.getTicketById(ticketId);
  }
}
