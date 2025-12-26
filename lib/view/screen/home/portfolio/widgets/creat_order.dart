import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/trade_model.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../../order_details/order_details_screen.dart';

class CreatOrder extends StatelessWidget {
  final Trade order;
  final VoidCallback onCloseTap;
  const CreatOrder({super.key, required this.order, required this.onCloseTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.all( 8.sp),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigation.push(context,  OrderDetailsScreen(orderId: order.id!,));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
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
                                    '+${order.qty}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 6.sp,
                              ),

           //////////////////////////////////////////////////////////////////////////////////////////////////////// price 2
                              Row(
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
                                  Text(
                                    '+14.854',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(),
                                  ),
                                ],
                              ),
                            ],
                          ),

          ////////////////////////////////////////////////////////////////////////////////////////////// price 1
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(
                              '2.5494',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: AppColors.greyText,
                              ),
                            ),
                          ),

                        ],
                      ),


                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10.sp,
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
          const Divider(color: AppColors.yellow2),
        ],
      ),
    );
  }
}
