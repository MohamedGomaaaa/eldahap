import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/trade_model.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../../order_details/order_details_screen.dart';

class CreatOrder extends StatelessWidget {
  final Trade trade;
  final VoidCallback onCloseTap;
  const CreatOrder({super.key, required this.trade, required this.onCloseTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(top: 18.sp, right: 8.sp, left: 8.sp, bottom: 8.sp),
      child: Column(
        children: [
          Row(
            children: [
InkWell(
                  onTap: (){


                  Navigation.push(context,  OrderDetailsPage());

                },
  child: Row(children: [
    //////////////////////////////////////////////////////////////////////////////////////////// price 1
    const Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        '2.5494',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: AppColors.greyText,
        ),
      ),
    ),
    SizedBox(
      width: 6.h,
    ),
    //////////////////////////////////////////////////////////////////////////////////////////// quantity
    Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(8.sp),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.sp,
          vertical: 5.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(
            color: AppColors.blueColor,
            width: 1.sp,
          ),
        ),
        child: Text(
          '+${trade.qty}',
          style: const TextStyle(
            color: AppColors.white,
          ),
        ),
      ),
    ),
    SizedBox(
      width: 6.sp,
    ),
  ],),
),



              //Navigation.push(context,  OrderDetailsPage());
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      '@',
                      style: TextStyle(
                        color: AppColors.greyText,
                      ),
                    ),
                    SizedBox(
                      width: 6.sp,
                    ),
//////////////////////////////////////////////////////////////////////////////////////////// price2
                    Text(
                      '+14.854',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 6.sp,
              ),
/////////////////////////////////////////////////////////////////////////////////////////// close
              InkWell(
                onTap: onCloseTap,
                child: CircleAvatar(
                  backgroundColor: AppColors.greyText,
                  radius: 10.r,
                  child: Icon(
                    Icons.close,
                    size: 16.sp,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
