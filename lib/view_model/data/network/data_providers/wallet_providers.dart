import 'package:dio/dio.dart';
import 'package:official_gold/view_model/data/network/dio_helper.dart';
import 'package:official_gold/view_model/data/network/end_points.dart';

class WalletProvider {
  Future<Response?> wallet() async {
    try {
      return await DioHelper.get(
        path: EndPoints.wallet,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }








  Future<Response?> convertCurrency({
    required num amount,

  }) async {
    try {
      return await DioHelper.post(
        path: EndPoints.convertCurrency,
        data: {
          "amount": amount,
          "from": "USD",
          "to": "EGP"

        },
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }


















// In wallet_provider.dart
  Future<Response?> transactions({int page = 1, int perPage = 10}) async {
    try {
      return await DioHelper.get(
        path: "${EndPoints.transactions}/?type=&is_approval=&date_from=2024-08-01&date_to=2025-09-23&per_page=$perPage&page=$page",
        withToken: true,

      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> currencies() async {
    try {
      return await DioHelper.get(
        path: EndPoints.currencies,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> payUsdt({required String currency, required num amount, String? message}) async {
    try {
      return await DioHelper.post(
        path: EndPoints.payUsdt,
        withToken: true,
        data: {
          'currency': currency,
          'amount': amount,
          if(message != null && message.isNotEmpty)
          'message': message,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> depositReports() async {
    try {
      return await DioHelper.get(
        path: EndPoints.reportDeposit,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> withdrawReports() async {
    try {
      return await DioHelper.get(
        path: EndPoints.reportWithdraw,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> withdraw({required num amount,}) async {
    try {
      return await DioHelper.post(
        path: EndPoints.makeWithdraw,
        withToken: true,
        data: {
          'amount': amount,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> deposit({required num amount,}) async {
    try {
      return await DioHelper.post(
        path: EndPoints.makeDeposit,
        withToken: true,
        data: {
          'amount': amount,
        },
      );
    } catch (e) {
      rethrow;
    }
  }





  Future<Response?> reports({required String type}) async {
    try {
      String path;

      if (type == 'deposit') {
        path = EndPoints.reportDeposit;
      } else if (type == 'withdraw') {
        path = EndPoints.reportWithdraw;
      } else {
        throw Exception('Invalid report type: $type');
      }

      return await DioHelper.get(
        path: path,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<Response?> orderReports({required String type}) async {
    try {
      String path;

      if (type == 'pending') {
        path = EndPoints.orderPending;
      } else if (type == 'closed-trades') {
        path = EndPoints.closedTrades;
      } else {
        throw Exception('Invalid order report type: $type');
      }

      return await DioHelper.get(
        path: path,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }










}
