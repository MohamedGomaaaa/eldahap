import 'package:dio/dio.dart';
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

  Future<Response?> deleteTrade({required orderId}) async {
    try{
      return await DioHelper.post(
        path: EndPoints.deleteTrade,
        data: {
          'order_id' : orderId,
        },
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<Response?> closeTrade({required orderId,required closePrice}) async {
    try{
      return await DioHelper.post(
        path: EndPoints.closeTrade,
        data: {
          'order_id' : orderId,
          "close_price": closePrice
        },
        withToken: true,
      );
    } catch (e) {
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
