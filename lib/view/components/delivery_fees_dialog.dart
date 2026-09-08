import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../model/trade_order_model.dart';

import '../../../utils/app_color.dart';
import '../../../utils/common_method.dart';

class DeliveryFeesDialog extends StatelessWidget {
  final String deliveryFees;

  final TradeOrOrder trade;

  const DeliveryFeesDialog({
    Key? key,
    required this.deliveryFees,
    required this.trade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: AppColors.grey,
          width: 1.w,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.grey,
            width: 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  // Text(
                  //   'Delivery Fees',
                  //   style: TextStyle(
                  //     color: AppColors.yellow,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 18.sp,
                  //   ),
                  // ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                      padding: EdgeInsets.all(8.w),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Delivery Icon
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey2,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: AppColors.yellow,
                    width: 2.w,
                  ),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: AppColors.yellow,
                  size: 30.sp,
                ),
              ),

              SizedBox(height: 16.h),

              // Fees Amount
              trade.hasDelivery == true
                  ? creatMoneyDetails(
                      label: 'shipping coast : ',
                      value:
                          Methods.removeTrailingZeros(trade.shippingCost ?? 0),
                    )
                  : SizedBox(),

              // manufacturing Amount
              creatMoneyDetails(
                label: 'manufacturing coast : ',
                value: Methods.removeTrailingZeros(trade.manufacturingFee ?? 0),
              ),

              SizedBox(height: 24.h),

              // OK Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
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

  Widget creatMoneyDetails({
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 12.h,
      ),
      // decoration: BoxDecoration(
      //   // color: Colors.red,
      //   // color: AppColors.backgroundGrey2,
      //   borderRadius: BorderRadius.circular(12.r),
      //   border: Border.all(
      //     color: AppColors.grey,
      //     width: 1.w,
      //   ),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "$value LE",
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
