

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/trade_order_model.dart';

import '../../../../view_model/data/network/repos/trades_repository.dart';
import 'order_state.dart';



class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());

  static OrderCubit get(BuildContext context) =>
      BlocProvider.of<OrderCubit>(context);
  final TextEditingController stopLossController = TextEditingController();
  final TextEditingController takeProfitController = TextEditingController();

  bool stopLossEnabled = false;
  bool takeProfitEnabled = false;
  double stopLossAmount = 0.0;
  double takeProfitAmount = 0.0;



  // OrderModel? currentOrder;
  //
  // void loadOrder(OrderModel order) {
  //   currentOrder = order;
  //   emit(OrderLoaded(order));
  // }kllkkl






  TradeOrOrder? currentOrder;

  void loadOrder(TradeOrOrder order) {
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
////////////////////////////////////////////////////////////////////////////////////

  // Future<void> getOrderss({bool showShimmer = true}) async {
  //   if (showShimmer) {
  //     emit(GetOrdersLoadingState());
  //   } else {
  //     isOrdersRefreshing = true;
  //     emit(OrdersRefreshingState());
  //   }
  //
  //   try {
  //     final res = await TradesRepository().orderss();
  //     wholeOrders = res.result ?? [];
  //     isOrdersRefreshing = false;
  //     emit(GetOrdersSuccessState());
  //   } on DioException catch (error) {
  //     isOrdersRefreshing = false;
  //     debugPrint('Error: ${error.response?.data}');
  //     emit(GetOrdersErrorState());
  //   } catch (error) {
  //     isOrdersRefreshing = false;
  //     debugPrint('Error: $error');
  //     emit(GetOrdersErrorState());
  //   }
  // }

  // void deleteOrder() {
  //   // Call API to delete order
  //   emit(OrderDeleted());
  // }

//////////////////////////////////////////////////////////////////////////////////// delete order
  Future<void> deleteOrder({required orderId}) async {
    emit(CloseOrderLoadingState());
    await TradesRepository().closeOrder(orderId: orderId).then((value) async {
      emit(CloseOrderSuccessState());
      // ✅ بعد العملية: اعمل get مع shimmer
      // await getOrderss(showShimmer: false);
    }).catchError((error) {
      if (error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      } else {
        debugPrint('Error: $error');
      }
      emit(CloseOrderErrorState());
    });
  }




















  // void saveOrder() {
  //   // Call API to save order with stop loss and take profit
  //   final data = {
  //     'stopLoss': stopLossEnabled ? stopLossAmount : null,
  //     'takeProfit': takeProfitEnabled ? takeProfitAmount : null,
  //   };
  //   // Send to backend
  //   print('Saving order: $data');
  // }


  // Future<void> closeTrade({required orderId, required closePrice}) async {
  //   emit(CloseTradeLoadingState());
  //   await TradesRepository()
  //       .closeTrade(orderId: orderId, closePrice: closePrice)
  //       .then((value) async {
  //     emit(CloseTradeSuccessState());
  //
  //     // ✅ بعد العملية: اعمل get مع shimmer
  //     // await getTradess(showShimmer: false);
  //   }).catchError((error) {
  //     if (error is DioException) {
  //       debugPrint('Error: ${error.response?.data}');
  //     } else {
  //       debugPrint('Error: $error');
  //     }
  //     emit(CloseTradeErrorState());
  //   });
  // }



  @override
  Future<void> close() {
    stopLossController.dispose();
    takeProfitController.dispose();
    return super.close();
  }
}