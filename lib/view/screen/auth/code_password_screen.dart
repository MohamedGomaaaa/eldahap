import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/screen/auth/login_screen.dart';
import 'package:official_gold/view/screen/auth/register_screen.dart';
import 'package:official_gold/view/screen/auth/reset_password_screen.dart';
import 'package:official_gold/view_model/cubit/auth_cubit/auth_cubit.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import 'package:official_gold/view_model/utils/colors.dart';

import '../../../view_model/utils/navigation.dart';
import '../../../view_model/utils/toast.dart';

class CodePasswordScreen extends StatelessWidget {
  String? debugOtp;
   CodePasswordScreen( {this.debugOtp,super.key});

  @override
  Widget build(BuildContext context) {
    AuthCubit.get(context).codeController.text = debugOtp ?? "";
    return Scaffold(
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
                LocaleKeys.codePassword.tr(),
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
                      key: AuthCubit.get(context).formKeyCode,
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
                            controller: AuthCubit.get(context).codeController,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.code.tr(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.pleaseEnterTheCode.tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              LocaleKeys.pleaseCheckTheEmailInTheSpamFolder.tr(),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          SizedBox(
                            width: 200.w,
                            height: 40.h,
                            child: ElevatedButton(
                              onPressed: () {
                                if(!AuthCubit.get(context).formKeyCode.currentState!.validate()) return;
                                AuthCubit.get(context).verifyResetOtp(context).then((value) {
                                  if (value?.data["success"] ?? false) {
                                    print("Success Verify OTP");
                                    Toast.showMsg(msg: value?.data["message"]);
                                    Navigation.push(context, const ResetPasswordScreen());
                                  }else{
                                    Toast.showMsg(msg: value?.data["message"]);
                                    print("Failed Verify OTP");
                                  }
                                });
                              },
                              child: Text(
                                LocaleKeys.activation.tr(),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 16.sp,
                                      color: AppColors.background,
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
