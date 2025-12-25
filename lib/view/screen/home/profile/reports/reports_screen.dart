import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view/screen/home/profile/components/profile_tile_widget.dart';
import 'package:official_gold/view_model/utils/navigation.dart';

import '../../../../../view_model/utils/colors.dart';
import '../../../../components/app_bar_widget.dart';
import 'deposit_reports_screen.dart';
import 'earnings_reports_screen.dart';
import 'order_reports_screen.dart';
import 'withdraw_reports_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientWidget(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(12.sp),
            children: [
              const AppBarCustom(),
              SizedBox(
                height: 12.h,
              ),
              Text(
                LocaleKeys.reports.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    // color: AppColors.textYellow,
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
              ProfileTileWidget(
                title: LocaleKeys.orderReports.tr(),
                onTap: (){
                  Navigation.push(context,  OrderReportsScreen(),);
                },
              ),
              ProfileTileWidget(
                title: LocaleKeys.earningsReports.tr(),
                onTap: (){
                  Navigation.push(context, const EarningsReportsScreen(),);
                },
              ),
              ProfileTileWidget(
                title: LocaleKeys.depositReports.tr(),
                onTap: (){
                  Navigation.push(context, const DepositReportsScreen(),);
                },
              ),
              ProfileTileWidget(
                title: LocaleKeys.withdrawReports.tr(),
                onTap: (){
                  Navigation.push(context, const WithDrawReportsScreen(),);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
