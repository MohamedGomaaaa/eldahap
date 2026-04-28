import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:official_gold/view_model/data/network/dio_helper.dart';
import 'package:official_gold/view_model/data/network/end_points.dart';

class TradesProvider {
/////////////////////////////////////////////////////////////////////////////////////////////// old trades
  Future<Response?> trades() async {
    try{
      return await DioHelper.get(
        path: EndPoints.allTrades,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }
/////////////////////////////////////////////////////////////////////////////////////////////// new trades by eng gomaa

  Future<Response> tradess() async {
    return await DioHelper.get(
      path: EndPoints.tradess, // endpoint الجديد
      withToken: true,
    );
  }
/////////////////////////////////////////////////////////////////////////////////////////////// new orders by eng gomaa


  Future<Response?> orderss() async {
    try {
      return await DioHelper.get(
        path: EndPoints.orderss, // ✅ endpoint بتاع orders
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }




/////////////////////////////////////////////////////////////////////////////////////////////// get Commission Rate


  Future<Response> getCommissionRate() async {
    return await DioHelper.get(
      path: EndPoints.commissionRate,
      withToken: true,
    );
  }






/////////////////////////////////////////////////////////////////////////////////////////////// old orders
//   Future<Response?> orders() async {
//     try{
//       return await DioHelper.get(
//         path: EndPoints.orderss,
//         withToken: true,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }



///////////////////////////////////////////////////////////////////////////////////////////////









  Future<Response?> updateTrade({required orderId}) async {
    try{
      return await DioHelper.post(
        path: EndPoints.updateTrade,
        data: {
          'order_id' : orderId,
        },
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Future<Response?> deleteTrade({required orderId}) async {
  //   try{
  //     return await DioHelper.post(
  //       path: EndPoints.deleteTrade,
  //       data: {
  //         'order_id' : orderId,
  //       },
  //       withToken: true,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }


  Future<Response?> closeTrade({
    required dynamic orderId,
    required dynamic closePrice,
  }) async {
    try {
      final params = {
        'order_id': orderId,
        // 'close_price': closePrice,
      };

      /// 🔥 طباعة البارمز
      debugPrint("📦 closeTrade params:");
      params.forEach((key, value) {
        debugPrint("$key : $value");
      });

      final response = await DioHelper.post(
        path: EndPoints.closeTrade2,
        data: params,
        withToken: true,
      );

      /// 🔥 طباعة الريسبونس (اختياري)
      debugPrint("✅ Response: ${response.data}");

      return response;
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Error: $e");
      rethrow;
    }
  }


  Future<Response?> closeOrder({required orderId}) async {
    try{
      return await DioHelper.post(
        path: EndPoints.closeOrder,
        data: {
          'order_id' : orderId,

        },
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }











  Future<Response?> sellTrade({required orderId}) async {
    try{
      return await DioHelper.post(
        path: EndPoints.sellTrade,
        data: {
          'order_id' : orderId,
        },
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Future<Response?> products({required int categoryId}) async {
  //   try{
  //     return await DioHelper.get(
  //       path: '${EndPoints.products}/$categoryId',
  //       withToken: true,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
