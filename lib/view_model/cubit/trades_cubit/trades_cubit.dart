import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/trades_repository.dart';
import '../../../model/commission_rate_model.dart';
import '../../../model/trade_order_group.dart';
part 'trades_state.dart';

class TradesCubit extends Cubit<TradesState> {
  TradesCubit() : super(TradesInitial());

  static TradesCubit get(context) => BlocProvider.of<TradesCubit>(context);

  /////////////////////////////////////////////////////////////////////////////////
  // open trade list
  final Set<String> _expandedGroupKeys = {};
  bool isGroupExpanded(String key) => _expandedGroupKeys.contains(key);

  void toggleGroup(String key) {
    if (_expandedGroupKeys.contains(key)) {
      _expandedGroupKeys.remove(key);
    } else {
      _expandedGroupKeys.add(key);
    }
    emit(TradesExpandedChanged(Set<String>.from(_expandedGroupKeys)));
  }

  /////////////////////////////////////////////////////////////////////////////////
  // open order list
  final Set<String> _expandedOrderGroupKeys = {};
  bool isOrderGroupExpanded(String key) =>
      _expandedOrderGroupKeys.contains(key);

  void toggleOrderGroup(String key) {
    if (_expandedOrderGroupKeys.contains(key)) {
      _expandedOrderGroupKeys.remove(key);
    } else {
      _expandedOrderGroupKeys.add(key);
    }
    emit(TradesExpandedChanged(Set<String>.from(_expandedOrderGroupKeys)));
  }

  ////////////////////////////////////////////////////////// ///// //////// get Tradess
  // trades list
  List<GroupOfTradesOrOrders> groupOfTradesOrOrders = [];
  bool isTradesRefreshing = false;

  Future<void> getTradess({bool showShimmer = true}) async {
    print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< TTTTTTTTTTTTTTTTTTTTTTTTTTT");
    if (showShimmer) {
      emit(GetTradesLoadingState());
    } else {
      isTradesRefreshing = true;
      emit(TradesRefreshingState());
    }

    try {
      final res = await TradesRepository().tradess();
      groupOfTradesOrOrders = res.groupOfTradesOrOrders ?? [];
      isTradesRefreshing = false;
      emit(GetTradesSuccessState());
    } on DioException catch (error) {
      isTradesRefreshing = false;
      debugPrint('Error: ${error.response?.data}');
      emit(GetTradesErrorState());
    } catch (error) {
      isTradesRefreshing = false;
      debugPrint('Error: $error');
      emit(GetTradesErrorState());
    }
  }

  ///////////////////////////////////////////////////////////////////////////////// get Orderss
  // orders list
  List<GroupOfTradesOrOrders> wholeOrders = [];
  bool isOrdersRefreshing = false;

  Future<void> getOrderss({bool showShimmer = true}) async {
    print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ooooooooooooooooooooooooooooooo");
    if (showShimmer) {
      emit(GetOrdersLoadingState());
    } else {
      isOrdersRefreshing = true;
      emit(OrdersRefreshingState());
    }

    try {
      final res = await TradesRepository().orderss();
      wholeOrders = res.groupOfTradesOrOrders ?? [];
      isOrdersRefreshing = false;
      emit(GetOrdersSuccessState());
    } on DioException catch (error) {
      isOrdersRefreshing = false;
      debugPrint('Error: ${error.response?.data}');
      emit(GetOrdersErrorState());
    } catch (error) {
      isOrdersRefreshing = false;
      debugPrint('Error: $error');
      emit(GetOrdersErrorState());
    }
  }

  ///////////////////////////////////////////////////////////////////////////////// close Trade
  // close trade
  Future<void> closeTrade({required orderId, required closePrice}) async {

    print("orderId : $orderId, closePrice: $closePrice");



    emit(CloseTradeLoadingState());
    await TradesRepository()
        .closeTrade(orderId: orderId, closePrice: closePrice)
        .then((value) async {
      emit(CloseTradeSuccessState());
      // ✅ بعد العملية: اعمل get مع shimmer
      await getTradess(showShimmer: false);
    }).catchError((error) {
      if (error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      } else {
        debugPrint('Error: $error');
      }
      emit(CloseTradeErrorState());
    });
  }

  ///////////////////////////////////////////////////////////////////////////////// closeOrder
  // close order (delete pending)
  Future<void> closeOrder({required orderId}) async {
    emit(CloseOrderLoadingState());
    await TradesRepository().closeOrder(orderId: orderId).then((value) async {
      emit(CloseOrderSuccessState());

      // ✅ بعد العملية: اعمل get مع shimmer
      await getOrderss(showShimmer: false);
    }).catchError((error) {
      if (error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      } else {
        debugPrint('Error: $error');
      }
      emit(CloseOrderErrorState());
    });
  }

  ///////////////////////////////////////////////////////////////////////////////// get Commission Rate
  CommissionRateResult? commissionRate;
  num? commissionRateValue; // الرقم نفسه (0.1)
  Future<void> getCommissionRate() async {
    emit(GetCommissionRateLoadingState());
    try {
      final res = await TradesRepository().getCommissionRate();
      // خزّن الريسبونس كامل
      commissionRate = res.result;
      // خزّن الرقم لوحده
      commissionRateValue = res.result?.commissionRate;

      emit(GetCommissionRateSuccessState());
    } on DioException catch (error) {
      debugPrint('Commission Rate Error: ${error.response?.data}');
      emit(
        GetCommissionRateErrorState(
          msg: error.response?.data?['message']?.toString(),
        ),
      );
    } catch (error) {
      debugPrint('Commission Rate Error: $error');
      emit(GetCommissionRateErrorState(msg: error.toString()));
    }
  }
num calculateCommission(num amount) {
  final rate = commissionRateValue ?? 0;
  return (amount * rate) / 100;
}















}