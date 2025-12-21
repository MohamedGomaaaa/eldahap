import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/trades_repository.dart';

import '../../../model/new_trades.dart';
import '../../../model/trades.dart';

part 'trades_state.dart';

class TradesCubit extends Cubit<TradesState> {
  TradesCubit() : super(TradesInitial());

  static TradesCubit get(context) => BlocProvider.of<TradesCubit>(context);
/////////////////////////////////////////////////////////////////////////////////////////////// old get trades
  List<Trades> trades = [];

  Future<void> getTrades() async {
    emit(GetTradesLoadingState());
    await TradesRepository().trades().then((value) {
      trades.clear();
      trades = value;
      emit(GetTradesSuccessState());
    }).catchError((error) {
      if(error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      }else{
        debugPrint('Error: $error');
      }
      emit(GetTradesErrorState());
    });
  }
/////////////////////////////////////////////////////////////////////////////////////////// new get trades by eng gomaa



  List<Tradess> tradess = [];

  Future<void> getTradess() async {
    emit(GetTradesLoadingState());
    await TradesRepository().tradess().then((value) {
      tradess.clear();
      tradess = value;
      emit(GetTradesSuccessState());
    }).catchError((error) {
      if(error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      }else{
        debugPrint('Error: $error');
      }
      emit(GetTradesErrorState());
    });
  }



///////////////////////////////////////////////////////////////////////////////////////////////////////// old orders
  Future<void> getOrders() async {
    emit(GetOrdersLoadingState());
    await TradesRepository().orders().then((value) {
      emit(GetOrdersSuccessState());
    }).catchError((error) {
      if(error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      }else{
        debugPrint('Error: $error');
      }
      emit(GetOrdersErrorState());
    });
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////// new orders by eng gomaa

  Future<void> getOrderss() async {
    emit(GetOrdersLoadingState());
    await TradesRepository().orderss().then((value) {
      emit(GetOrdersSuccessState());
    }).catchError((error) {
      if(error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      }else{
        debugPrint('Error: $error');
      }
      emit(GetOrdersErrorState());
    });
  }











  Future<void> updateTrade({required orderId}) async {
    emit(UpdateTradeLoadingState());
    await TradesRepository().updateTrade(orderId: orderId).then((value) {
      emit(UpdateTradeSuccessState());
    }).catchError((error) {
      if(error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      }else{
        debugPrint('Error: $error');
      }
      emit(UpdateTradeErrorState());
    });
  }

  Future<void> deleteTrade({required orderId}) async {
    emit(DeleteTradeLoadingState());
    await TradesRepository().deleteTrade(orderId: orderId).then((value) {
      emit(DeleteTradeSuccessState());
    }).catchError((error) {
      if(error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      }else{
        debugPrint('Error: $error');
      }
      emit(DeleteTradeErrorState());
    });
  }

  Future<void> sellTrade({required orderId}) async {
    emit(SellTradeLoadingState());
    await TradesRepository().sellTrade(orderId: orderId).then((value) {
      emit(SellTradeSuccessState());
    }).catchError((error) {
      if(error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      }else{
        debugPrint('Error: $error');
      }
      emit(SellTradeErrorState());
    });
  }
}
