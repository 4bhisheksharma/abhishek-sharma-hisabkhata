import 'package:dartz/dartz.dart';
import 'package:hisab_khata/core/errors/exceptions.dart';
import 'package:hisab_khata/core/errors/failures.dart';
import 'package:hisab_khata/features/raise-ticket/data/datasources/ticket_remote_data_source.dart';
import 'package:hisab_khata/features/raise-ticket/data/models/create_ticket_request.dart';
import 'package:hisab_khata/features/raise-ticket/domain/entities/support_ticket_entity.dart';
import 'package:hisab_khata/features/raise-ticket/domain/repositories/ticket_repository.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;

  TicketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SupportTicketEntity>> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final request = CreateTicketRequest(
        subject: subject,
        description: description,
        category: category,
        priority: priority,
      );

      final ticketModel = await remoteDataSource.createTicket(request);
      return Right(ticketModel.toEntity());
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SupportTicketEntity>>> getMyTickets() async {
    try {
      final ticketModels = await remoteDataSource.getMyTickets();
      final tickets = ticketModels.map((model) => model.toEntity()).toList();
      return Right(tickets);
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupportTicketEntity>> getTicketById(
    int ticketId,
  ) async {
    try {
      final ticketModel = await remoteDataSource.getTicketById(ticketId);
      return Right(ticketModel.toEntity());
    } on ServerException catch (e) {
      return Left(Failure(e.exceptionMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
