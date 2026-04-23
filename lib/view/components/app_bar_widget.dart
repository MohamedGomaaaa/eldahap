import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/user.dart';
import '../../view_model/cubit/home_cubit/home_cubit.dart';
import '../../view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../view_model/utils/assets.dart';
import '../../view_model/utils/colors.dart';
import '../../view_model/utils/common_method.dart';
import '../../view_model/utils/navigation.dart';
import '../screen/home/profile/profile_screen/profile_screen.dart';
import 'svg_widget.dart';





import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/user.dart';
import '../../view_model/cubit/home_cubit/home_cubit.dart';
import '../../view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../view_model/utils/assets.dart';
import '../../view_model/utils/colors.dart';
import '../../view_model/utils/navigation.dart';
import 'svg_widget.dart';









///////////////////////////////////////////////////////  edit by eng gomaa
class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final bool showBalance;
  // final List<Widget>? actions;

  // ✅ تحكم في ارتفاع الاب بار من برا لو تحب
  final double height;

  const AppBarCustom({
    this.showBalance = false,
    // this.actions,
    this.height = 80, // default height (logical px before .h)
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.transparent,

      // ✅ ده اللي بيزود ارتفاع الـ AppBar فعليًا
      toolbarHeight: height.h,

      titleSpacing: 16.w, // optional
      title: InkWell(


        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor:  Colors.transparent,
        focusColor:  Colors.transparent,


        onTap: () => Navigation.push(context, const ProfileScreen()),
        child: Padding(
          // ✅ مساحة عشان الشكل مايبقاش لازق فوق/تحت
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.textYellow,
                    radius: 20.r,
                    child: CircleAvatar(
                      backgroundColor: AppColors.background,
                      radius: 18.r,
                      child: const SvgWidget(assetName: AppAssets.face),
                    ),
                  ),
                  Positioned(
                    top: 27.h,
                    child: Container(

                      padding: EdgeInsets.symmetric(horizontal: 6.w,),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: ValueListenableBuilder<User>(
                        valueListenable: HomeCubit.get(context).user,
                        builder: (context, user, _) {
                          return Text(

                             user.mode ?? '',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              if (showBalance) ...[
                SizedBox(width: 12.w),
                BlocBuilder<WalletCubit, WalletState>(
                  buildWhen: (previous, current) =>
                  current is GetWalletSuccessState ||
                      current is GetWalletLoadingState ||
                      current is GetWalletErrorState,
                  builder: (context, state) {
                    return
                      Text(

                        "${ Methods.removeTrailingZeros( WalletCubit.get(context).walletDollar)} \$",
                        style: Theme.of(context).textTheme.headlineSmall,
                      );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      // actions: actions,
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, height.h);
}
/////////////////////////////////////////////////////////////////////////////////////////// old code












// class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
//   final bool showBalance;
//
//   final List<Widget>? actions;
//
//   const AppBarCustom({this.showBalance = false, this.actions, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       centerTitle: false,
//       backgroundColor: AppColors.transparent,
//       surfaceTintColor: AppColors.transparent,
//       title: InkWell(
//         onTap: () {
//           Navigation.push(context, const ProfileScreen());
//         },
//         child: Container(
//           child: Row(
//             children: [
//            Stack(
//
//              alignment: Alignment.bottomCenter,
//              children: [
//                InkWell(
//                  onTap: () {
//                    Navigation.push(context, const ProfileScreen());
//                  },
//                  child: CircleAvatar(
//                    backgroundColor: AppColors.textYellow,
//                    radius: 22.r,
//                    child: CircleAvatar(
//                      backgroundColor: AppColors.background,
//                      radius: 20.r,
//                      child: const SvgWidget(
//                        assetName: AppAssets.face,
//                      ),
//                    ),
//                  ),
//                ),
//
//
//
//                Positioned(
//                  child: Container(
//
//                    width: 50,height: 16.h,
//
//                    decoration: BoxDecoration(
//                      color: AppColors.blueColor,
//                      borderRadius: BorderRadius.circular(4.r),
//                    ),
//                    child: ValueListenableBuilder<User>(
//                      valueListenable: HomeCubit.get(context).user,
//                      builder: (context, user, _) {
//                        return InkWell(
//                            onTap: () {
//                              Navigation.push(context, const ProfileScreen());
//                            },
//                            child:
//                            Center(
//                              child: Text(
//
//                                user.mode ?? '',
//                                textAlign: TextAlign.center,
//
//                                style:
//                                Theme.of(context).textTheme.bodyLarge?.copyWith(
//
//                                  color: AppColors.white,
//                                  fontWeight: FontWeight.w500,
//                                  fontSize: 13.sp,
//                                ),
//                              ),
//                            )
//                        );
//                      },
//                    ),
//                  ),
//                )
//
//              ],
//            ),
//               if (showBalance) ...[
//                 SizedBox(
//                   width: 12.w,
//                 ),
//                 BlocBuilder<WalletCubit, WalletState>(
//                   buildWhen: (previous, current) {
//                     return current is GetWalletSuccessState ||
//                         current is GetWalletLoadingState ||
//                         current is GetWalletErrorState;
//                   },
//                   builder: (context, state) {
//                     return Text(
//                       '\$${WalletCubit.get(context).wallet}',
//                       style: Theme.of(context).textTheme.headlineSmall,
//                     );
//                   },
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//       actions: actions,
//     );
//   }
//
//   @override
//   // TODO: implement preferredSize
//   Size get preferredSize => Size(double.infinity, 70.h);
// }
