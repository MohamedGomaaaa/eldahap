// 5. Main Page Widget
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view_model/utils/colors.dart';

import '../../../view_model/data/local/shared_helper.dart';
import '../../../view_model/data/local/shared_keys.dart';
import '../../../view_model/data/network/end_points.dart';
import '../../../view_model/utils/toast.dart';
import '../../components/app_loader.dart';
import '../home/portfolio/trade_details_screen.dart';
import 'models/payment_methods_model.dart';

// 1. Model for API Response
class PageModel {
  final int id;
  final String title;
  final String content;
  final int publish;
  final String image;

  PageModel({
    required this.id,
    required this.title,
    required this.content,
    required this.publish,
    required this.image,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      publish: json['publish'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final PageModel? result;

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
          json['result'] != null ? PageModel.fromJson(json['result']) : null,
    );
  }
}

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
  }) async
  {
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

  Future<ApiResponse> makeWithdraw({
    required String amount,
    required String paymentMethodId,
    required String accountName,
    required String accountPhone,
    required String bankName,
    required String bankAccount,
    required String note,
    required String address,
    required String binanceId,
  }) async
  {
    try {
      final response = await _dio.post(
        '$baseUrl'
        'make-withdraw',
        data: {
          'amount': amount,
          'payment_method_id': paymentMethodId,
          'account_name': accountName,
          'account_phone': accountPhone,
          'bank_name': bankName,
          'bank_account': bankAccount,
          'note': note,
          'address': address,
          'binanceId': binanceId,
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
        Toast.showMsg(msg: e.response?.data['message'] ?? 'Server error occurred');
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
}

// 3. Cubit State Classes
abstract class PageState {}

class PageInitial extends PageState {}

class PageLoading extends PageState {}

class PageLoaded extends PageState {
  final PageModel page;
  PageLoaded(this.page);
}

class PageError extends PageState {
  final String message;
  PageError(this.message);
}

// 4. Cubit

class PageCubit extends Cubit<PageState> {
  final ApiService _apiService;

  PageCubit(this._apiService) : super(PageInitial());

  Future<void> loadPage(int id) async {
    emit(PageLoading());

    try {
      final response = await _apiService.getSinglePage(id);

      if (response.success && response.result != null) {
        emit(PageLoaded(response.result!));
      } else {
        emit(PageError(response.message));
      }
    } catch (e) {
      emit(PageError('Failed to load page data'));
    }
  }
}

class StaticPageScreen extends StatelessWidget {
  final int pageId;

  const StaticPageScreen({required this.pageId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PageCubit(ApiService())..loadPage(pageId),
      child: SinglePageView(),
    );
  }
}

class SinglePageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(),
      ),
      body: BlocBuilder<PageCubit, PageState>(
        builder: (context, state) {
          if (state is PageLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
              ),
            );
          }

          if (state is PageError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 60.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PageCubit>()
                          .loadPage(1); // Retry with same ID
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.black,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PageLoaded) {
            return PageContent(page: state.page);
          }

          return Center(
            child: Text(
              'Welcome',
              style: TextStyle(color: AppColors.white),
            ),
          );
        },
      ),
    );
  }
}

class PageContent extends StatelessWidget {
  final PageModel page;

  const PageContent({required this.page, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(12.sp),
      children: [
        // Title Row with Icon
        Row(
          children: [
            Icon(
              Icons.article_outlined,
              color: AppColors.yellow,
              size: 20.h,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                page.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // Image Carousel
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            clipBehavior: Clip.none,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
          ),
          items: [
            Container(
              width: double.infinity,
              height: 150.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.yellowBorder,
                  width: 0.5.sp,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: page.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.grey,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.yellow),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.grey,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.lightGrey,
                            size: 40.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: AppColors.lightGrey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // Content
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.yellowBorder,
              width: 0.5.sp,
            ),
          ),
          child: Text(
            page.content,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.yellow,
                  height: 1.6,
                  fontSize: 16.sp,
                ),
          ),
        ),

        SizedBox(height: 20.h),

        // Status Indicator
        // if (page.publish == 1)
        //   Container(
        //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        //     decoration: BoxDecoration(
        //       color: AppColors.green.withOpacity(0.1),
        //       borderRadius: BorderRadius.circular(20.r),
        //       border: Border.all(color: AppColors.green, width: 1),
        //     ),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(
        //           Icons.check_circle,
        //           color: AppColors.green,
        //           size: 16.sp,
        //         ),
        //         SizedBox(width: 8.w),
        //         Text(
        //           'Published',
        //           style: TextStyle(
        //             color: AppColors.green,
        //             fontSize: 12.sp,
        //             fontWeight: FontWeight.w500,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    );
  }
}
class DeliveryFeesDialog extends StatelessWidget {
  final String deliveryFees;

  const DeliveryFeesDialog({
    Key? key,
    required this.deliveryFees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: AppColors.grey,
          width: 1.w,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.grey,
            width: 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Fees',
                    style: TextStyle(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                      padding: EdgeInsets.all(8.w),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Delivery Icon
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey2,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: AppColors.yellow,
                    width: 2.w,
                  ),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: AppColors.yellow,
                  size: 30.sp,
                ),
              ),

              SizedBox(height: 16.h),

              // Fees Amount
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey2,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.grey,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Fees: ',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      deliveryFees,
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // OK Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}