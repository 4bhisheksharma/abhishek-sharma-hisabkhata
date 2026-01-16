import 'package:hisab_khata/core/data/base_remote_data_source.dart';
import 'package:hisab_khata/features/raise-ticket/data/models/create_ticket_request.dart';
import 'package:hisab_khata/features/raise-ticket/data/models/support_ticket_model.dart';

abstract class TicketRemoteDataSource {
  Future<SupportTicketModel> createTicket(CreateTicketRequest request);
  Future<List<SupportTicketModel>> getMyTickets();
  Future<SupportTicketModel> getTicketById(int ticketId);
}

class TicketRemoteDataSourceImpl extends BaseRemoteDataSource
    implements TicketRemoteDataSource {
  TicketRemoteDataSourceImpl({super.client});

  @override
  Future<SupportTicketModel> createTicket(CreateTicketRequest request) async {
    final response = await post(
      'support/tickets/',
      body: request.toJson(),
      includeAuth: true,
    );
    return SupportTicketModel.fromJson(response);
  }

  @override
  Future<List<SupportTicketModel>> getMyTickets() async {
    final response = await get(
      'support/tickets/my_tickets/',
      includeAuth: true,
    );
    final List<dynamic> data = response;
    return data.map((json) => SupportTicketModel.fromJson(json)).toList();
  }

  @override
  Future<SupportTicketModel> getTicketById(int ticketId) async {
    final response = await get('support/tickets/$ticketId/', includeAuth: true);
    return SupportTicketModel.fromJson(response);
  }
}
