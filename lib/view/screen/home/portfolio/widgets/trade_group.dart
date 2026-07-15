import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/trade_order_group.dart';
import '../../../../../model/trade_order_model.dart';
import '../../../../../view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../../view_model/utils/assets.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../components/live_text.dart';
import '../../../../components/svg_widget.dart';
import 'creat_trade.dart';


class TradeGroup extends StatelessWidget {
  final GroupOfTradesOrOrders tradeGroup;
  final String groupKey;
  final num totalPnlOfEachGroup;

  const TradeGroup({
    super.key,
    required this.groupKey,
    required this.tradeGroup,
    required this.totalPnlOfEachGroup,
  });

  @override
  Widget build(BuildContext context) {
    final tradesCubit = context.read<TradesCubit>();

    return BlocBuilder<TradesCubit, TradesState>(
      builder: (context, state) {
        final isOpen = tradesCubit.isGroupExpanded(groupKey);
        final group = tradesCubit.groupOfTradesOrOrders.firstWhere(
              (g) => '${g.metal ?? ''}_${g.currency ?? ''}' == groupKey,
          orElse: () => tradeGroup,
        );
        final tradeList = group.tradesOrOrders ?? [];
        final TradeOrOrder summaryTrade = tradeList.isNotEmpty ? tradeList.first : TradeOrOrder();
        final bool hasMoreThanOne = tradeList.length > 1;
        final bool effectiveOpen = hasMoreThanOne ? isOpen : true;

        // حساب حالة الربح للجروب بالكامل
        final bool isProfit = totalPnlOfEachGroup >= 0;

        // ✅ قراءة البيانات الجاهزة للـ summaryTrade لتمريها لاحقاً
        final int summaryTradeId = summaryTrade.id ?? 0;
        final num summaryTradePnl = tradesCubit.singleTradePnlMap[summaryTradeId] ?? 0.0;
        final num summaryLivePrice = tradesCubit.singleTradeLivePriceMap[summaryTradeId] ?? 0.0;
        final bool isSummaryProfit = summaryTradePnl >= 0;
        final bool isSummaryLive = summaryLivePrice > 0;

        return Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(12.sp),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: AppColors.yellow2, width: 1.sp),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Material(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(50.sp),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.sp,
                              vertical: 6.sp,
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: SvgWidget(
                                    assetName: AppAssets.gold3,
                                    width: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 6.sp),
                                Expanded(
                                  child: Text(
                                    "${tradeGroup.title}",
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                LivePriceText(
                                  price: double.parse(Methods.removeTrailingZeros(totalPnlOfEachGroup)),
                                  decimals: 2,
                                  fakeMinDelta: 0.01,
                                  fakeMaxDelta: 0.05,
                                  fakeTickEvery: const Duration(milliseconds: 900),
                                  neutralColor: Colors.transparent,
                                  upColor: Colors.transparent,
                                  downColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  width: null,
                                  alignment: Alignment.centerRight,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isProfit ? AppColors.blueColor : AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.yellow2),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasMoreThanOne) ...[
                        InkWell(
                          onTap: () => tradesCubit.toggleGroup(groupKey),
                          child: AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: isOpen ? 0.5 : 0.0,
                            child: Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: AppColors.yellow2,
                              size: 26.sp,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: effectiveOpen
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Column(
                            children: List.generate(tradeList.length, (index) {
                              final trade = tradeList[index];
                              final isLast = index == tradeList.length - 1 ||
                                  (hasMoreThanOne == false && index == 0);

                              // ✅ قراءة حسابات الصفقة المحددة من الكيوبت مباشرة
                              final int tradeId = trade.id ?? 0;
                              final num tradePnl = tradesCubit.singleTradePnlMap[tradeId] ?? 0.0;
                              final num livePrice = tradesCubit.singleTradeLivePriceMap[tradeId] ?? 0.0;
                              final bool tradeIsProfit = tradePnl >= 0;
                              final bool tradeHasLive = livePrice > 0;

                              return CreatTrade(
                                productTitle: tradeGroup.title ?? '',
                                trade: trade,
                                tradesCubit: tradesCubit,
                                lastIndex: isLast,
                                livePrice: livePrice,
                                pnl: tradePnl,
                                isProfit: tradeIsProfit,
                                hasLive: tradeHasLive,
                              );
                            }),
                          ),
                          secondChild: CreatTrade(
                            productTitle: tradeGroup.title ?? '',
                            lastIndex: true,
                            trade: summaryTrade,
                            tradesCubit: tradesCubit,
                            livePrice: summaryLivePrice,
                            pnl: summaryTradePnl,
                            isProfit: isSummaryProfit,
                            hasLive: isSummaryLive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// class TradeWidget extends StatelessWidget {
//   final GroupOfTradesOrOrders tradeGroup;
//   final String groupKey;
//   final num totalPnlOfEachGroup; // 👈 تم إضافة المتغير لاستقبال الربح/الخسارة جاهزاً
//
//   const TradeWidget({
//     super.key,
//     required this.groupKey,
//     required this.tradeGroup,
//     required this.totalPnlOfEachGroup, // 👈 مطلوب الآن
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final tradesCubit = context.read<TradesCubit>();
//
//     return BlocBuilder<TradesCubit, TradesState>(
//       builder: (context, state) {
//         final isOpen = tradesCubit.isGroupExpanded(groupKey);
//         final group = tradesCubit.groupOfTradesOrOrders.firstWhere(
//               (g) => '${g.metal ?? ''}_${g.currency ?? ''}' == groupKey,
//           orElse: () => tradeGroup,
//         );
//         final tradeList = group.tradesOrOrders ?? [];
//         final TradeOrOrder summaryTrade = tradeList.isNotEmpty ? tradeList.first : TradeOrOrder();
//         final bool hasMoreThanOne = tradeList.length > 1;
//         final bool effectiveOpen = hasMoreThanOne ? isOpen : true;
//
//         // حساب حالة الربح من المتغير الجاهز
//         final bool isProfit = totalPnlOfEachGroup >= 0;
//
//         return Material(
//           color: AppColors.transparent,
//           borderRadius: BorderRadius.circular(12.sp),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeInOut,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12.sp),
//               border: Border.all(color: AppColors.yellow2, width: 1.sp),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(8.sp),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Material(
//                           color: AppColors.black,
//                           borderRadius: BorderRadius.circular(50.sp),
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 8.sp,
//                               vertical: 6.sp,
//                             ),
//                             child: Row(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(6.0),
//                                   child: SvgWidget(
//                                     assetName: AppAssets.gold3,
//                                     width: 20.sp,
//                                   ),
//                                 ),
//                                 SizedBox(width: 6.sp),
//                                 Expanded(
//                                   child: Text(
//                                     "${tradeGroup.title}",
//                                     style: const TextStyle(
//                                       color: AppColors.white,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 SizedBox(width: 8.w),
//                                 // ❌ تم حذف الـ BlocBuilder الخاص بالـ LivePriceCubit
//                                 // ✅ نستخدم المتغير الممرر جاهزاً
//                                 LivePriceText(
//                                   price: double.parse(Methods.removeTrailingZeros(totalPnlOfEachGroup)),
//                                   decimals: 2,
//                                   fakeMinDelta: 0.01,
//                                   fakeMaxDelta: 0.05,
//                                   fakeTickEvery: const Duration(milliseconds: 900),
//                                   neutralColor: Colors.transparent,
//                                   upColor: Colors.transparent,
//                                   downColor: Colors.transparent,
//                                   padding: EdgeInsets.zero,
//                                   width: null,
//                                   alignment: Alignment.centerRight,
//                                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                     color: isProfit ? AppColors.blueColor : AppColors.red,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Divider(color: AppColors.yellow2),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (hasMoreThanOne) ...[
//                         InkWell(
//                           onTap: () => tradesCubit.toggleGroup(groupKey),
//                           child: AnimatedRotation(
//                             duration: const Duration(milliseconds: 200),
//                             turns: isOpen ? 0.5 : 0.0,
//                             child: Icon(
//                               Icons.keyboard_arrow_down_outlined,
//                               color: AppColors.yellow2,
//                               size: 26.sp,
//                             ),
//                           ),
//                         ),
//                       ],
//                       Expanded(
//                         child: AnimatedCrossFade(
//                           duration: const Duration(milliseconds: 250),
//                           crossFadeState: effectiveOpen
//                               ? CrossFadeState.showFirst
//                               : CrossFadeState.showSecond,
//                           firstChild: Column(
//                             children: List.generate(tradeList.length, (index) {
//                               final trade = tradeList[index];
//                               final isLast = index == tradeList.length - 1 ||
//                                   (hasMoreThanOne == false && index == 0);
//
//                               return CreatTrade(
//                                 productTitle: tradeGroup.title ?? '',
//                                 trade: trade,
//                                 tradesCubit: tradesCubit,
//                                 lastIndex: isLast,
//                               );
//                             }),
//                           ),
//                           secondChild: CreatTrade(
//                             productTitle: tradeGroup.title ?? '',
//                             lastIndex: true,
//                             trade: summaryTrade,
//                             tradesCubit: tradesCubit,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
