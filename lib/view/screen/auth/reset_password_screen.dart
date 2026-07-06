import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/screen/auth/login_screen.dart';
import 'package:official_gold/view/screen/auth/register_screen.dart';
import 'package:official_gold/view_model/cubit/auth_cubit/auth_cubit.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import 'package:official_gold/view_model/utils/colors.dart';

import '../../../view_model/utils/navigation.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {

    AuthCubit.get(context).newPasswordController.dispose();
    AuthCubit.get(context).confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                LocaleKeys.resetPassword.tr(), // You may need to add this key to your locale
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
                      key: AuthCubit.get(context).formKeyResetPassword,
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
                          // New Password Field
                          TextFormField(
                            controller: AuthCubit.get(context).newPasswordController,
                            obscureText: obscureNewPassword,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.newPassword.tr(), // Add this to your locale
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureNewPassword = !obscureNewPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureNewPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.yellow,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.pleaseEnterNewPassword.tr(); // Add this to your locale
                              }
                              if (value.length < 6) {
                                return LocaleKeys.passwordMustBeAtLeast6Characters.tr(); // Add this to your locale
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          // Confirm Password Field
                          TextFormField(
                            controller: AuthCubit.get(context).confirmPasswordController,
                            obscureText: obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.confirmPassword.tr(), // Add this to your locale
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword = !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.yellow,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.pleaseConfirmPassword.tr(); // Add this to your locale
                              }
                              if (value != AuthCubit.get(context).newPasswordController.text) {
                                return LocaleKeys.passwordsDoNotMatch.tr(); // Add this to your locale
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
                              LocaleKeys.pleaseEnterStrongPassword.tr(), // Add this to your locale
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.yellow.withOpacity(0.7),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          // Reset Password Button
                          SizedBox(
                            width: 200.w,
                            height: 40.h,
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (!AuthCubit.get(context).formKeyResetPassword.currentState!.validate()) return;

                                // Call your reset password API method
                                AuthCubit.get(context).resetPassword(
                                  context,
                                ).then((value) {
                                  if (value?.data["success"] ?? false) {
                                    print("Success Reset Password");
                                    // Show success message and navigate to login
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleKeys.passwordResetSuccessfully.tr()), // Add this to your locale
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigation.pushAndRemoveUntil(context, const LoginScreen());
                                  } else {
                                    print("Failed Reset Password");
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleKeys.passwordResetFailed.tr()), // Add this to your locale
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                });
                              },
                              child: Text(
                                LocaleKeys.resetPassword.tr(),
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
                          // Login Button
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
                          // Register Button
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