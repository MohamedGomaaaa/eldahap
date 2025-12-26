import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/trade_model.dart';

import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../trade_details_screen.dart';

/// ✅ 1) Common widget للجزء اللي كان متكرر (الـ details اللي تحت)
/// - اخدناه زي ما هو من الكود المتعلقّ
/// - وخليناه يقبل بيانات ثابتة مؤقتًا (P&L / prices)
/// - وكمان يقبل onCloseTap عشان يفتح bottom sheet
class CreatTrade extends StatelessWidget {
  final Trade trade;
  final VoidCallback onCloseTap;
  final String ?displayQty;
  const CreatTrade({
    super.key,
    required this.trade,
    required this.onCloseTap, required this.displayQty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(top: 4.sp, right: 8.sp, left: 8.sp, bottom: 8.sp),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: InkWell(
              onTap: () {
                Navigation.push(context, TradeDetailsScreen(trade));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: AppColors.blueColor,
                    borderRadius: BorderRadius.circular(8.sp),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.sp,
                        vertical: 5.h,
                      ),
                      child: Text(
                        // '+${trade.qty ?? "0"}',
                          '+${displayQty ?? (trade.qty ?? "0")}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 6.sp,
                  ),
//////////////////////////////////////////////////////////////////////////////////////////////// Low And High Price
                  creatLowAndHighPrice(),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 6.sp,
          ),
//////////////////////////////////////////////////////////////////////////////////////////////// second column

          InkWell(
            onTap: onCloseTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('P&L'),
                    SizedBox(width: 6.sp),
                    Text(
                      '+14.854',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.blueColor,
                          ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 6.sp,
                ),
                ////////////////////////////////////////////////////////////////////////////////////////////////  cancel button
                CircleAvatar(
                  backgroundColor: AppColors.greyText,
                  radius: 10.r,
                  child: Icon(
                    Icons.close,
                    size: 16.sp,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),

////////////////////////////////////////////////////////////////////////////////////////////////  space

          // SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget creatLowAndHighPrice() {
    return Row(
      children: [
        Text(
          '2.5494',
          style: const TextStyle(color: AppColors.greyText),
        ),
        SizedBox(width: 6.sp),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.yellow2,
          size: 12.sp,
        ),
        SizedBox(width: 6.sp),
        Text(
          '2.5494',
          style: const TextStyle(color: AppColors.greyText),
        ),
      ],
    );
  }
}
