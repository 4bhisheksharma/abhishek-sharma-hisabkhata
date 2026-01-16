import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/features/raise-ticket/domain/entities/support_ticket_entity.dart';

abstract class TicketRepository {
  Future<Either<Failure, SupportTicketEntity>> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  });

  Future<Either<Failure, List<SupportTicketEntity>>> getMyTickets();

  Future<Either<Failure, SupportTicketEntity>> getTicketById(int ticketId);
}
