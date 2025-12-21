import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/model/user.dart';
import 'package:official_gold/view/components/app_loader.dart';
import 'package:official_gold/view_model/data/local/shared_helper.dart';
import 'package:official_gold/view_model/data/local/shared_keys.dart';
import 'package:official_gold/view_model/data/network/repos/authentication_repository.dart';
import 'package:official_gold/view_model/utils/toast.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);

  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController emailForgetPassword = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyForgetPassword = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyCode = GlobalKey<FormState>();
  GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKeyResetPassword = GlobalKey<FormState>();

  String? countryName;
String countryCode="+20";
  User user = User();

  Future<void> login() async {
    emit(LoginLoadingState());
    await AuthRepository().login(email.text, password.text).then((value) {
      user = value.$1;
      SharedHelper.save(SharedKeys.token, value.$2);

      print(
          ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${SharedHelper.get(SharedKeys.token)}");

      emit(LoginSuccessState(user));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        Toast.showError(
            msg: error.response?.data?['message'].toString() ??
                'Error on Login');
        emit(LoginErrorState(msg: error.response?.data?['message'].toString()));
      }
      throw error;
    });
  }

  Future<void> register() async {
    emit(RegisterLoadingState());
    await AuthRepository()
        .register(username.text, email.text, "$countryCode${mobile.text}",
            password.text)
        .then((value) {
      user = value.$1;
      SharedHelper.save(SharedKeys.token, value.$2);
      emit(RegisterSuccessState(user));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        Toast.showError(
            msg: error.response?.data?['errors']
                    .toString()
                    .replaceAll('{', '')
                    .replaceAll('}', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '') ??
                'Error on Login');
      }
      throw error;
    });
  }

  Future<Response?> forgetPassword(BuildContext context) async {
    AppLoader.showLoader(context, const ValueKey("forgetPassword"));
    print("object..... ${emailForgetPassword.text} .....");
    var res;
    await AuthRepository()
        .forgetPassword(emailForgetPassword.text)
        .then((value) {
      res = value;
      print("object>>>>>>>>>>>> value : ${value} ,  data = ${value?.data}");
      AppLoader.closeLoader(context, const ValueKey("forgetPassword"));
      return value;
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        Toast.showError(
            msg: error.response?.data?['errors']
                    .toString()
                    .replaceAll('{', '')
                    .replaceAll('}', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '') ??
                'Error on Login');
        AppLoader.closeLoader(context, const ValueKey("forgetPassword"));
      }
      throw error;
    });
    return res;
  }

  Future<Response?> verifyResetOtp(BuildContext context) async {
    AppLoader.showLoader(context, const ValueKey("verifyResetOtp"));
    print("emailForgetPassword..... ${emailForgetPassword.text} .....");
    print("codeController..... ${codeController.text} .....");
    var res;
    await AuthRepository()
        .verifyResetOtp(emailForgetPassword.text, codeController.text)
        .then((value) {
      res = value;
      print("object>>>>>>>>>>>> value : ${value} ,  data = ${value?.data}");
      AppLoader.closeLoader(context, const ValueKey("verifyResetOtp"));
      return value;
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        Toast.showError(
            msg: error.response?.data?['errors']
                    .toString()
                    .replaceAll('{', '')
                    .replaceAll('}', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '') ??
                'Error on Login');
        AppLoader.closeLoader(context, const ValueKey("verifyResetOtp"));
      }
      throw error;
    });
    return res;
  }

  Future<Response?> resetPassword(BuildContext context) async {
    AppLoader.showLoader(context, const ValueKey("resetPassword"));
    print("emailForgetPassword..... ${emailForgetPassword.text} .....");
    print("codeController..... ${codeController.text} .....");
    var res;
    await AuthRepository()
        .resetPassword(emailForgetPassword.text, codeController.text,
            newPasswordController.text, confirmPasswordController.text)
        .then((value) {
      res = value;
      print("object>>>>>>>>>>>> value : ${value} ,  data = ${value?.data}");
      AppLoader.closeLoader(context, const ValueKey("resetPassword"));
      return value;
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        Toast.showError(
            msg: error.response?.data?['errors']
                    .toString()
                    .replaceAll('{', '')
                    .replaceAll('}', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '') ??
                'Error on Login');
        AppLoader.closeLoader(context, const ValueKey("resetPassword"));
      }
      throw error;
    });
    return res;
  }

  Future<void> logout() async {
    emit(LogoutLoadingState());
    await AuthRepository().logout().then((value) {
      debugPrint(value.data?.toString());
      SharedHelper.clear();
      emit(LogoutSuccessState());
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        Toast.showError(
            msg: error.response?.data?['message'].toString() ??
                'Error on Logout');
      }
      emit(LogoutErrorState());
      throw error;
    });
  }
}
