import 'package:dio/dio.dart';
import 'package:official_gold/view_model/data/network/dio_helper.dart';
import 'package:official_gold/view_model/data/network/end_points.dart';

class AuthProvider {
  AuthProvider();

  Future<Response?> login(String email, String password) async {
    try{
      return await DioHelper.post(
        path: EndPoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> register({
    required String username,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
    return await DioHelper.post(
      path: EndPoints.register,
      data: {
        'name': username,
        'mobile_number': mobile,
        'email': email,
        'password': password,
      },
    );
    } catch (e) {
      rethrow;
    }
  }
  Future<Response?> forgotPassword({
    required String email,
  }) async {
    try {
    return await DioHelper.post(
      path: EndPoints.forgotPassword,
      data: {
        'email': email,
      },
    );
    } catch (e) {
      rethrow;
    }
  }
  // auth/verify-reset-otp
  Future<Response?> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    try {
    return await DioHelper.post(
      path: EndPoints.verifyResetOtp,
      data: {
        'email': email,
        'code': code,
      },
    );
    } catch (e) {
      rethrow;
    }
  }


  Future<Response?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      return await DioHelper.post(
        path: EndPoints.resetPassword,
        data: {
          'email': email,
          'code': code,
          "password": newPassword,
          "password_confirmation": confirmPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logout() async {
    try {
    return await DioHelper.post(
      path: EndPoints.logout,
      withToken: true,
    );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> profile() async {
    try {
    return await DioHelper.get(
      path: EndPoints.profile,
      withToken: true,
    );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> updateProfile({
    required String name,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
    return await DioHelper.post(
      path: EndPoints.updateProfile,
      data: {
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
      },
    );
    } catch (e) {
      rethrow;
    }
  }



}
