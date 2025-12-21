import 'order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final OrderModel order;
  OrderLoaded(this.order);
}

class StopLossToggled extends OrderState {
  final bool isEnabled;
  StopLossToggled(this.isEnabled);
}

class TakeProfitToggled extends OrderState {
  final bool isEnabled;
  TakeProfitToggled(this.isEnabled);
}

class StopLossAmountChanged extends OrderState {
  final double amount;
  StopLossAmountChanged(this.amount);
}

class TakeProfitAmountChanged extends OrderState {
  final double amount;
  TakeProfitAmountChanged(this.amount);
}

class OrderDeleted extends OrderState {}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}