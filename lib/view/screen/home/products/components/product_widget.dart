import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:official_gold/model/product.dart';
import 'package:official_gold/view_model/utils/navigation.dart';

import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../model/category.dart';
import '../../../../../view_model/utils/assets.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../product_chart/product_chart_screen.dart';
import 'product_details_screen.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  final Category category;
  final int tabIndex;
  const ProductWidget({required this.product, required this.category,required this.tabIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundGrey,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.yellowBorder,
            width: 1.w,
          ),
        ),
        child: Column(
          children: [
   ////////////////////////////////////////////////////////////////////////////////////////////// title and image
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppAssets.gold,
                ),
                SizedBox(
                  width: 12.w,
                ),
                Text(

                   product.currency ?? '',
                  // '1 ${LocaleKeys.gram.tr()}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textYellow,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 12.h,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${product.lowestPrice}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textYellow,
                        ),
                      ),
                      SizedBox(
                        height: 6.h,
                      ),
      ////////////////////////////////////////////////////////////////////////////////////////////// buy button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){
                            Navigation.push(context, ProductDetailsScreen(
                              product: product,
                              category: category,
                            ));

                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.transparent,
                            disabledBackgroundColor: AppColors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(
                                color: AppColors.yellowBorder,
                                width: 1.w,
                              ),
                            ),
                          ),
                          child: Text(

                             LocaleKeys.low.tr(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textYellow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 6.w,
                ),
      /////////////////////////////////////////////////////////////////////////////////// chart
                Expanded(child:

                  Column(
                  children: [
                  Text(
                  '${product.lowestPrice}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textYellow,
                  ),
                ),
                SizedBox(
                  height: 6.h,
                ),
                    GestureDetector(

                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>      TradingViewPage(type:
                              product.metal?.toLowerCase()=='gold'?1:product.metal?.toLowerCase()=='silver'?2:3
                              ), // 1 = Gold, 2 = Silver, 3 = Bitcoin
                            ),
                          );
                        },
                        child: Image.asset(AppAssets.tradingChart,))
              ],
            ),










                )










                ,
                SizedBox(
                  width: 6.w,
                ),
      /////////////////////////////////////////////////////////////////////////////////// buy  high
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${product.highestPrice}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textYellow,
                        ),
                      ),
                      SizedBox(
                        height: 6.h,
                      ),
           ///////////////////////////////////////////////////////////////////////////////// buy buton
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (){                  Navigation.push(context, ProductDetailsScreen(
                            product: product,
                            category: category,
                          ));},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.transparent,
                            elevation: 0,
                            disabledBackgroundColor: AppColors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(
                                color: AppColors.yellowBorder,
                                width: 1.w,
                              ),
                            ),
                          ),
                          child: Text(
                            LocaleKeys.high.tr(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textYellow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
