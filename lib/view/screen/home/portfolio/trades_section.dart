import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';
import 'package:official_gold/view/screen/home/portfolio/widgets/trade_widget.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart';
import 'package:official_gold/view_model/utils/text_style.dart';
import '../../../../model/trade_order_group.dart';
import '../../../../view_model/utils/colors.dart';
import '../../../components/live_status_text.dart';










class TradesSection extends StatelessWidget {
  const TradesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TradesCubit()
          ..getTradess()
         ..getCommissionRate(),
      child: RefreshIndicator(
        onRefresh: () async => context.read<TradesCubit>().getTradess(),
        backgroundColor: AppColors.yellow2,
        color: AppColors.black,
        child: BlocBuilder<TradesCubit, TradesState>(
          buildWhen: (previous, current) {
            return current is GetTradesLoadingState ||
                current is GetTradesSuccessState ||
                current is GetTradesErrorState ||
                current is CloseTradeLoadingState ||
                current is TradesRefreshingState || // ✅ NEW
                current is TradesExpandedChanged ||
                current is GetCommissionRateLoadingState ||
                current is GetCommissionRateSuccessState ||
                current is GetCommissionRateErrorState; // ✅ مهم
          },
          builder: (context, state) {
            if (state is GetTradesLoadingState ||
                state is CloseTradeLoadingState) {
              return ListView.separated(
                padding:
                    EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp),
                itemBuilder: (context, index) {
                  return ShimmerWidget(
                    child: Container(
                      padding: EdgeInsets.all(12.sp),
                      width: double.infinity,
                      height: 130.h,
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

/////////////////////////////////////////////////////////////////////////////////////// Whole Trade List
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: 12.sp,
                horizontal: 0.sp,
              ),
              itemCount: TradesCubit.get(context).groupOfTradesOrOrders.length,
              itemBuilder: (context, index) {
                // final  GroupOfTradesOrOrders  g = TradesCubit.get(context).groupOfTradesOrOrders[index];
                // final key = g.metal ?? 'unknown_$index';
                final GroupOfTradesOrOrders g =
                    TradesCubit.get(context).groupOfTradesOrOrders[index];
                final key = '${g.metal ?? ''}_${g.currency ?? ''}';

                return TradeWidget(
                  tradeGroup: g,
                  groupKey: key, // ✅ نفس المفتاح اللي الكيوبت بيستخدمه
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


