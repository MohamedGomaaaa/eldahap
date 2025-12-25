import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view/components/app_bar_widget.dart';

import '../../../../../view_model/utils/colors.dart';

class CompletedDepositScreen extends StatelessWidget {
  const CompletedDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
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
                LocaleKeys.completedDeposit.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(),
              ),
              SizedBox(
                height: 6.h,
              ),
              const Divider(
                color: AppColors.textYellow,
              ),
              SizedBox(
                height: 12.h,
              ),
              Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.yellowBorder,
                    width: 0.5.w,
                  ),
                  color: AppColors.backgroundGrey,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_rounded,
                      color: AppColors.textYellow,
                      size: 60.sp,
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Text(
                      LocaleKeys.thanksForAddingTheMoney.tr(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
