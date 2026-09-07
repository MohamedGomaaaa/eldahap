import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:official_gold/view/screen/auth/login_screen.dart';
import 'package:official_gold/view/screen/auth/register_screen.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:intl_phone_field/countries.dart';

import 'package:easy_localization/easy_localization.dart';


import '../../../services/translation/locale_keys.g.dart';
import '../../../utils/app_assets.dart';
import '../../../utils/app_color.dart';
import '../../../utils/navigation.dart';
import '../../../utils/text_style.dart';
import '../../../utils/toast.dart';
import '../../../view_model/cubit/auth_cubit/auth_cubit.dart';
import 'code_password_screen.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(     appBar: AppBar(),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 12.w,
            end: 12.w,
            top: 12.h,
            bottom: 0,
          ),
          child: Column(
            children: [
              Text(
                LocaleKeys.forgetYourPassword.tr(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.yellow,
                    ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(20.r),
                      topEnd: Radius.circular(20.r),
                    ),
                    border: Border.all(
                      color: AppColors.yellowBorder,
                      width: 1.w,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: AuthCubit.get(context).formKeyForgetPassword,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20.h,
                          ),
                          SvgPicture.asset(
                            AppAssets.logo,
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          TextFormField(
                            controller: AuthCubit.get(context).emailForgetPassword,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.email.tr(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.pleaseEnterYourEmail.tr();
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return LocaleKeys.pleaseEnterAValidEmail.tr();
                              }
                              return null;
                            }
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              LocaleKeys.aCodeHasBeenSentToYourEmail.tr(),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          SizedBox(
                            width: 200.w,
                            height: 40.h,
                            child: ElevatedButton(
                              onPressed: () {FocusScope.of(context).unfocus();
                                if(!AuthCubit.get(context).formKeyForgetPassword.currentState!.validate()){
                                  return;
                                }else{
                                  AuthCubit.get(context).forgetPassword(context).then((value){

                                    print("object ..... sent ..... ${AuthCubit.get(context).emailForgetPassword.text} .....}");
                                    print("object ${value?.data["success"]}");
                                    if(value?.data["success"] ?? false){
                                      Toast.showMsg(msg: value?.data["message"]);

                                      Navigation.push(context,  CodePasswordScreen(debugOtp:value?.data["debug_otp"].toString()));
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(value?.data["message"] ?? LocaleKeys.pleaseEnterTheCode.tr()),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  });
                                }
                              },
                              child: Text(
                                LocaleKeys.send.tr(),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 16.sp,
                                      color: AppColors.white,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigation.pushAndRemoveUntil(context, const LoginScreen());
                            },
                            child: Text(
                              LocaleKeys.login.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 18.sp, color: AppColors.yellow),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigation.pushAndRemoveUntil(context, const RegisterScreen());
                            },
                            child: Text(
                              LocaleKeys.registerNow.tr(),
                            ),
                          )
                        ],
                      ),
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
