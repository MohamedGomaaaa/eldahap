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
import '../create_nav_bar/layout_screen.dart';
import 'creat_country_phone.dart';
import 'forget_password_screen.dart';




import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

// import your files...
// import 'auth_cubit.dart';
// import 'auth_state.dart';
// import 'app_assets.dart';
// import 'app_colors.dart';
// import 'locale_keys.g.dart';
// import 'navigation.dart';
// import 'layout_screen.dart';
// import 'forget_password_screen.dart';
// import 'validator.dart';
// import 'toast.dart';
// import 'creat_country_code_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: AuthCubit.get(context),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final cubit = AuthCubit.get(context);
          final isLoading = state is RegisterLoadingState;

          return Stack(
            children: [
              Scaffold(
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
                        SizedBox(height: 20.h),
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
                                key: cubit.registerFormKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20.h),
                                    SvgPicture.asset(AppAssets.logo),
                                    SizedBox(height: 40.h),

                                    TextFormField(
                                      controller: cubit.username,
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
                                    SizedBox(height: 12.h),

                                    TextFormField(
                                      controller: cubit.email,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: LocaleKeys.email.tr(),
                                      ),
                                      validator: (v) => Validator.validateEmail(value: v),
                                    ),
                                    SizedBox(height: 12.h),

                                    CreatCountryCodeField(
                                      label: "phone",
                                      title: "enter_phone",
                                      countryName: cubit.countryName ?? "EG",
                                      phoneController: cubit.mobile,
                                      onCountryChanged: (country) {
                                        FocusScope.of(context).unfocus();
                                        cubit.countryCode = '+${country.dialCode}';
                                        cubit.countryName = country.code;
                                      },
                                    ),

                                    SizedBox(height: 12.h),

                                    TextFormField(
                                      controller: cubit.password,
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

                                    SizedBox(height: 10),

                                    TextFormField(
                                      controller: cubit.confirmPasswordController,
                                      decoration: InputDecoration(
                                        hintText: LocaleKeys.confirmPassword.tr(),
                                      ),
                                      obscureText: true,
                                      validator: (v) => Validator.validateConfirmPassword(
                                        value: v,
                                        originalPassword: cubit.password.text,
                                      ),
                                    ),

                                    SizedBox(height: 40.h),

                                    SizedBox(
                                      width: 200.w,
                                      height: 40.h,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () async {
                                          FocusScope.of(context).unfocus();

                                          final ok = cubit.registerFormKey.currentState?.validate() ?? false;
                                          if (!ok) return;

                                          if (cubit.mobile.text.trim().isEmpty) {
                                            Toast.showError(msg: LocaleKeys.phoneError.tr());
                                            return;
                                          }

                                          await cubit.register();

                                          // لو عندك State success اعمل التنقل في BlocListener
                                          // هنا زي ما عندك:
                                          Navigation.pushAndRemoveUntil(
                                            context,
                                            const LayoutScreen(),
                                          );
                                        },
                                        child: Text(
                                          LocaleKeys.register.tr(),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontSize: 16.sp,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 12.h),

                                    TextButton(
                                      onPressed: isLoading ? null : () => Navigator.pop(context),
                                      child: Text(
                                        LocaleKeys.login.tr(),
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontSize: 18.sp,
                                          color: AppColors.yellow,
                                        ),
                                      ),
                                    ),

                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                        Navigation.push(context, const ForgetPasswordScreen());
                                      },
                                      child: Text(LocaleKeys.forgetYourPassword.tr()),
                                    ),
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

              // ===== Full Screen Loading Overlay =====
              if (isLoading) const _FullScreenAuthLoading(),
            ],
          );
        },
      ),
    );
  }
}



/// Overlay لودنج على الشاشة كلها + يمنع الضغط
class _FullScreenAuthLoading extends StatelessWidget {
  const _FullScreenAuthLoading();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.35),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.yellowBorder, width: 1.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  LocaleKeys.loading.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.yellow,
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






















// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: AuthCubit.get(context),
//       child: Scaffold(
//         appBar: AppBar(),
//         body: SafeArea(
//           bottom: false,
//           child: Padding(
//             padding: EdgeInsetsDirectional.only(
//               start: 12.w,
//               end: 12.w,
//               top: 12.h,
//               bottom: 0,
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   LocaleKeys.registerNow.tr(),
//                   style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                         color: AppColors.yellow,
//                       ),
//                 ),
//                 SizedBox(
//                   height: 20.h,
//                 ),
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.all(12.sp),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadiusDirectional.only(
//                         topStart: Radius.circular(20.r),
//                         topEnd: Radius.circular(20.r),
//                       ),
//                       border: Border.all(
//                         color: AppColors.yellowBorder,
//                         width: 1.w,
//                       ),
//                     ),
//                     child: SingleChildScrollView(
//                       child: Form(
//                         key: AuthCubit.get(context).registerFormKey,
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: 20.h,
//                             ),
//                             SvgPicture.asset(
//                               AppAssets.logo,
//                             ),
//                             SizedBox(
//                               height: 40.h,
//                             ),
//                             TextFormField(
//                               controller: AuthCubit.get(context).username,
//                               textInputAction: TextInputAction.next,
//                               decoration: InputDecoration(
//                                 hintText: LocaleKeys.username.tr(),
//                               ),
//                               validator: (value) {
//                                 if ((value ?? '').trim().isEmpty) {
//                                   return LocaleKeys.usernameError.tr();
//                                 }
//                                 return null;
//                               },
//                             ),
//                             SizedBox(
//                               height: 12.h,
//                             ),
//                             TextFormField(
//                               controller: AuthCubit.get(context).email,
//                               textInputAction: TextInputAction.next,
//                               keyboardType: TextInputType.emailAddress,
//                               decoration: InputDecoration(
//                                 hintText: LocaleKeys.email.tr(),
//                               ),
//                               validator: (v) => Validator.validateEmail(
//                                 value: v,
//                               ),
//                             ),
//                             SizedBox(
//                               height: 12.h,
//                             ),
//                             // TextFormField(
//                             //   controller: AuthCubit.get(context).mobile,
//                             //   textInputAction: TextInputAction.next,
//                             //   keyboardType: TextInputType.phone,
//                             //   decoration: InputDecoration(
//                             //     hintText: LocaleKeys.phone.tr(),
//                             //   ),
//                             //   validator: (value) {
//                             //     if ((value ?? '').trim().isEmpty) {
//                             //       return LocaleKeys.phoneError.tr();
//                             //     }
//                             //     return null;
//                             //   },
//                             // ),
//
//
//
//                             CreatCountryCodeField(
//                               label: "phone",
//                               title: "enter_phone",
//                               countryName:
//                                   AuthCubit.get(context).countryName ?? "EG",
//                               phoneController: AuthCubit.get(context).mobile,
//                               onCountryChanged: (country) {
//                                 AuthCubit.get(context).countryCode =
//                                     '+${country.dialCode}';
//                                 AuthCubit.get(context).countryName =
//                                     country.code;
//                                 print(
//                                   'countryCode : ${AuthCubit.get(context).countryCode}',
//                                 );
//                                 print(
//                                   'countryName : ${AuthCubit.get(context).countryName}',
//                                 );
//                               },
//                             ),
//
//                             SizedBox(
//                               height: 12.h,
//                             ),
//                             TextFormField(
//                               controller: AuthCubit.get(context).password,
//                               decoration: InputDecoration(
//                                 hintText: LocaleKeys.password.tr(),
//                               ),
//                               obscureText: true,
//                               validator: (value) {
//                                 if ((value ?? '').trim().isEmpty) {
//                                   return LocaleKeys.passwordError.tr();
//                                 }
//                                 return null;
//                               },
//                             ),
//
//                             SizedBox(
//                               height: 10,
//                             ),
//                             TextFormField(
//                               controller: AuthCubit.get(context)
//                                   .confirmPasswordController,
//                               decoration: InputDecoration(
//                                 hintText: LocaleKeys.confirmPassword.tr(),
//                               ),
//                               obscureText: true,
//                               validator: (v) =>
//                                   Validator.validateConfirmPassword(
//                                       value: v,
//                                       originalPassword:
//                                           AuthCubit.get(context).password.text),
//                             ),
//
//                             SizedBox(
//                               height: 40.h,
//                             ),
//                             SizedBox(
//                               width: 200.w,
//                               height: 40.h,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   FocusScope.of(context).unfocus();
//
//                                   if (AuthCubit.get(context)
//                                       .registerFormKey
//                                       .currentState!
//                                       .validate()) {
//                                     if (AuthCubit.get(context)
//                                         .mobile
//                                         .text
//                                         .trim()
//                                         .isEmpty) {
//                                       Toast.showError(
//                                           msg: LocaleKeys.phoneError.tr());
//                                     } else {
//                                       AuthCubit.get(context)
//                                           .register()
//                                           .then((value) {
//                                         Navigation.pushAndRemoveUntil(
//                                           context,
//                                           const LayoutScreen(),
//                                         );
//                                       });
//                                     }
//                                   }
//                                 },
//                                 child: Text(
//                                   LocaleKeys.register.tr(),
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleLarge
//                                       ?.copyWith(
//                                         fontSize: 16.sp,
//                                         color: AppColors.background,
//                                       ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 12.h,
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Text(
//                                 LocaleKeys.login.tr(),
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleLarge
//                                     ?.copyWith(
//                                         fontSize: 18.sp,
//                                         color: AppColors.yellow),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 Navigation.push(
//                                     context, const ForgetPasswordScreen());
//                               },
//                               child: Text(
//                                 LocaleKeys.forgetYourPassword.tr(),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
