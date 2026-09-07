import 'package:dio/dio.dart';

import '../../services/dio_helper/dio_helper.dart';
import '../../services/end_points/end_points.dart';

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
