import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/trades_repository.dart';
import '../../../model/new_trades.dart';
import '../../../model/trade_model.dart';
part 'trades_state.dart';

class TradesCubit extends Cubit<TradesState> {
  TradesCubit() : super(TradesInitial());

  static TradesCubit get(context) => BlocProvider.of<TradesCubit>(context);

/////////////////////////////////////////////////////////////////////////////////////////////  open trade list
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

/////////////////////////////////////////////////////////////////////////////////////////////  open order list
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






/////////////////////////////////////////////////////////////////////////////////////////////// old get trades
//   List<Trade> trades = [];
//
//   Future<void> getTrades() async {
//     emit(GetTradesLoadingState());
//     await TradesRepository().trades().then((value) {
//       trades.clear();
//       trades = value;
//       emit(GetTradesSuccessState());
//     }).catchError((error) {
//       if(error is DioException) {
//         debugPrint('Error: ${error.response?.data}');
//       }else{
//         debugPrint('Error: $error');
//       }
//       emit(GetTradesErrorState());
//     });
//   }

///////////////////////////////////////////////////////////////////////////////////////////////////////// old orders
//   Future<void> getOrders() async {
//     emit(GetOrdersLoadingState());
//     await TradesRepository().orders().then((value) {
//       emit(GetOrdersSuccessState());
//     }).catchError((error) {
//       if (error is DioException) {
//         debugPrint('Error: ${error.response?.data}');
//       } else {
//         debugPrint('Error: $error');
//       }
//       emit(GetOrdersErrorState());
//     });
//   }
/////////////////////////////////////////////////////////////////////////////////////////// new get trades by eng gomaa

  List<Result> wholeTrade = [];

  Future<void> getTradess() async {
    emit(GetTradesLoadingState());

    try {
      final res = await TradesRepository().tradess(); // Tradess
      wholeTrade = res.result ?? [];
      emit(GetTradesSuccessState());
    } on DioException catch (error) {
      debugPrint('Error: ${error.response?.data}');
      emit(GetTradesErrorState());
    } catch (error) {
      debugPrint('Error: $error');
      emit(GetTradesErrorState());
    }
  }


///////////////////////////////////////////////////////////////////////////////////////////////////////// new orders by eng gomaa

// ✅ orders list
  List<Result> wholeOrders = [];

