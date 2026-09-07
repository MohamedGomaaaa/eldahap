

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



import '../../../../../model/payment_data.dart';
import '../../../../../model/payment_methods_model.dart';
import '../../../../../services/translation/locale_keys.g.dart';
import '../../../../../utils/app_color.dart';
import '../../../../../utils/common_method.dart';





class PaymentConfirmationSheet extends StatelessWidget {
  final double amount;
  final PaymentData paymentData;
  final VoidCallback onConfirm;

  const PaymentConfirmationSheet({
    super.key,
    required this.amount,
    required this.paymentData,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.greyText,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            LocaleKeys.payment_confirmation.tr(),
            style: TextStyle(
              color: AppColors.textYellow,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            // LocaleKeys.payment_deduction.tr(args: [amount.toStringAsFixed(2)]),

            LocaleKeys.payment_deduction.tr(
              namedArgs: {
                'amount': Methods.removeTrailingZeros(amount)

              },
            ),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            // LocaleKeys.pay_via.tr(args: ),

            LocaleKeys.pay_via.tr(
              namedArgs: {
                'method': paymentData.name,
              },
            ),
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                LocaleKeys.proceed_payment.tr(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LocaleKeys.cancel.tr(),
              style: const TextStyle(color: AppColors.yellow),
            ),
          ),
        ],
      ),
    );
  }
}