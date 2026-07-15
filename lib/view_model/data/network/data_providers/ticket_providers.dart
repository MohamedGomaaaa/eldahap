import 'package:dio/dio.dart';
import 'package:official_gold/view_model/data/network/dio_helper.dart';
import 'package:official_gold/view_model/data/network/end_points.dart';

class TicketProvider {
  TicketProvider();

  Future<Response?> makeTicket(String message) async {
    try{
      return await DioHelper.post(
        path: EndPoints.makeTickets,
        data: {
          'message' : message,
        },
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> tickets() async {
    try{
      return await DioHelper.get(
        path: EndPoints.tickets,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> ticketResponses(int id) async {
    try{
      return await DioHelper.get(
        path: '${EndPoints.ticketResponses}/$id',
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> makeResponse(int ticketId, String response) async {
    try{
      return await DioHelper.post(
        path: EndPoints.makeResponse,
        data: {
          'ticket_id' : ticketId,
          'response' : response,
        },
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
