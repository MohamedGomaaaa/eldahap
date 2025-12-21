import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/home/app_bar/app_bar_widget.dart';
import 'package:official_gold/view/screen/home/profile/components/profile_tile_widget.dart';
import 'package:official_gold/view_model/cubit/home_cubit/home_cubit.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../../../../components/gradient_widget.dart';
import 'activate_the_account_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: HomeCubit.get(context)..getProfile()..clearControllers(),
      child: Scaffold(
        body: GradientWidget(
          child: Column(
            children: [
              const AppBarCustom(),
              Expanded(
                child: Form(
                  key: HomeCubit.get(context).formKey,
                  child: ListView(
                    padding: EdgeInsets.all(12.sp),
                    children: [
                      SizedBox(
                        height: 12.h,
                      ),
                      Text(
                        LocaleKeys.settings.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(),
                      ),
                      SizedBox(
                        height: 6.h,
                      ),
                      const Divider(
                        color: AppColors.textYellow,
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      TextFormField(
                        controller: HomeCubit.get(context).nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundGrey,
                          hintText: LocaleKeys.name.tr(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.nameError.tr();
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      // SizedBox(
                      //   height: 8.h,
                      // ),
                      // TextFormField(
                      //   decoration: InputDecoration(
                      //     filled: true,
                      //     fillColor: AppColors.backgroundGrey,
                      //     hintText: LocaleKeys.lastName.tr(),
                      //   ),
                      //   textInputAction: TextInputAction.next,
                      // ),
                      SizedBox(
                        height: 8.h,
                      ),
                      TextFormField(
                        controller: HomeCubit.get(context).emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundGrey,
                          hintText: LocaleKeys.email.tr(),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.emailError.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      TextFormField(
                        controller: HomeCubit.get(context).phoneController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundGrey,
                          hintText: LocaleKeys.mobile.tr(),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 8) {
                            return LocaleKeys.mobileError.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      TextFormField(
                        controller: HomeCubit.get(context).currentPasswordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundGrey,
                          hintText: LocaleKeys.currentPassword.tr(),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 8) {
                            return LocaleKeys.passwordError.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      TextFormField(
                        controller: HomeCubit.get(context).newPasswordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundGrey,
                          hintText: LocaleKeys.newPassword.tr(),
                        ),
                        textInputAction: TextInputAction.next,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 8) {
                            return LocaleKeys.passwordError.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      TextFormField(
                        controller: HomeCubit.get(context).confirmPasswordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.backgroundGrey,
                          hintText: LocaleKeys.reTypeThePassword.tr(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.passwordError.tr();
                          }else if (value != HomeCubit.get(context).newPasswordController.text) {
                            return LocaleKeys.passwordNotMatch.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      // ProfileTileWidget(
                      //   title: LocaleKeys.paymentDetails.tr(),
                      //   onTap: () {
                      //     Navigation.push(
                      //       context,
                      //       const PaymentDetailsScreen(),
                      //     );
                      //   },
                      // ),
                      ProfileTileWidget(
                        titleColor: AppColors.green,
                        title: LocaleKeys.activateTheAccount.tr(),
                        onTap: () {
                          Navigation.push(
                            context,
                            const ActivateTheAccountScreen(),
                          );
                        },
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: () {
                            if(HomeCubit.get(context).formKey.currentState!.validate()){
                              HomeCubit.get(context).updateProfile().then((value) => Navigator.pop(context));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            LocaleKeys.save.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                ),
                          ),
                        ),
                      ),
                    ],
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
