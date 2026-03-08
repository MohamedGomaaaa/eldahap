import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/screen/auth/register_screen.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import 'package:official_gold/view_model/utils/colors.dart';
import 'package:official_gold/view_model/utils/navigation.dart';

import '../../../view_model/cubit/auth_cubit/auth_cubit.dart';
import '../home/layout_screen.dart';
import 'forget_password_screen.dart';










import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: AuthCubit.get(context),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final cubit = AuthCubit.get(context);
          final isLoading = state is LoginLoadingState;

          return Stack(
            children: [
              Scaffold(
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
                                key: cubit.formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20.h),
                                    SvgPicture.asset(AppAssets.logo),
                                    SizedBox(height: 40.h),

                                    TextFormField(
                                      controller: cubit.email,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: LocaleKeys.email.tr(),
                                      ),
                                      validator: (value) {
                                        if ((value ?? '').trim().isEmpty) {
                                          return LocaleKeys.emailError.tr();
                                        }
                                        return null;
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

                                    Align(
                                      alignment: AlignmentDirectional.centerStart,
                                      child: TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                          Navigation.push(context, const ForgetPasswordScreen());
                                        },
                                        child: Text(LocaleKeys.forgetYourPassword.tr()),
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
                                          final ok = cubit.formKey.currentState?.validate() ?? false;
                                          if (!ok) return;

                                          await cubit.login();

                                          Navigation.pushAndRemoveUntil(
                                            context,
                                            const LayoutScreen(),
                                          );
                                        },
                                        child: Text(
                                          LocaleKeys.login.tr(),
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontSize: 16.sp,
                                            color: AppColors.background,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 12.h),

                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                        Navigation.push(context, const RegisterScreen());
                                      },
                                      child: Text(
                                        LocaleKeys.registerNow.tr(),
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontSize: 18.sp,
                                          color: AppColors.yellow,
                                        ),
                                      ),
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


// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: AuthCubit.get(context),
//       child: BlocBuilder<AuthCubit, AuthState>(
//         builder: (context, state) {
//           final cubit = AuthCubit.get(context);
//           final isLoading = state is LoginLoadingState;
//
//           return Stack(
//             children: [
//               Scaffold(
//                 body: SafeArea(
//                   bottom: false,
//                   child: Padding(
//                     padding: EdgeInsetsDirectional.only(
//                       start: 12.w,
//                       end: 12.w,
//                       top: 12.h,
//                       bottom: 0,
//                     ),
//                     child: Column(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             padding: EdgeInsets.all(12.sp),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadiusDirectional.only(
//                                 topStart: Radius.circular(20.r),
//                                 topEnd: Radius.circular(20.r),
//                               ),
//                               border: Border.all(
//                                 color: AppColors.yellowBorder,
//                                 width: 1.w,
//                               ),
//                             ),
//                             child: SingleChildScrollView(
//                               child: Form(
//                                 key: cubit.formKey,
//                                 child: Column(
//                                   children: [
//                                     SizedBox(height: 20.h),
//                                     SvgPicture.asset(AppAssets.logo),
//                                     SizedBox(height: 40.h),
//
//                                     TextFormField(
//                                       controller: cubit.email,
//                                       textInputAction: TextInputAction.next,
//                                       keyboardType: TextInputType.emailAddress,
//                                       decoration: InputDecoration(
//                                         hintText: LocaleKeys.email.tr(),
//                                       ),
//                                       validator: (value) {
//                                         if ((value ?? '').trim().isEmpty) {
//                                           return LocaleKeys.emailError.tr();
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                     SizedBox(height: 12.h),
//
//                                     TextFormField(
//                                       controller: cubit.password,
//                                       decoration: InputDecoration(
//                                         hintText: LocaleKeys.password.tr(),
//                                       ),
//                                       obscureText: true,
//                                       validator: (value) {
//                                         if ((value ?? '').trim().isEmpty) {
//                                           return LocaleKeys.passwordError.tr();
//                                         }
//                                         return null;
//                                       },
//                                     ),
//
//                                     Align(
//                                       alignment: AlignmentDirectional.centerStart,
//                                       child: TextButton(
//                                         onPressed: isLoading
//                                             ? null
//                                             : () {
//                                           Navigation.push(context, const ForgetPasswordScreen());
//                                         },
//                                         child: Text(LocaleKeys.forgetYourPassword.tr()),
//                                       ),
//                                     ),
//
//                                     SizedBox(height: 40.h),
//
//                                     SizedBox(
//                                       width: 200.w,
//                                       height: 40.h,
//                                       child: ElevatedButton(
//                                         onPressed: isLoading
//                                             ? null
//                                             : () async {
//                                           final ok = cubit.formKey.currentState?.validate() ?? false;
//                                           if (!ok) return;
//
//                                           await cubit.login();
//
//                                           Navigation.pushAndRemoveUntil(
//                                             context,
//                                             const LayoutScreen(),
//                                           );
//                                         },
//                                         child: Text(
//                                           LocaleKeys.login.tr(),
//                                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                             fontSize: 16.sp,
//                                             color: AppColors.background,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//
//                                     SizedBox(height: 12.h),
//
//                                     TextButton(
//                                       onPressed: isLoading
//                                           ? null
//                                           : () {
//                                         Navigation.push(context, const RegisterScreen());
//                                       },
//                                       child: Text(
//                                         LocaleKeys.registerNow.tr(),
//                                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                           fontSize: 18.sp,
//                                           color: AppColors.yellow,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               // ===== Full Screen Loading Overlay =====
//               if (isLoading) const _FullScreenAuthLoading(),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

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





















// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: AuthCubit.get(context),
//       child:
//
//
//
//       Scaffold(
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
//                 // Padding(
//                 //   padding: EdgeInsetsDirectional.only(
//                 //     start: 20.w,
//                 //     end: 20.w,
//                 //   ),
//                 //   child: SizedBox(
//                 //     width: double.infinity,
//                 //     height: 60.h,
//                 //     child: Stack(
//                 //       clipBehavior: Clip.none,
//                 //       children: [
//                 //         PositionedDirectional(
//                 //           start: 0,
//                 //           bottom: 0,
//                 //           child: Material(
//                 //             color: AppColors.yellow2,
//                 //             borderRadius: BorderRadiusDirectional.only(
//                 //               topStart: Radius.circular(30.r),
//                 //               topEnd: Radius.circular(30.r),
//                 //             ),
//                 //             clipBehavior: Clip.antiAliasWithSaveLayer,
//                 //             child: InkWell(
//                 //               onTap: () {},
//                 //               borderRadius: BorderRadius.only(
//                 //                 topLeft: Radius.circular(30.r),
//                 //                 topRight: Radius.circular(30.r),
//                 //               ),
//                 //               child: Container(
//                 //                 width: MediaQuery.of(context).size.width / 2.3,
//                 //                 padding: EdgeInsets.all(12.sp),
//                 //                 decoration: BoxDecoration(
//                 //                   borderRadius: BorderRadiusDirectional.only(
//                 //                     topStart: Radius.circular(30.r),
//                 //                     topEnd: Radius.circular(30.r),
//                 //                   ),
//                 //                   border: Border.all(
//                 //                     color: AppColors.yellowBorder,
//                 //                     width: 1.w,
//                 //                   ),
//                 //                 ),
//                 //                 child: Text(
//                 //                   LocaleKeys.live.tr(),
//                 //                   style: Theme.of(context)
//                 //                       .textTheme
//                 //                       .titleLarge
//                 //                       ?.copyWith(
//                 //                         fontSize: 16.sp,
//                 //                         color: AppColors.background,
//                 //                       ),
//                 //                   textAlign: TextAlign.center,
//                 //                 ),
//                 //               ),
//                 //             ),
//                 //           ),
//                 //         ),
//                 //         PositionedDirectional(
//                 //           end: 0,
//                 //           bottom: 0,
//                 //           child: Material(
//                 //             color: AppColors.background,
//                 //             borderRadius: BorderRadiusDirectional.only(
//                 //               topStart: Radius.circular(30.r),
//                 //               topEnd: Radius.circular(30.r),
//                 //             ),
//                 //             clipBehavior: Clip.antiAliasWithSaveLayer,
//                 //             child: InkWell(
//                 //               onTap: () {},
//                 //               borderRadius: BorderRadius.only(
//                 //                 topLeft: Radius.circular(30.r),
//                 //                 topRight: Radius.circular(30.r),
//                 //               ),
//                 //               child: Container(
//                 //                 width: MediaQuery.of(context).size.width / 2.2,
//                 //                 padding: EdgeInsets.all(12.sp),
//                 //                 decoration: BoxDecoration(
//                 //                   borderRadius: BorderRadiusDirectional.only(
//                 //                     topStart: Radius.circular(30.r),
//                 //                     topEnd: Radius.circular(30.r),
//                 //                   ),
//                 //                   border: Border.all(
//                 //                     color: AppColors.yellowBorder,
//                 //                     width: 1.w,
//                 //                   ),
//                 //                 ),
//                 //                 child: Text(
//                 //                   LocaleKeys.demo.tr(),
//                 //                   style: Theme.of(context)
//                 //                       .textTheme
//                 //                       .titleLarge
//                 //                       ?.copyWith(
//                 //                         fontSize: 16.sp,
//                 //                         color: AppColors.yellow,
//                 //                       ),
//                 //                   textAlign: TextAlign.center,
//                 //                 ),
//                 //               ),
//                 //             ),
//                 //           ),
//                 //         ),
//                 //       ],
//                 //     ),
//                 //   ),
//                 // ),
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
//                         key: AuthCubit.get(context).formKey,
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
//                               controller: AuthCubit.get(context).email,
//                               textInputAction: TextInputAction.next,
//                               keyboardType: TextInputType.emailAddress,
//                               decoration: InputDecoration(
//                                 hintText: LocaleKeys.email.tr(),
//                               ),
//                               validator: (value) {
//                                 if ((value ?? '').trim().isEmpty) {
//                                   return LocaleKeys.emailError.tr();
//                                 }
//                                 return null;
//                               },
//                             ),
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
//                             Align(
//                               alignment: AlignmentDirectional.centerStart,
//                               child: TextButton(
//                                 onPressed: () {
//                                   Navigation.push(
//                                       context, const ForgetPasswordScreen());
//                                 },
//                                 child: Text(
//                                   LocaleKeys.forgetYourPassword.tr(),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 40.h,
//                             ),
//                             SizedBox(
//                               width: 200.w,
//                               height: 40.h,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   if (AuthCubit.get(context).formKey.currentState?.validate() ??
//                                       false) {
//                                     AuthCubit.get(context).login().then((value) {
//                                       Navigation.pushAndRemoveUntil(
//                                         context,
//                                         const LayoutScreen(),
//                                       );
//                                     });
//                                   }
//                                 },
//                                 child: Text(
//                                   LocaleKeys.login.tr(),
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
//                                 Navigation.push(
//                                     context, const RegisterScreen());
//                               },
//                               child: Text(
//                                 LocaleKeys.registerNow.tr(),
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleLarge
//                                     ?.copyWith(
//                                         fontSize: 18.sp,
//                                         color: AppColors.yellow),
//                               ),
//                             ),
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
