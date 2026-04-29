import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/ticket.dart';
import '../../../model/ticket.dart' as ticket;
import '../../data/network/repos/ticket_repository.dart';
part 'ticket_state.dart';


class TicketCubit extends Cubit<TicketState> {
  TicketCubit() : super(TicketInitial());

  static TicketCubit get(context) => BlocProvider.of<TicketCubit>(context);

  List<Ticket> tickets = [];

  Future<void> getTickets() async {
    emit(GetTicketsLoadingState());
    await TicketRepository().tickets().then((List<Ticket> value) {
      tickets = value;
      emit(GetTicketsSuccessState(value));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get Tickets');
        emit(GetTicketsErrorState(
            msg: error.response?.data?['message'].toString()));
      }
    });
  }

  List<ticket.Response> ticketResponses = [];

  Future<void> getTicketResponse(int id) async {
    emit(GetTicketResponseLoadingState());
    await TicketRepository().ticketResponses(id).then((List<ticket.Response> value) {
      ticketResponses = value;
      emit(GetTicketResponseSuccessState(value));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get Ticket Response');
        emit(GetTicketResponseErrorState(
            msg: error.response?.data?['message'].toString()));
      }
    });
  }

  TextEditingController responseController = TextEditingController();

  Future<void> makeResponse(int ticketId) async {
    emit(MakeResponseLoadingState());
    await TicketRepository().makeResponse(ticketId, responseController.text).then((value) {
      responseController.clear();
      ticketResponses.add(value);
      emit(MakeResponseSuccessState(ticketResponses));
      getTicketResponse(ticketId);
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Make Response');
        emit(MakeResponseErrorState(
            msg: error.response?.data?['message'].toString()));
      }
    });
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController ticketController = TextEditingController();

  Future<void> makeTicket() async {
    if (formKey.currentState!.validate() && state is! MakeTicketLoadingState) {
      emit(MakeTicketLoadingState());
      await TicketRepository().makeTicket(ticketController.text).then((value) {
        ticketController.clear();
        tickets.add(value);
        emit(MakeTicketSuccessState(value));
      }).catchError((error) {
        if (error is DioException) {
          debugPrint(error.response?.data?.toString() ?? 'Error on Make Ticket');
          emit(MakeTicketErrorState(
              msg: error.response?.data?['message'].toString()));
        }
      });
    }
  }
}
