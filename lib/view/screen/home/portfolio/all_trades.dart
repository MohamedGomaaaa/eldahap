import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';
import 'package:official_gold/view/screen/home/portfolio/widgets/trade_group.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../model/trade_order_group.dart';
import '../../../../model/metal_price_model.dart';
import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/utils/colors.dart';
import '../../../../view_model/cubit/live_price_cubit/live_states.dart'; // 👈 استدعاء مهم لحالات السعر الحي


class AllTrades extends StatelessWidget {
  const AllTrades({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TradesCubit()..getTradess(),
      child: RefreshIndicator(
        onRefresh: () async => context.read<TradesCubit>().getTradess(),
        backgroundColor: AppColors.yellow2,
        color: AppColors.white,
        child: BlocBuilder<TradesCubit, TradesState>(
          buildWhen: (previous, current) {
            return current is GetTradesLoadingState ||
                current is GetTradesSuccessState ||
                current is GetTradesErrorState ||
                current is CloseTradeLoadingState ||
                current is TradesRefreshingState ||
                current is TradesExpandedChanged;
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
// /////////////////////////////////////////////////////////////////////////////////////// Whole Trade List
            // الـ BlocBuilder الخاص بالسعر الحي الذي يُغذي القائمة بالكامل
            return BlocBuilder<LivePriceCubit, LivePriceState>(
              builder: (context, liveState) {
                final tradesCubit = TradesCubit.get(context);

                final livePrices = liveState is LivePriceLive
                    ? liveState.metals
                    : const <String, Map<String, MetalPrices>>{};

                // 2. أمر تحديث الحسابات والكاش في الكيوبيت
                tradesCubit.calculateTotalAndSinglePnl(
                  livePrices: livePrices,
                );

                // 3. رسم الواجهة بناءً على البيانات المحسوبة
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.sp,
                    horizontal: 0.sp,
                  ),
                  itemCount: tradesCubit.groupOfTradesOrOrders.length,
                  itemBuilder: (context, index) {
                    final GroupOfTradesOrOrders g =
                        tradesCubit.groupOfTradesOrOrders[index];
                    final key = '${g.metal ?? ''}_${g.currency ?? ''}';
                    // 👈 قراءة الربح/الخسارة الجاهز الخاص بهذا الجروب
                    final num calculatedPnl =
                        tradesCubit.totalPnlOfEachGroupMap[key] ?? 0.0;
                    return TradeGroup(
                      tradeGroup: g,
                      groupKey: key,
                      totalPnlOfEachGroup:
                          calculatedPnl, // 👈 تمريره للويدجت الفرعي
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 12.sp),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
// class TradesSection extends StatelessWidget {
//
//   const TradesSection({super.key,});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => TradesCubit()
//           ..getTradess()
//          ..getCommissionRate(),
//       child: RefreshIndicator(
//         onRefresh: () async => context.read<TradesCubit>().getTradess(),
//         backgroundColor: AppColors.yellow2,
//         color: AppColors.white,
//         child: BlocBuilder<TradesCubit, TradesState>(
//           buildWhen: (previous, current) {
//             return current is GetTradesLoadingState ||
//                 current is GetTradesSuccessState ||
//                 current is GetTradesErrorState ||
//                 current is CloseTradeLoadingState ||
//                 current is TradesRefreshingState || // ✅ NEW
//                 current is TradesExpandedChanged ||
//                 current is GetCommissionRateLoadingState ||
//                 current is GetCommissionRateSuccessState ||
//                 current is GetCommissionRateErrorState; // ✅ مهم
//           },
//           builder: (context, state) {
//             if (state is GetTradesLoadingState ||
//                 state is CloseTradeLoadingState) {
//               return ListView.separated(
//                 padding:
//                     EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp),
//                 itemBuilder: (context, index) {
//                   return ShimmerWidget(
//                     child: Container(
//                       padding: EdgeInsets.all(12.sp),
//                       width: double.infinity,
//                       height: 130.h,
//                       decoration: BoxDecoration(
//                         color: AppColors.yellow2,
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (_, __) => SizedBox(height: 12.h),
//                 itemCount: 6,
//               );
//             }
//
// /////////////////////////////////////////////////////////////////////////////////////// Whole Trade List
//             return ListView.separated(
//               padding: EdgeInsets.symmetric(
//                 vertical: 12.sp,
//                 horizontal: 0.sp,
//               ),
//               itemCount: TradesCubit.get(context).groupOfTradesOrOrders.length,
//               itemBuilder: (context, index) {
//                 final GroupOfTradesOrOrders g =  TradesCubit.get(context).groupOfTradesOrOrders[index];
//                 final key = '${g.metal ?? ''}_${g.currency ?? ''}';
//
//                 return
//                   // Text("kjskjsd");
//                   TradeWidget(
//                   tradeGroup: g,
//                   groupKey: key, // ✅ نفس المفتاح اللي الكيوبت بيستخدمه
//                 );
//               },
//               separatorBuilder: (_, __) => SizedBox(height: 12.sp),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
