import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:official_gold/utils/validator.dart';

import '../../../model/payment_methods_model.dart';
import '../../../model/trade_order_model.dart';

import '../../../services/end_points/end_points.dart';
import '../../../services/shared_preference/shared_helper.dart';
import '../../../services/shared_preference/shared_keys.dart';
import '../../../utils/toast.dart';
import '../../model/static_page.dart';
import '../../view/components/app_loader.dart';
import '../../view/components/delivery_fees_dialog.dart';


class ApiResponse {
  final bool success;
  final String message;
  final StaticPageModel? result;

  ApiResponse({
    required this.success,
    required this.message,
    this.result,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      result:
          json['result'] != null ? StaticPageModel.fromJson(json['result']) : null,
    );
  }
}
// 1. Model for API Response

// 2. API Service

class ApiService {
  /*
              'Authorization': 'Bearer ${SharedHelper.get(SharedKeys.token)}',

   */
  static const String baseUrl = EndPoints.baseUrl;
  static String token = '${SharedHelper.get(SharedKeys.token)}';

  final Dio _dio = Dio();

  ApiService() {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // /payment-methods/deposit
  Future<PaymentMethodsResponse> gePaymentMethodsDeposit() async {
    try {
      final response = await _dio.get('$baseUrl' 'payment-methods/deposit');
      return PaymentMethodsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return PaymentMethodsResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error occurred',
          result: [],
        );
      } else {
        return PaymentMethodsResponse(
          success: false,
          message: 'Network error occurred',
          result: [],
        );
      }
    } catch (e) {
      return PaymentMethodsResponse(
          success: false, message: 'An unexpected error occurred', result: []);
    }
  }

  ///api/make-withdraw
  Future<PaymentMethodsResponse> gePaymentMethodsWithdraw() async {
    try {
      final response =
          await _dio.get('$baseUrl' 'payment-methods/withdraw-options');
      return PaymentMethodsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return PaymentMethodsResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error occurred',
          result: [],
        );
      } else {
        return PaymentMethodsResponse(
          success: false,
          message: 'Network error occurred',
          result: [],
        );
      }
    } catch (e) {
      return PaymentMethodsResponse(
          success: false, message: 'An unexpected error occurred', result: []);
    }
  }

