import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/components/svg_widget.dart';
import 'package:official_gold/view/screen/auth/login_screen.dart';
import 'package:official_gold/view_model/cubit/auth_cubit/auth_cubit.dart';
import 'package:official_gold/view_model/cubit/layout_cubit/layout_cubit.dart';
import 'package:official_gold/view_model/data/local/shared_helper.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import 'package:official_gold/view_model/utils/colors.dart';
import 'package:official_gold/view_model/utils/navigation.dart';

import '../../components/gradient_widget.dart';
import '../../components/app_bar_widget.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        var cubit = LayoutCubit.get(context);
        return Scaffold(
          appBar:
          cubit.index==3?
              null:
          AppBarCustom(
            showBalance: true,
 //            actions: [
 //              Stack(
 //                alignment: Alignment.center,
 //                children: [
 //                  BlocBuilder<AuthCubit, AuthState>(
 //                    buildWhen: (previous, current) {
 //                      return current is LogoutLoadingState ||
 //                          current is LogoutSuccessState ||
 //                          current is LogoutErrorState;
 //                    },
 //                    builder: (context, state) {
 //                      return Visibility(
 //                        visible: state is LogoutLoadingState,
 //                        child: const CircularProgressIndicator(
 //                          color: AppColors.yellow2,
 //                        ),
 //                      );
 //                    },
 //                  ),
 // ///////////////////////////////////////////////////////////////////////////////////////////////// log out
 //                  IconButton(
 //                    onPressed: () {
 //                      SharedHelper.clear();
 //                      // AuthCubit.get(context).logout().then((value) {
 //                      //   Navigation.pushAndRemoveUntil(
 //                      //     context,
 //                      //     const LoginScreen(),
 //                      //   );
 //                      // });
 //                      Navigation.pushAndRemoveUntil(context, const LoginScreen());
 //                    },
 //                    icon: Icon(
 //                      Icons.logout_rounded,
 //                      color: AppColors.yellow2,
 //                      size: 20.sp,
 //                    ),
 //                    tooltip: LocaleKeys.logout.tr(),
 //                  ),
 //                ],
 //              ),
 //            ],
          ),
          body:


          Column(
            children: [
              SizedBox(height:    cubit.index==3? 38:0),
              Expanded(
                child: GradientWidget(
                  child: cubit.screens[cubit.index],
                ),
              ),
              Container(
                height: 1.h,
                color: AppColors.textYellow,
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: BottomNavigationBar(
              currentIndex: cubit.index,
              backgroundColor: AppColors.background,
              unselectedItemColor: AppColors.yellow2,
              onTap: (index) {
                cubit.changeCurrentIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: SvgWidget(
                    assetName: AppAssets.home,
                    height: 25.h,
                    color: AppColors.grey,
                  ),
                  label: LocaleKeys.home.tr(),
                  backgroundColor: AppColors.background,
                  activeIcon: SvgWidget(
                    assetName: AppAssets.home,
                    height: 26.h,
                    color: AppColors.yellow2,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: SvgWidget(
                    assetName: AppAssets.products,
                    height: 25.h,
                    color: AppColors.grey,
                  ),
                  label: LocaleKeys.products.tr(),
                  backgroundColor: AppColors.background,
                  activeIcon: SvgWidget(
                    assetName: AppAssets.products,
                    height: 26.h,
                    color: AppColors.yellow2,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: SvgWidget(
                    assetName: AppAssets.portfolio,
                    height: 25.h,
                    color: AppColors.grey,
                  ),
                  label: LocaleKeys.portfolio.tr(),
                  backgroundColor: AppColors.background,
                  activeIcon: SvgWidget(
                    assetName: AppAssets.portfolio,
                    height: 26.h,
                    color: AppColors.yellow2,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: SvgWidget(
                    assetName: AppAssets.chart,
                    height: 24.h,
                    color: AppColors.grey,
                  ),
                  label:  LocaleKeys.chart.tr(),
                  backgroundColor: AppColors.background,
                  activeIcon: SvgWidget(
                    assetName: AppAssets.chart,
                    height: 25.h,
                    color: AppColors.yellow2,
                  ),
                ),
                BottomNavigationBarItem(
                  icon: SvgWidget(
                    assetName: AppAssets.liveChat,
                    height: 25.h,
                    color: AppColors.grey,
                  ),
                  label: LocaleKeys.liveChat.tr(),
                  backgroundColor: AppColors.background,
                  activeIcon: SvgWidget(
                    assetName: AppAssets.liveChat,
                    height: 26.h,
                    color: AppColors.yellow2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
