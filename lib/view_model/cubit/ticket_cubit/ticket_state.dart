part of 'ticket_cubit.dart';

@immutable
sealed class TicketState {}

final class TicketInitial extends TicketState {}

final class GetTicketsLoadingState extends TicketState {}

final class GetTicketsSuccessState extends TicketState {
  final List<Ticket> tickets;

  GetTicketsSuccessState(this.tickets);
}

final class GetTicketsErrorState extends TicketState {
  final String? msg;

  GetTicketsErrorState({this.msg});
}

final class GetTicketResponseLoadingState extends TicketState {}

final class GetTicketResponseSuccessState extends TicketState {
  final List<ticket.Response> ticketResponses;

  GetTicketResponseSuccessState(this.ticketResponses);
}

final class GetTicketResponseErrorState extends TicketState {
  final String? msg;

  GetTicketResponseErrorState({this.msg});
}

final class MakeResponseLoadingState extends TicketState {}

final class MakeResponseSuccessState extends TicketState {
  final List<ticket.Response> ticketResponses;

  MakeResponseSuccessState(this.ticketResponses);
}

final class MakeResponseErrorState extends TicketState {
  final String? msg;

  MakeResponseErrorState({this.msg});
}

final class MakeTicketLoadingState extends TicketState {}

final class MakeTicketSuccessState extends TicketState {
  final Ticket ticket;

  MakeTicketSuccessState(this.ticket);
}

final class MakeTicketErrorState extends TicketState {
  final String? msg;

  MakeTicketErrorState({this.msg});
}