import 'dart:convert';
import 'dart:developer';

import 'package:official_gold/view_model/data/network/data_providers/trades_providers.dart';

import '../../../../model/commission_rate_model.dart';
import '../../../../model/new_trades.dart';
import '../../../../model/trade_model.dart';


class TradesRepository {

  late final TradesProvider productProvider;

  TradesRepository() {
    productProvider = TradesProvider();
  }



///////////////////////////////////////////////////////////////////////////////////////////// old trades
  Future<List<TradeOrOrder>> trades() async {
    try {
      final tradesResponse = await productProvider.trades();
      // log(jsonEncode(tradesResponse?.data));
      return (tradesResponse?.data?['result'] as List).map((e) => TradeOrOrder.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

/////////////////////////////////////////////////////////////////////////////////////////////// new trades by eng gomaa
  Future<Tradess> tradess() async {
    try {
      final tradesResponse = await productProvider.tradess();

      final data = tradesResponse?.data;
      if (data is Map<String, dynamic>) {
        return Tradess.fromJson(data);
      }

      // لو data جاية Map بس مش typed
      if (data is Map) {
        return Tradess.fromJson(Map<String, dynamic>.from(data));
      }

      // fallback
      return Tradess(success: false, message: "Invalid response", groupOfTradesOrOrders: []);
    } catch (e) {
      rethrow;
    }
  }

/////////////////////////////////////////////////////////////////////////////////////////////// new orders by eng gomaa

  Future<Tradess> orderss() async {
    try {
      final ordersResponse = await productProvider.orderss();

      final data = ordersResponse?.data;
      if (data is Map<String, dynamic>) {
        return Tradess.fromJson(data);
      }

      // لو data جاية Map بس مش typed
      if (data is Map) {
        return Tradess.fromJson(Map<String, dynamic>.from(data));
      }

      // fallback
      return Tradess(success: false, message: "Invalid response", groupOfTradesOrOrders: []);
    } catch (e) {
      rethrow;
    }
  }






/////////////////////////////////////////////////////////////////////////////////////////////// get Commission Rate

  Future<CommissionRateModel> getCommissionRate() async {
    try {
      final response = await productProvider.getCommissionRate();

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return CommissionRateModel.fromJson(data);
      }

      if (data is Map) {
        return CommissionRateModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      return CommissionRateModel(
        success: false,
        message: "Invalid response",
        result: null,
      );
    } catch (e) {
      rethrow;
    }
  }














/////////////////////////////////////////////////////////////////////////////////////////////// old orders




  // Future<void> orders() async {
  //   try {
  //     final ordersResponse = await productProvider.orders();
  //     log(jsonEncode(ordersResponse?.data));
  //     // return (tradesResponse?.data?['result'] as List).map((e) => Product.fromJson(e)).toList();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }


///////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> updateTrade({required orderId}) async {
    try {
      final updateTradeResponse = await productProvider.updateTrade(orderId: orderId);
      log(jsonEncode(updateTradeResponse?.data));
      // return (tradesResponse?.data?['result'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTrade({required orderId}) async {
    try {
      final deleteTradeResponse = await productProvider.deleteTrade(orderId: orderId);
      log(jsonEncode(deleteTradeResponse?.data));
      // return (tradesResponse?.data?['result'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeTrade({required orderId,required closePrice}) async {
    try {
      final closeTradeResponse = await productProvider.closeTrade(orderId: orderId,closePrice: closePrice);
      log(jsonEncode(closeTradeResponse?.data));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeOrder({required orderId}) async {
    try {
      final closeOrderResponse = await productProvider.closeOrder(orderId: orderId);
      log(jsonEncode(closeOrderResponse?.data));
    } catch (e) {
      rethrow;
    }















    Future<void> sellTrade({required orderId}) async {
    try {
      final sellTradeResponse = await productProvider.sellTrade(orderId: orderId);
      log(jsonEncode(sellTradeResponse?.data));
      // return (tradesResponse?.data?['result'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Future<List<Product>> products({required int categoryId}) async {
  //   try {
  //     final productsResponse = await productProvider.products(categoryId: categoryId);
  //     if(productsResponse?.data?['result'] == null || productsResponse?.data?['result'][0]['error'] != null) {
  //       Toast.showError(msg: productsResponse?.data?['result'][0]['error'] ?? 'Error on Get Products');
  //       return [];
  //     }
  //     return (productsResponse?.data?['result'] as List).map((e) => Product.fromJson(e)).toList();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}}
