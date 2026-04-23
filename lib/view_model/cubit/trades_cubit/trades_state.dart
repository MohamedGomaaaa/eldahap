part of 'trades_cubit.dart';

@immutable
sealed class TradesState {}

final class TradesInitial extends TradesState {}

final class GetTradesLoadingState extends TradesState {}

final class GetTradesSuccessState extends TradesState {}

final class GetTradesErrorState extends TradesState {}

final class GetOrdersLoadingState extends TradesState {}

final class GetOrdersSuccessState extends TradesState {}

final class GetOrdersErrorState extends TradesState {}

final class UpdateTradeLoadingState extends TradesState {}

final class UpdateTradeSuccessState extends TradesState {}

final class UpdateTradeErrorState extends TradesState {}

final class DeleteTradeLoadingState extends TradesState {}

final class DeleteTradeSuccessState extends TradesState {}

final class DeleteTradeErrorState extends TradesState {}

final class SellTradeLoadingState extends TradesState {}

final class SellTradeSuccessState extends TradesState {}

final class SellTradeErrorState extends TradesState {}


final class CloseTradeSuccessState extends TradesState {}

final class CloseTradeErrorState extends TradesState {}

final class CloseTradeLoadingState extends TradesState {}



final class CloseOrderErrorState extends TradesState {}

final class CloseOrderLoadingState extends TradesState {}

final class CloseOrderSuccessState extends TradesState {}


class TradesRefreshingState extends TradesState {}
class OrdersRefreshingState extends TradesState {}




class TradesExpandedChanged extends TradesState {
  final Set<String> expandedKeys;
  TradesExpandedChanged(this.expandedKeys);
}




class GetCommissionRateLoadingState extends TradesState {}

class GetCommissionRateSuccessState extends TradesState {}

class GetCommissionRateErrorState extends TradesState {
  final String? msg;
  GetCommissionRateErrorState({this.msg});
}




























