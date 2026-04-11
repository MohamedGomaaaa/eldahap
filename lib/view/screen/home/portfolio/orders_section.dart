import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';
import 'package:official_gold/view/screen/home/portfolio/widgets/order_widget.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart';

import '../../../../view_model/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';
import 'package:official_gold/view/screen/home/portfolio/widgets/order_widget.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart';

import '../../../../view_model/utils/colors.dart';

class OrdersSection extends StatelessWidget {
  const OrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TradesCubit()..getOrderss(),
      child: RefreshIndicator(
        onRefresh: () async => context.read<TradesCubit>().getOrderss(),
        backgroundColor: AppColors.yellow2,
        color: AppColors.black,
        child: BlocBuilder<TradesCubit, TradesState>(
          buildWhen: (previous, current) {
            return current is GetOrdersLoadingState ||
                current is GetOrdersSuccessState ||
                current is GetOrdersErrorState ||


           current is CloseOrderLoadingState||
                current is OrdersRefreshingState; // ✅ NEW

          },
          builder: (context, state) {
            if (state is GetOrdersLoadingState || state is OrdersRefreshingState|| state is CloseOrderLoadingState) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 0.sp),
                itemBuilder: (context, index) {
                  return ShimmerWidget(
                    child: Container(
                      padding: EdgeInsets.all(12.sp),
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                        color: AppColors.yellow2,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemCount: 6,
              );
            }

            final cubit = TradesCubit.get(context);

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 0.sp),
              itemCount: cubit.wholeOrders.length,
              itemBuilder: (context, index) {
                final g = cubit.wholeOrders[index];
                final key = '${g.metal ?? ''}_${g.currency ?? ''}';
                return OrderWidget(
                  groupKey: key, tradeGroup: g,
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 12.sp),
            );
          },
        ),
      ),
    );
  }
}

