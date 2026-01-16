import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/features/raise-ticket/domain/entities/support_ticket_entity.dart';
import 'package:hisab_khata/features/raise-ticket/domain/repositories/ticket_repository.dart';

class GetMyTicketsUseCase {
  final TicketRepository repository;

  GetMyTicketsUseCase(this.repository);

  Future<Either<Failure, List<SupportTicketEntity>>> call() async {
    return await repository.getMyTickets();
  }
}
