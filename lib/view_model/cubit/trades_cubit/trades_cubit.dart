import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/trades_repository.dart';
import '../../../model/new_trades.dart';
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
  bool isOrderGroupExpanded(String key) => _expandedOrderGroupKeys.contains(key);

  void toggleOrderGroup(String key) {
    if (_expandedOrderGroupKeys.contains(key)) {
      _expandedOrderGroupKeys.remove(key);
    } else {
      _expandedOrderGroupKeys.add(key);
    }
    emit(TradesExpandedChanged(Set<String>.from(_expandedOrderGroupKeys)));
  }

  //////////////////////////////////////////////////////// ////// ////// //////// ///// ////////
  // trades list
  List<GroupOfTradesOrOrders> groupOfTradesOrOrders = [];
  bool isTradesRefreshing = false;

  Future<void> getTradess({bool showShimmer = true}) async {
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

  /////////////////////////////////////////////////////////////////////////////////
  // orders list
  List<GroupOfTradesOrOrders> wholeOrders = [];
  bool isOrdersRefreshing = false;

  Future<void> getOrderss({bool showShimmer = true}) async {
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

  /////////////////////////////////////////////////////////////////////////////////
  // close trade
  Future<void> closeTrade({required orderId, required closePrice}) async {
    emit(CloseTradeLoadingState());
    await TradesRepository()
        .closeTrade(orderId: orderId, closePrice: closePrice)
        .then((value) async {
      emit(CloseTradeSuccessState());

      // ✅ بعد العملية: اعمل get مع shimmer
      // await getTradess(showShimmer: false);
    }).catchError((error) {
      if (error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      } else {
        debugPrint('Error: $error');
      }
      emit(CloseTradeErrorState());
    });
  }







  /////////////////////////////////////////////////////////////////////////////////
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
}

// class TradesCubit extends Cubit<TradesState> {
//   TradesCubit() : super(TradesInitial());
//
//   static TradesCubit get(context) => BlocProvider.of<TradesCubit>(context);
//
// /////////////////////////////////////////////////////////////////////////////////////////////  open trade list
//   final Set<String> _expandedGroupKeys = {};
//
//   bool isGroupExpanded(String key) => _expandedGroupKeys.contains(key);
//   void toggleGroup(String key) {
//     if (_expandedGroupKeys.contains(key)) {
//       _expandedGroupKeys.remove(key);
//     } else {
//       _expandedGroupKeys.add(key);
//     }
//     emit(TradesExpandedChanged(Set<String>.from(_expandedGroupKeys)));
//   }
//
// /////////////////////////////////////////////////////////////////////////////////////////////  open order list
//   final Set<String> _expandedOrderGroupKeys = {};
//
//   bool isOrderGroupExpanded(String key) => _expandedOrderGroupKeys.contains(key);
//
//   void toggleOrderGroup(String key) {
//     if (_expandedOrderGroupKeys.contains(key)) {
//       _expandedOrderGroupKeys.remove(key);
//     } else {
//       _expandedOrderGroupKeys.add(key);
//     }
//     emit(TradesExpandedChanged(Set<String>.from(_expandedOrderGroupKeys)));
//   }
//
//
// /////////////////////////////////////////////////////////////////////////////////////////// new get trades by eng gomaa
//
//    List<Result> wholeTrade = [];
//
//   Future<void> getTradess() async {
//     emit(GetTradesLoadingState());
//
//     try {
//       final res = await TradesRepository().tradess(); // Tradess
//       wholeTrade = res.result ?? [];
//       emit(GetTradesSuccessState());
//     } on DioException catch (error) {
//       debugPrint('Error: ${error.response?.data}');
//       emit(GetTradesErrorState());
//     } catch (error) {
//       debugPrint('Error: $error');
//       emit(GetTradesErrorState());
//     }
//   }
//
//
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// new orders by eng gomaa
//
// // ✅ orders list
//   List<Result> wholeOrders = [];
//
//   Future<void> getOrderss() async {
//     emit(GetOrdersLoadingState());
//
//     try {
//       final res = await TradesRepository().orderss(); // ✅ Tradess response برضه (success/message/result)
//       wholeOrders = res.result ?? [];
//       emit(GetOrdersSuccessState());
//     } on DioException catch (error) {
//       debugPrint('Error: ${error.response?.data}');
//       emit(GetOrdersErrorState());
//     } catch (error) {
//       debugPrint('Error: $error');
//       emit(GetOrdersErrorState());
//     }
//   }
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// updateTrade
//
//   //
//   //
//   // Future<void> closeTrade({required orderId,required closePrice }) async {
//   //   emit(CloseTradeLoadingState());
//   //   await TradesRepository().closeTrade(orderId: orderId,closePrice: closePrice).then((value) {
//   //     emit(CloseTradeSuccessState());
//   //     getTradess();
//   //   }).catchError((error) {
//   //     if (error is DioException) {
//   //       debugPrint('Error: ${error.response?.data}');
//   //     } else {
//   //       debugPrint('Error: $error');
//   //     }
//   //     emit(CloseTradeErrorState());
//   //   });
//   // }
//   //
//   // Future<void> closeOrder({required orderId, }) async {
//   //   emit(CloseOrderLoadingState());
//   //   await TradesRepository().closeOrder(orderId: orderId).then((value) {
//   //     emit(CloseOrderSuccessState());
//   //     getOrderss();
//   //   }).catchError((error) {
//   //     if (error is DioException) {
//   //       debugPrint('Error: ${error.response?.data}');
//   //     } else {
//   //       debugPrint('Error: $error');
//   //     }
//   //     emit(CloseOrderErrorState());
//   //   });
//   // }
//   //
//   //
//
//   Future<void> closeTrade({required orderId, required closePrice}) async {
//     emit(CloseTradeLoadingState());
//     await TradesRepository()
//         .closeTrade(orderId: orderId, closePrice: closePrice)
//         .then((value) async {
//       emit(CloseTradeSuccessState());
//       await getTradess(showShimmer: false); // ✅
//     }).catchError((error) {
//       if (error is DioException) {
//         debugPrint('Error: ${error.response?.data}');
//       } else {
//         debugPrint('Error: $error');
//       }
//       emit(CloseTradeErrorState());
//     });
//   }
//
//   Future<void> closeOrder({required orderId}) async {
//     emit(CloseOrderLoadingState());
//     await TradesRepository().closeOrder(orderId: orderId).then((value) async {
//       emit(CloseOrderSuccessState());
//       await getOrderss(showShimmer: false); // ✅
//     }).catchError((error) {
//       if (error is DioException) {
//         debugPrint('Error: ${error.response?.data}');
//       } else {
//         debugPrint('Error: $error');
//       }
//       emit(CloseOrderErrorState());
//     });
//   }
//
//
//       }
