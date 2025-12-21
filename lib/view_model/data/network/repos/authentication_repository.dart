import 'package:dio/dio.dart';
import 'package:official_gold/model/user.dart';
import 'package:official_gold/view_model/data/network/data_providers/auth_provider.dart';

class AuthRepository {
  late final AuthProvider authProvider;

  AuthRepository() {
    authProvider = AuthProvider();
  }

  Future<(User, String)> login(String email, String password) async {
    try {
      final loginResponse = await authProvider.login(email, password);
      return (
        User.fromJson(loginResponse?.data),
        loginResponse?.data?['token'].toString() ?? ''
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<(User, String)> register(
      String username, String email, String mobile, String password) async {
    try {
      _printRegisterParams(
        username: username,
        email: email,
        mobile: mobile,
        password: password,
      );
      final loginResponse = await authProvider.register(
          username: username, mobile: mobile, email: email, password: password);
      return (
        User.fromJson(loginResponse?.data),
        loginResponse?.data?['token'].toString() ?? ''
      );
    } catch (e) {
      rethrow;
    }
  }

  void _printRegisterParams({
    required String username,
    required String email,
    required String mobile,
    required String password,
  }) {
    print('========== REGISTER PARAMS ==========');
    print('username: $username');
    print('email   : $email');
    print('mobile  : $mobile');
    print('password: ${'*' * password.length}'); // يخفي الباسورد
    print('====================================');
  }

  Future<Response?> forgetPassword(String email) async {
    try {
      final forgetResponse = await authProvider.forgotPassword(email: email);
      return forgetResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> verifyResetOtp(String email, String code) async {
    try {
      final verifyResetOtpResponse =
          await authProvider.verifyResetOtp(email: email, code: code);
      return verifyResetOtpResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> resetPassword(String email, String code, String newPassword,
      String confirmPassword) async {
    try {
      final resetPasswordResponse = await authProvider.resetPassword(
          email: email,
          code: code,
          newPassword: newPassword,
          confirmPassword: confirmPassword);
      return resetPasswordResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logout() async {
    try {
      return await authProvider.logout();
    } catch (e) {
      rethrow;
    }
  }
}
