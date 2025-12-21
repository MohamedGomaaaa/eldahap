import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/home/profile/tawk_chat/tawk_chat_screen.dart';
import 'package:official_gold/view/screen/home/profile/wallet/wallet_screen.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import 'package:official_gold/view_model/utils/navigation.dart';

import '../../../../l10n/locale_keys.g.dart';
import '../../../../model/user.dart';
import '../../../../view_model/cubit/home_cubit/home_cubit.dart';
import '../../../../view_model/utils/colors.dart';
import '../../static_pages/static_page_screen.dart';
import 'components/profile_tile_widget.dart';
import 'faq/faq_screen.dart';
import 'my_account/my_account_screen.dart';
import 'reports/reports_screen.dart';
import 'send_ticket/tickets_screen.dart';
import 'settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 12.w,vertical: 12.h),
          children: [
            ValueListenableBuilder<User>(
              valueListenable: HomeCubit.get(context).user,
              builder: (context, user, _) {
                return InkWell(
                  onTap: () {
                    Navigation.push(context, const ProfileScreen());
                  },
                  child: Container(
                    width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textYellow,
                        shape: BoxShape.circle,
                        // borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:8.0,left:8,right: 8),
                        child: Text(
                          user.mode ?? '',
                          textAlign: TextAlign.center,
                          style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.background,
                            fontSize: 14.sp,
                          ),
                        ),
                      )),
                );
              },
            ),
            Text(
              LocaleKeys.profile.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textYellow,
                  ),
            ),
            SizedBox(
              height: 6.h,
            ),
            const Divider(
              color: AppColors.textYellow,
            ),
            SizedBox(
              height: 6.h,
            ),

            ValueListenableBuilder<User>(
              valueListenable: HomeCubit.get(context).user,
              builder: (context, user, _) {
                return    ProfileTileWidget(
                  title: "${LocaleKeys.mode.tr()} : (${user.mode}) ",
                  assetName: AppAssets.myAccount,
                  onTap: () {
                    HomeCubit.get(context).changeMode();
                  },
                  action: Text(
                    //  LocaleKeys.demo_usd.tr(),
                    "",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.green,
                    ),
                  ),
                );
              },
            ),


            ValueListenableBuilder<User>(
              valueListenable: HomeCubit.get(context).user,
              builder: (context, user, _) {
                return      ProfileTileWidget(
                  title: LocaleKeys.myAccount.tr(),
                  assetName: AppAssets.settings,
                  onTap: () {
                    print("User mode: ${user.mode.toString().toLowerCase()}");
                    Navigation.push(context,  MyAccountsPage(accountType: user.mode.toString().toLowerCase()));
                  },
                );
              },
            ),

            ProfileTileWidget(
              title: LocaleKeys.settings.tr(),
              assetName: AppAssets.settings,
              onTap: () {
                Navigation.push(context, const SettingsScreen());
              },
            ),

            // ProfileTileWidget(
            //   title: LocaleKeys.payUsdt.tr(),
            //   assetName: AppAssets.payUsdt2,
            //   onTap: () {
            //     LayoutCubit.get(context).changeCurrentIndex(4);
            //   },
            // ),
            ProfileTileWidget(
              title: LocaleKeys.wallet.tr(),
              assetName: AppAssets.wallet,
              onTap: () {
                Navigation.push(
                  context,
                  const WalletScreen(),
                );
              },
            ),

            // ProfileTileWidget(
            //   title: LocaleKeys.deposit.tr(),
            //   assetName: AppAssets.deposit,
            //   onTap: () {
            //     Navigation.push(context, const DepositScreen(),);
            //   },
            // ),
            // ProfileTileWidget(
            //   title: LocaleKeys.withdraw.tr(),
            //   assetName: AppAssets.withdraw,
            //   onTap: () {
            //     Navigation.push(context, const WithdrawScreen(),);
            //   },
            // ),
            ProfileTileWidget(
              title: LocaleKeys.reports.tr(),
              assetName: AppAssets.reports,
              onTap: () {
                Navigation.push(
                  context,
                  const ReportsScreen(),
                );
              },
            ),
            ProfileTileWidget(
              title: LocaleKeys.sendTicket.tr(),
              assetName: AppAssets.sendTicket,
              onTap: () {
                Navigation.push(context, const TicketsScreen());
              },
            ),

            ProfileTileWidget(
              title: LocaleKeys.faq.tr(),
              assetName: AppAssets.faq,
              onTap: () {
                Navigation.push(context, const FAQScreen());
              },
            ),
            ProfileTileWidget(
              title: LocaleKeys.privacyPolicy.tr(),//LocaleKeys.settings.tr()
              iconWidget: const Icon(Icons.privacy_tip,color: AppColors.textYellow,),
              onTap: () {
                Navigation.push(context,  const StaticPageScreen(pageId: 6,));
              },
            ),
            ProfileTileWidget(
              title: LocaleKeys.termsAndConditions.tr(),//LocaleKeys.settings.tr()
              iconWidget: const Icon(Icons.policy,color: AppColors.textYellow,),
              onTap: () {
                Navigation.push(context,  const StaticPageScreen(pageId: 5,));
              },
            ),
            ProfileTileWidget(
              title: LocaleKeys.aboutUs.tr(),//LocaleKeys.settings.tr()
              iconWidget: const Icon(Icons.info_outline, color: AppColors.textYellow,),
              onTap: () {
                Navigation.push(context,  const StaticPageScreen(pageId: 7,));
              },
            ),

            ProfileTileWidget(
              title: LocaleKeys.liveChat.tr(),
              assetName: AppAssets.liveChat,
              onTap: () {
                Navigation.push(
                  context,
                  const TawkChatPage(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
