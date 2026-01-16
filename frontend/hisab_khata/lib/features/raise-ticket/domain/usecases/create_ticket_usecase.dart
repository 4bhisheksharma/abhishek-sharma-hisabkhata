import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/features/raise-ticket/domain/entities/support_ticket_entity.dart';
import 'package:hisab_khata/features/raise-ticket/domain/repositories/ticket_repository.dart';

class CreateTicketUseCase {
  final TicketRepository repository;

  CreateTicketUseCase(this.repository);

  Future<Either<Failure, SupportTicketEntity>> call({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    return await repository.createTicket(
      subject: subject,
      description: description,
      category: category,
      priority: priority,
    );
  }
}
