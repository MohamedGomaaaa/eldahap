import 'package:dio/dio.dart';


import '../end_points/end_points.dart';
import '../shared_preference/shared_helper.dart';
import '../shared_preference/shared_keys.dart';


class DioHelper {
  static Dio dio = Dio(
    BaseOptions(
      baseUrl: EndPoints.baseUrl,
      receiveDataWhenStatusError: true,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool? withToken = false,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          headers: {
            if(withToken ?? false)
            'Authorization': 'Bearer ${SharedHelper.get(SharedKeys.token)}',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> post({
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool? withToken = false,
  }) async {
    try {
      return await dio.post(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          headers: {
            if(withToken ?? false)
              'Authorization': 'Bearer ${SharedHelper.get(SharedKeys.token)}',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> put({
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool? withToken = false,
  }) async {
    try {
      return await dio.put(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          headers: {
            if(withToken ?? false)
              'Authorization': 'Bearer ${SharedHelper.get(SharedKeys.token)}',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }


  static Future<Response> patch({
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool? withToken = false,
  }) async {
    try {
      return await dio.patch(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          headers: {
            if(withToken ?? false)
              'Authorization': 'Bearer ${SharedHelper.get(SharedKeys.token)}',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> delete({
    required String path,
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool? withToken = false,
  }) async {
    try {
      return await dio.delete(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          headers: {
            if(withToken ?? false)
              'Authorization': 'Bearer ${SharedHelper.get(SharedKeys.token)}',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
