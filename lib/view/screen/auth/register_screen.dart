import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import 'package:official_gold/view_model/utils/colors.dart';
import 'package:official_gold/view_model/utils/navigation.dart';
import '../../../view_model/cubit/auth_cubit/auth_cubit.dart';
import '../../../view_model/utils/toast.dart';
import '../../../view_model/utils/validator.dart';
import '../home/layout_screen.dart';
import 'creat_country_phone.dart';
import 'forget_password_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: AuthCubit.get(context),
      child: Scaffold(
        appBar: AppBar(),
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
                  LocaleKeys.registerNow.tr(),
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
                        key: AuthCubit.get(context).registerFormKey,
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
                              controller: AuthCubit.get(context).username,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.username.tr(),
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return LocaleKeys.usernameError.tr();
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                            TextFormField(
                              controller: AuthCubit.get(context).email,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.email.tr(),
                              ),
                              validator: (v) => Validator.validateEmail(
                                value: v,
                              ),
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                            // TextFormField(
                            //   controller: AuthCubit.get(context).mobile,
                            //   textInputAction: TextInputAction.next,
                            //   keyboardType: TextInputType.phone,
                            //   decoration: InputDecoration(
                            //     hintText: LocaleKeys.phone.tr(),
                            //   ),
                            //   validator: (value) {
                            //     if ((value ?? '').trim().isEmpty) {
                            //       return LocaleKeys.phoneError.tr();
                            //     }
                            //     return null;
                            //   },
                            // ),

                            CreatCountryCodeField(
                              label: "phone",
                              title: "enter_phone",
                              countryName:
                                  AuthCubit.get(context).countryName ?? "EG",
                              phoneController: AuthCubit.get(context).mobile,
                              onCountryChanged: (country) {
                                AuthCubit.get(context).countryCode =
                                    '+${country.dialCode}';
                                AuthCubit.get(context).countryName =
                                    country.code;
                                print(
                                  'countryCode : ${AuthCubit.get(context).countryCode}',
                                );
                                print(
                                  'countryName : ${AuthCubit.get(context).countryName}',
                                );
                              },
                            ),

                            SizedBox(
                              height: 12.h,
                            ),
                            TextFormField(
                              controller: AuthCubit.get(context).password,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.password.tr(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return LocaleKeys.passwordError.tr();
                                }
                                return null;
                              },
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: AuthCubit.get(context)
                                  .confirmPasswordController,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.confirmPassword.tr(),
                              ),
                              obscureText: true,
                              validator: (v) =>
                                  Validator.validateConfirmPassword(
                                      value: v,
                                      originalPassword:
                                          AuthCubit.get(context).password.text),
                            ),

                            SizedBox(
                              height: 40.h,
                            ),
                            SizedBox(
                              width: 200.w,
                              height: 40.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();

                                  if (AuthCubit.get(context)
                                      .registerFormKey
                                      .currentState!
                                      .validate()) {
                                    if (AuthCubit.get(context)
                                        .mobile
                                        .text
                                        .trim()
                                        .isEmpty) {
                                      Toast.showError(
                                          msg: LocaleKeys.phoneError.tr());
                                    } else {
                                      AuthCubit.get(context)
                                          .register()
                                          .then((value) {
                                        Navigation.pushAndRemoveUntil(
                                          context,
                                          const LayoutScreen(),
                                        );
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  LocaleKeys.register.tr(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
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
                                Navigator.pop(context);
                              },
                              child: Text(
                                LocaleKeys.login.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontSize: 18.sp,
                                        color: AppColors.yellow),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigation.push(
                                    context, const ForgetPasswordScreen());
                              },
                              child: Text(
                                LocaleKeys.forgetYourPassword.tr(),
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
      ),
    );
  }
}
