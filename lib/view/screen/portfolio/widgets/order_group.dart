import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../model/trade_order_group.dart';

import '../../../../../view_model/cubit/trades_cubit/trades_cubit.dart';

import '../../../../utils/app_assets.dart';
import '../../../../utils/app_color.dart';
import '../../../components/svg_widget.dart';
import 'creat_order.dart';


class OrderGroup extends StatelessWidget {
  final GroupOfTradesOrOrders tradeGroup;
  final String groupKey;

  const OrderGroup({
    super.key,
    required this.tradeGroup,
    required this.groupKey,
  });

  @override
  Widget build(BuildContext context) {
    final tradesCubit = context.read<TradesCubit>();

    return BlocBuilder<TradesCubit, TradesState>(
      builder: (context, state) {


        final group = tradesCubit.wholeOrders.firstWhere(
              (g) => '${g.metal ?? ''}_${g.currency ?? ''}' == groupKey,
          orElse: () => GroupOfTradesOrOrders(tradesOrOrders: []),
        );
        final orderList = group.tradesOrOrders ?? [];





        return Material(
          color: AppColors.backgroundGrey2,
          borderRadius: BorderRadius.circular(12.sp),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(
                color: AppColors.yellow2,
                width: 1.sp,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================= Header =================
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.sp,
                    right: 8.sp,
                    top: 8.sp,
                    bottom: 4.sp,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(50.sp),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4,
                              ),
                              child: SvgWidget(
                                assetName: AppAssets.gold3,
                                width: 20.sp,
                              ),
                            ),
                            SizedBox(width: 6.sp),

                            // whole order type
                            Text(
                              "${tradeGroup.title}  ", // سيب المسافه
                              style: const TextStyle(color: AppColors.white),
                            ),
                            SizedBox(width: 6.w),

                            // ✅ شيلنا زرار الفتح/القفل
                          ],
                        ),
                      ),
                      const SizedBox(),
                    ],
                  ),
                ),

                // ✅ Divider ثابت
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  child: SizedBox(
                    height: 1,
                    child: Divider(
                      thickness: 1,
                      height: 1,
                      indent: 0,
                      endIndent: 0,
                      color: AppColors.yellow2,
                    ),
                  ),
                ),

                // ✅ اعرض الليست على طول زي ما هي

                Column(
                  children: List.generate(orderList.length, (index) {
                    final isLast = index == orderList.length - 1;
                    return CreatOrder(
                      productTitle: "${tradeGroup.title}",
                      lastIndex: isLast,
                      order: orderList[index],
                      tradesCubit: tradesCubit,
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


















































