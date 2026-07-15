import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view/components/svg_widget.dart';
import 'package:official_gold/view/components/app_bar_widget.dart';
import 'package:official_gold/view_model/utils/assets.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientWidget(
        child: Column(
          children: [
            const AppBarCustom(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(12.sp),
                children: [
                  SizedBox(
                    height: 12.h,
                  ),
                  Text(
                    LocaleKeys.paymentDetails.tr(),
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
                    height: 8.h,
                  ),
                  Text(
                    LocaleKeys.wallet.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Material(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.yellowBorder,
                            width: 0.5.w,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                LocaleKeys.uploadOfIDCardFront.tr(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                              ),
                            ),
                            const SvgWidget(
                              assetName: AppAssets.myAccount,
                              color: AppColors.textYellow,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Text(
                    LocaleKeys.pleaseUploadAHighQualityImage.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Material(
                    color: AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.yellowBorder,
                            width: 0.5.w,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                LocaleKeys.uploadOfIDCardBack.tr(),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                              ),
                            ),
                            const SvgWidget(
                              assetName: AppAssets.cardID,
                              color: AppColors.textYellow,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Text(
                    LocaleKeys.dataAndPhotosWillBeReviewedAsSoonAsPossible.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    '.. ${LocaleKeys.thankYou.tr()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.sp),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.save.tr(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
