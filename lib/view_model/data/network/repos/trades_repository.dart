import 'dart:convert';
import 'dart:developer';

import 'package:official_gold/view_model/data/network/data_providers/trades_providers.dart';

import '../../../../model/new_trades.dart';
import '../../../../model/trades.dart';

class TradesRepository {

  late final TradesProvider productProvider;

  TradesRepository() {
    productProvider = TradesProvider();
  }



///////////////////////////////////////////////////////////////////////////////////////////// old trades
  Future<List<Trades>> trades() async {
    try {
      final tradesResponse = await productProvider.trades();
      // log(jsonEncode(tradesResponse?.data));
      return (tradesResponse?.data?['result'] as List).map((e) => Trades.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

/////////////////////////////////////////////////////////////////////////////////////////////// new trades by eng gomaa
  Future<List<Tradess>> tradess() async {
    try {
      final tradesResponse = await productProvider.tradess();
      return (tradesResponse?.data?['result'] as List).map((e) => Tradess.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }




/////////////////////////////////////////////////////////////////////////////////////////////// old orders




  Future<void> orders() async {
    try {
      final ordersResponse = await productProvider.orders();
      log(jsonEncode(ordersResponse?.data));
      // return (tradesResponse?.data?['result'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
/////////////////////////////////////////////////////////////////////////////////////////////// new orders by eng gomaa
  Future<void> orderss() async {
    try {
      final ordersResponse = await productProvider.orderss();
      log(jsonEncode(ordersResponse?.data));
      // return (tradesResponse?.data?['result'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }


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
}
