

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'order_model.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  final TextEditingController stopLossController = TextEditingController();
  final TextEditingController takeProfitController = TextEditingController();

  bool stopLossEnabled = false;
  bool takeProfitEnabled = false;
  double stopLossAmount = 0.0;
  double takeProfitAmount = 0.0;

  OrderModel? currentOrder;

  void loadOrder(OrderModel order) {
    currentOrder = order;
    emit(OrderLoaded(order));
  }

  void toggleStopLoss(bool value) {
    stopLossEnabled = value;
    if (!value) {
      stopLossController.clear();
      stopLossAmount = 0.0;
    }
    emit(StopLossToggled(value));
  }

  void toggleTakeProfit(bool value) {
    takeProfitEnabled = value;
    if (!value) {
      takeProfitController.clear();
      takeProfitAmount = 0.0;
    }
    emit(TakeProfitToggled(value));
  }

  void addStopLossAmount() {
    final current = double.tryParse(stopLossController.text) ?? 0.0;
    final newAmount = current + 1.0;
    stopLossAmount = newAmount;
    stopLossController.text = newAmount.toStringAsFixed(2);
    emit(StopLossAmountChanged(newAmount));
  }

  void subtractStopLossAmount() {
    final current = double.tryParse(stopLossController.text) ?? 0.0;
    if (current > 0) {
      final newAmount = current - 1.0;
      stopLossAmount = newAmount;
      stopLossController.text = newAmount.toStringAsFixed(2);
      emit(StopLossAmountChanged(newAmount));
    }
  }

  void addTakeProfitAmount() {
    final current = double.tryParse(takeProfitController.text) ?? 0.0;
    final newAmount = current + 1.0;
    takeProfitAmount = newAmount;
    takeProfitController.text = newAmount.toStringAsFixed(2);
    emit(TakeProfitAmountChanged(newAmount));
  }

  void subtractTakeProfitAmount() {
    final current = double.tryParse(takeProfitController.text) ?? 0.0;
    if (current > 0) {
      final newAmount = current - 1.0;
      takeProfitAmount = newAmount;
      takeProfitController.text = newAmount.toStringAsFixed(2);
      emit(TakeProfitAmountChanged(newAmount));
    }
  }

  void deleteOrder() {
    // Call API to delete order
    emit(OrderDeleted());
  }

  void saveOrder() {
    // Call API to save order with stop loss and take profit
    final data = {
      'stopLoss': stopLossEnabled ? stopLossAmount : null,
      'takeProfit': takeProfitEnabled ? takeProfitAmount : null,
    };
    // Send to backend
    print('Saving order: $data');
  }

  @override
  Future<void> close() {
    stopLossController.dispose();
    takeProfitController.dispose();
    return super.close();
  }
}