// /make-deposit
  Future<ApiResponse> makeDeposit({
    required String amount,
    required String paymentMethodId,
    required String payerName,
    required String payerPhone,
    required String note,
    required String receiptPath, // 🖼️ مسار الصورة
  }) async {
    try {
      final formData = FormData.fromMap({
        'amount': amount,
        'payment_method_id': paymentMethodId,
        'payer_name': payerName,
        'payer_phone': payerPhone,
        'note': note,
        'receipt': await MultipartFile.fromFile(
          receiptPath,
          filename: receiptPath.split('/').last, // اسم الملف
        ),
      });

      final response = await _dio.post(
        '$baseUrl' 'make-deposit',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // 🔑 لازم لو الـ API بيطلب
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
        ),
      );
      Toast.showMsg(msg: response.data["message"] ?? '');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error occurred',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  Future<ApiResponse> makeWithdraw(
      {required String amount,
      required String paymentMethodId,
      required String accountName,
      required String accountPhone,
      required String bankName,
      required String bankAccount,
      required String note,
      required String address,
      required String binanceId,
      required int selectedIndex}) async {
    final requestBody = {
      'amount': amount,
      'payment_method_id': paymentMethodId,
      'account_name': accountName,
      'account_phone': accountPhone,
      'bank_name': Validator.checkString(bankName),
      'bank_account': Validator.checkString(bankAccount),
      'note': note,
      'address': address,
      'binanceId': binanceId,
      "currency": selectedIndex == 0 ? "USD" : "EGP",
    };

    print("===== POSTMAN BODY =====");
    print(const JsonEncoder.withIndent('  ').convert(requestBody));
    print("========================");

    try {
      final response = await _dio.post(
        '$baseUrl'
        'make-withdraw',
        data: requestBody,

        ///Users/mohamedhassan/StudioProjects/LiftTraineeApp
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      Toast.showMsg(msg: response.data["message"] ?? '');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error occurred',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  Future<ApiResponse> updateOrder({
    required int orderId,
    required double stopLoss,
    required double takeProfit,
    required BuildContext ctx,
  }) async {
    try {
      // ✅ ابني الـ data بشكل شرطي
      final Map<String, dynamic> data = {
        "order_id": orderId,
      };

      // ✅ متبعتش stop_loss لو = 0
      if (stopLoss > 0) {
        data["stop_loss"] = stopLoss;
      }

      // ✅ متبعتش take_profit لو = 0
      if (takeProfit > 0) {
        data["take_profit"] = takeProfit;
      }
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $data");
      final response = await _dio.put(
        '$baseUrl'
        'order/update',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      Toast.showMsg(msg: response.data["message"] ?? '');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        Toast.showMsg(
            msg: e.response?.data['message'] ?? 'Server error occurred');
        AppLoader.closeLoader(ctx, const ValueKey("updateOrder"));
        return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        AppLoader.closeLoader(ctx, const ValueKey("updateOrder"));
        return ApiResponse(
          success: false,
          message: 'Network error occurred',
        );
      }
    } catch (e) {
      AppLoader.closeLoader(ctx, const ValueKey("updateOrder"));
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Future<ApiResponse> updateOrder({
  //   required int orderId,
  //   required double stopLoss,
  //   required double takeProfit,
  //   required BuildContext ctx,
  //
  // }) async
  // {
  //   try {
  //     final response = await _dio.put(
  //       '$baseUrl'
  //       'order/update',
  //       data: {
  //         "order_id": orderId,
  //         "stop_loss": stopLoss,
  //          "take_profit": takeProfit,
  //
  //       },
  //       ///Users/mohamedhassan/StudioProjects/LiftTraineeApp
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Accept': 'application/json',
  //         },
  //       ),
  //     );
  //     Toast.showMsg(msg: response.data["message"] ?? '');
  //     return ApiResponse.fromJson(response.data);
  //   } on DioException catch (e) {
  //
  //     if (e.response != null) {
  //       Toast.showMsg(
  //           msg: e.response?.data['message'] ?? 'Server error occurred');
  //       AppLoader.closeLoader(ctx, ValueKey("updateOrder"));
  //       return ApiResponse(
  //         success: false,
  //         message: e.response?.data['message'] ?? 'Server error occurred',
  //       );
  //     } else {
  //       AppLoader.closeLoader(ctx, ValueKey("updateOrder"));
  //
  //       return ApiResponse(
  //         success: false,
  //         message: 'Network error occurred',
  //       );
  //     }
  //   } catch (e) {
  //     AppLoader.closeLoader(ctx, ValueKey("updateOrder"));
  //
  //     return ApiResponse(
  //       success: false,
  //       message: 'An unexpected error occurred',
  //     );
  //   }
  // }

// /order/sell

  Future<ApiResponse> sellOrder(
      {required int orderId, required BuildContext ctx, double? sell_price
      // required double sellWhenPrice,

      }) async {
    try {
      final response = await _dio.post(
        '$baseUrl'
        'order/sell',
        data: {
          "order_id": orderId,
          // "sell_price": 1902.35
        },

        ///Users/mohamedhassan/StudioProjects/LiftTraineeApp
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      Toast.showMsg(msg: response.data["message"] ?? '');
      AppLoader.closeLoader(ctx, ValueKey("sell_price"));

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("sell_price error  :::: ");
      if (e.response != null) {
        Toast.showMsg(
            msg: e.response?.data['message'] ?? 'Server error occurred');
        AppLoader.closeLoader(ctx, ValueKey("sell_price"));
        return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        AppLoader.closeLoader(ctx, ValueKey("sell_price"));

        return ApiResponse(
          success: false,
          message: 'Network error occurred',
        );
      }
    } catch (e) {
      AppLoader.closeLoader(ctx, ValueKey("sell_price"));
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // request-delivery

  Future<ApiResponse> requestDelivery({
    required TradeOrOrder trade,
    required int orderId,
    required String deliveryAddress,
    required String deliveryCity,
    required String deliveryPhone,
    required BuildContext ctx,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl' 'order/request-delivery',
        data: {
          "order_id": orderId,
          "delivery_method": "shipping",
          "delivery_address": deliveryAddress,
          "delivery_city": deliveryCity,
          "delivery_phone": deliveryPhone,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      Toast.showMsg(msg: response.data["message"] ?? '');
      AppLoader.closeLoader(ctx, ValueKey("requestDelivery"));

      // الاستخدام البسيط
      showDialog(
        context: ctx,
        // delivery_fee
        builder: (context) => DeliveryFeesDialog(
          trade: trade,
          deliveryFees:
              "${response.data["result"]["delivery_fee"]} USD", // أو أي قيمة
        ),
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("requestDelivery error  :::: ");
      if (e.response != null) {
        Toast.showMsg(
            msg: e.response?.data['message'] ?? 'Server error occurred');
        AppLoader.closeLoader(ctx, ValueKey("requestDelivery"));
        return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        AppLoader.closeLoader(ctx, ValueKey("requestDelivery"));

        return ApiResponse(
          success: false,
          message: 'Network error occurred',
        );
      }
    } catch (e) {
      AppLoader.closeLoader(ctx, ValueKey("requestDelivery"));
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  Future<ApiResponse> getSinglePage(int id) async {
    try {
      final response = await _dio.get('$baseUrl' 'single-pages/$id');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error occurred',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }
}
