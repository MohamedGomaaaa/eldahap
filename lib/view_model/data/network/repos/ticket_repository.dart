import 'package:official_gold/model/response.dart';
import 'package:official_gold/model/ticket.dart';
import 'package:official_gold/view_model/data/network/data_providers/ticket_providers.dart';


class TicketRepository {
  late final TicketProvider ticketProvider;

  TicketRepository() {
    ticketProvider = TicketProvider();
  }

  Future<Ticket> makeTicket(String message) async {
    try {
      final makeTicketResponse = await ticketProvider.makeTicket(message);
      return Ticket.fromJson(makeTicketResponse?.data?['result']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Ticket>> tickets() async {
    try {
      final ticketsResponse = await ticketProvider.tickets();
      return (ticketsResponse?.data?['result'] as List)
          .map((e) => Ticket.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Response>> ticketResponses(int id) async {
    try {
      final ticketResponsesResponse = await ticketProvider.ticketResponses(id);
      return (ticketResponsesResponse?.data?['result'] as List)
          .map((e) => Response.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> makeResponse(int ticketId, String response) async {
    try {
      final makeResponseResponse = await ticketProvider.makeResponse(ticketId, response);
      return Response.fromJson(makeResponseResponse?.data?['result']);
    } catch (e) {
      rethrow;
    }
  }
}