  Future<void> getOrderss() async {
    emit(GetOrdersLoadingState());

    try {
      final res = await TradesRepository().orderss(); // ✅ Tradess response برضه (success/message/result)
      wholeOrders = res.result ?? [];
      emit(GetOrdersSuccessState());
    } on DioException catch (error) {
      debugPrint('Error: ${error.response?.data}');
      emit(GetOrdersErrorState());
    } catch (error) {
      debugPrint('Error: $error');
      emit(GetOrdersErrorState());
    }
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////// updateTrade

  // Future<void> updateTrade({required orderId}) async {
  //   emit(UpdateTradeLoadingState());
  //   await TradesRepository().updateTrade(orderId: orderId).then((value) {
  //     emit(UpdateTradeSuccessState());
  //   }).catchError((error) {
  //     if (error is DioException) {
  //       debugPrint('Error: ${error.response?.data}');
  //     } else {
  //       debugPrint('Error: $error');
  //     }
  //     emit(UpdateTradeErrorState());
  //   });
  // }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////// old delete
//   Future<void> deleteTrade({required orderId}) async {
//     emit(DeleteTradeLoadingState());
//     await TradesRepository().deleteTrade(orderId: orderId).then((value) {
//       emit(DeleteTradeSuccessState());
//     }).catchError((error) {
//       if (error is DioException) {
//         debugPrint('Error: ${error.response?.data}');
//       } else {
//         debugPrint('Error: $error');
//       }
//       emit(DeleteTradeErrorState());
//     });
//   }


  Future<void> closeTrade({required orderId,required closePrice }) async {
    emit(CloseTradeLoadingState());
    await TradesRepository().closeTrade(orderId: orderId,closePrice: closePrice).then((value) {
      emit(CloseTradeSuccessState());
      getTradess();
    }).catchError((error) {
      if (error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      } else {
        debugPrint('Error: $error');
      }
      emit(CloseTradeErrorState());
    });
  }







/////////////////////////////////////////////////////////////////////////////////////////////////////////////// new delete
//   void removeTradeFromGroup({required String groupKey, required int tradeId}) {
//     /// locall delete
//     for (final g in wholeTrade) {
//       if ((g.metal ?? '') == groupKey) {
//         g.orders?.removeWhere((t) => (t.id ?? -1) == tradeId);
//         break;
//       }
//     }
//     emit(GetTradesSuccessState()); // ✅ أي state يخلي UI تعمل rebuild
//   }
//
//   Future<void> deleteTrade(
//       {required int orderId, required String groupKey}) async
//   {
//     emit(DeleteTradeLoadingState());
//     try {
//       await TradesRepository().deleteTrade(orderId: orderId);
//
//       /// ✅ تحديث محلي فوري
//       removeTradeFromGroup(groupKey: groupKey, tradeId: orderId);
//
//       emit(DeleteTradeSuccessState());
//     } on DioException catch (e) {
//       debugPrint('Error: ${e.response?.data}');
//       emit(DeleteTradeErrorState());
//     } catch (e) {
//       debugPrint('Error: $e');
//       emit(DeleteTradeErrorState());
//     }
//   }
////////////////////////////////////////////////////////////////////////////////////////////////// sell trade
//   Future<void> sellTrade({required orderId}) async {
//     emit(SellTradeLoadingState());
//     await TradesRepository().sellTrade(orderId: orderId).then((value) {
//       emit(SellTradeSuccessState());
//     }).catchError((error) {
//       if (error is DioException) {
//         debugPrint('Error: ${error.response?.data}');
//       } else {
//         debugPrint('Error: $error');
//       }
//       emit(SellTradeErrorState());
//     });
//   }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////// old

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
//
//
//
//
// /////////////////////////////////////////////////////////////////////////////////////////////// old get trades
// //   List<Trade> trades = [];
// //
// //   Future<void> getTrades() async {
// //     emit(GetTradesLoadingState());
// //     await TradesRepository().trades().then((value) {
// //       trades.clear();
// //       trades = value;
// //       emit(GetTradesSuccessState());
// //     }).catchError((error) {
// //       if(error is DioException) {
// //         debugPrint('Error: ${error.response?.data}');
// //       }else{
// //         debugPrint('Error: $error');
// //       }
// //       emit(GetTradesErrorState());
// //     });
// //   }
//
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// old orders
// //   Future<void> getOrders() async {
// //     emit(GetOrdersLoadingState());
// //     await TradesRepository().orders().then((value) {
// //       emit(GetOrdersSuccessState());
// //     }).catchError((error) {
// //       if (error is DioException) {
// //         debugPrint('Error: ${error.response?.data}');
// //       } else {
// //         debugPrint('Error: $error');
// //       }
// //       emit(GetOrdersErrorState());
// //     });
// //   }
// /////////////////////////////////////////////////////////////////////////////////////////// new get trades by eng gomaa
//
//   List<Result> wholeTrade = [];
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
// // Future<void> updateTrade({required orderId}) async {
// //   emit(UpdateTradeLoadingState());
// //   await TradesRepository().updateTrade(orderId: orderId).then((value) {
// //     emit(UpdateTradeSuccessState());
// //   }).catchError((error) {
// //     if (error is DioException) {
// //       debugPrint('Error: ${error.response?.data}');
// //     } else {
// //       debugPrint('Error: $error');
// //     }
// //     emit(UpdateTradeErrorState());
// //   });
// // }
//
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////// old delete
// //   Future<void> deleteTrade({required orderId}) async {
// //     emit(DeleteTradeLoadingState());
// //     await TradesRepository().deleteTrade(orderId: orderId).then((value) {
// //       emit(DeleteTradeSuccessState());
// //     }).catchError((error) {
// //       if (error is DioException) {
// //         debugPrint('Error: ${error.response?.data}');
// //       } else {
// //         debugPrint('Error: $error');
// //       }
// //       emit(DeleteTradeErrorState());
// //     });
// //   }
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////// new delete
// //   void removeTradeFromGroup({required String groupKey, required int tradeId}) {
// //     /// locall delete
// //     for (final g in wholeTrade) {
// //       if ((g.metal ?? '') == groupKey) {
// //         g.orders?.removeWhere((t) => (t.id ?? -1) == tradeId);
// //         break;
// //       }
// //     }
// //     emit(GetTradesSuccessState()); // ✅ أي state يخلي UI تعمل rebuild
// //   }
// //
// //   Future<void> deleteTrade(
// //       {required int orderId, required String groupKey}) async
// //   {
// //     emit(DeleteTradeLoadingState());
// //     try {
// //       await TradesRepository().deleteTrade(orderId: orderId);
// //
// //       /// ✅ تحديث محلي فوري
// //       removeTradeFromGroup(groupKey: groupKey, tradeId: orderId);
// //
// //       emit(DeleteTradeSuccessState());
// //     } on DioException catch (e) {
// //       debugPrint('Error: ${e.response?.data}');
// //       emit(DeleteTradeErrorState());
// //     } catch (e) {
// //       debugPrint('Error: $e');
// //       emit(DeleteTradeErrorState());
// //     }
// //   }
// ////////////////////////////////////////////////////////////////////////////////////////////////// sell trade
// //   Future<void> sellTrade({required orderId}) async {
// //     emit(SellTradeLoadingState());
// //     await TradesRepository().sellTrade(orderId: orderId).then((value) {
// //       emit(SellTradeSuccessState());
// //     }).catchError((error) {
// //       if (error is DioException) {
// //         debugPrint('Error: ${error.response?.data}');
// //       } else {
// //         debugPrint('Error: $error');
// //       }
// //       emit(SellTradeErrorState());
// //     });
// //   }
// }

