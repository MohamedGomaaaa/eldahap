import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/shimmer_widget.dart';
import 'package:official_gold/view/screen/home/portfolio/widgets/trade_widget.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../view_model/utils/colors.dart';
class TradesSection extends StatelessWidget {
  const TradesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TradesCubit()..getTradess(),
      child: RefreshIndicator(
        onRefresh: () async => context.read<TradesCubit>().getTradess(),
        backgroundColor: AppColors.yellow2,
        color: AppColors.black,
        child: BlocBuilder<TradesCubit, TradesState>(
          buildWhen: (previous, current) {
            return current is GetTradesLoadingState ||
                current is GetTradesSuccessState ||
                current is GetTradesErrorState ||
                current is TradesRefreshingState || // ✅ NEW
                current is TradesExpandedChanged; // ✅ مهم
          },
          builder: (context, state) {
            if (state is GetTradesLoadingState) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp),
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
                final g = TradesCubit.get(context).groupOfTradesOrOrders[index];
                final key = g.metal ?? 'unknown_$index';
                return
                  TradeWidget(
                  tradeGroup:g,
                  // wholeTradeName: g.title ?? '',
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

// class TradesSection extends StatelessWidget {
//   const TradesSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => TradesCubit()..getTradess(),
//       child: RefreshIndicator(
//         onRefresh: () async {
//           await context.read<TradesCubit>().getTradess();
//         },
//         backgroundColor: AppColors.yellow2,
//         color: AppColors.black,
//         child: BlocBuilder<TradesCubit, TradesState>(
//           buildWhen: (previous, current) {
//             return current is GetTradesLoadingState ||
//                 current is GetTradesSuccessState ||
//                 current is GetTradesErrorState ||
//                 current is TradesExpandedChanged;
//           },
//           builder: (context, state) {
//             final cubit = context.read<TradesCubit>();
//
//             if (state is GetTradesLoadingState) {
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// shimmer
//               return ListView.separated(
//                 padding: EdgeInsets.symmetric(
//                   vertical: 12.sp,
//                   horizontal: 12.sp,
//                 ),
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
//                 separatorBuilder: (context, index) => SizedBox(height: 12.h),
//                 itemCount: 6,
//               );
//             }
// ////////////////////////////////////////////////////////////////// wholeTrade list
//             return ListView.separated(
//               padding: EdgeInsets.symmetric(
//                 vertical: 12.sp,
//                 horizontal: 12.sp,
//               ),
//               itemCount: cubit.wholeTrade.length,
//               itemBuilder: (context, index) {
//                 return TradeWidget(
//                   wholeTradeName: cubit.wholeTrade[index].title!,
//                   tradeList:
//                       cubit.wholeTrade[index].orders!, groupKey: '', // ✅ لازم تبعت المنتج
//                 );
//               },
//               separatorBuilder: (context, index) => SizedBox(height: 12.sp),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

/////////////////////////////////////////////////////////////////////////////////////////////////////// old code

// class TradesSection extends StatelessWidget {
//   const TradesSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: TradesCubit.get(context)..getTrades(),
//       child: RefreshIndicator(
//         onRefresh: () async {
//           await TradesCubit.get(context).getTrades();
//         },
//         backgroundColor: AppColors.yellow2,
//         color: AppColors.black,
//         child: BlocBuilder<TradesCubit, TradesState>(
//           buildWhen: (previous, current) {
//             return current is GetTradesLoadingState ||
//                 current is GetTradesSuccessState ||
//                 current is GetTradesErrorState;
//           },
//           builder: (context, state) {
//             if (state is GetTradesLoadingState) {
// /////////////////////////////////////////////////////////////////////////////// shimmer
//               return ListView.separated(
//                 padding: EdgeInsets.symmetric(
//                   vertical: 12.sp,
//                   horizontal: 12.sp,
//                 ),
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
//                 separatorBuilder: (context, index) => SizedBox(
//                   height: 12.h,
//                 ),
//                 itemCount: 6,
//               );
//             }
// /////////////////////////////////////////////////////////////////////////////// list
//             return ListView.separated(
//               padding: EdgeInsets.symmetric(
//                 vertical: 12.sp,
//                 horizontal: 0.sp,
//               ),
//               itemCount: TradesCubit.get(context).trades.length,
//               itemBuilder: (context, index) {
//                 return TradeWidget(
//                   tradesCubit:  TradesCubit.get(context),
//                   product: TradesCubit.get(context).trades[index],
//                   // onTap: (){
//                   //   Navigation.push(context,TradeDetailsScreen(TradesCubit.get(context).trades[index]));
//                   // },
//                 );
//               },
//               separatorBuilder: (context, index) {
//                 return SizedBox(
//                   height: 12.sp,
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
