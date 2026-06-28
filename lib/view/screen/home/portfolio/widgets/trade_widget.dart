import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/trade_order_group.dart';
import '../../../../../model/trade_order_model.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../../view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../../view_model/utils/assets.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../components/live_text.dart';
import '../../../../components/svg_widget.dart';
import 'creat_trade.dart';
class TradeWidget extends StatelessWidget {
  final GroupOfTradesOrOrders tradeGroup;
  final String groupKey;

  const TradeWidget({
    super.key,
    required this.groupKey,
     required this.tradeGroup,
  });

  @override
  Widget build(BuildContext context) {
    final tradesCubit = context.read<TradesCubit>();

    return BlocBuilder<TradesCubit, TradesState>(
      builder: (context, state) {


        final isOpen = tradesCubit.isGroupExpanded(groupKey);

        final group = tradesCubit.groupOfTradesOrOrders.firstWhere(
              (g) => '${g.metal ?? ''}_${g.currency ?? ''}' == groupKey,
          orElse: () => GroupOfTradesOrOrders(tradesOrOrders: []),
        );

        final tradeList = group.tradesOrOrders ?? [];
        final TradeOrOrder summaryTrade =
        tradeList.isNotEmpty ? tradeList.first : TradeOrOrder();

        final bool hasMoreThanOne = tradeList.length > 1;
        final bool effectiveOpen = hasMoreThanOne ? isOpen : true;










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
 // ////////////////////////////////////////////////////////////////////////////////////////  gold image
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: SvgWidget(
                                    assetName: AppAssets.gold3,
                                    width: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 6.sp),
///////////////////////////////////////////////////////////////////////////////////////////  product name
                                Expanded(
                                  child: Text(
                                    "${tradeGroup.title}",
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
// ////////////////////////////////////////////////////////////////////////////////////////  total onl
                                SizedBox(width: 8.w),
                                BlocBuilder<LivePriceCubit, LivePriceState>(
                                  builder: (context, liveState) {
                                    double totalPnl = 0.0;

                                    if (liveState is LivePriceLive) {
                                      for (final trade in tradeList) {
                                        final String currencyKey =
                                        (trade.currency ?? 'USD')
                                            .toUpperCase();

                                        final mp =   liveState.metals[currencyKey];


                                        final double livePrice =
                                            ((mp?.buy ?? 0).toDouble()) *
                                                (trade.unitGramWeight ?? 0);

                                        final double openPrice = (trade.openPrice ?? 0).toDouble();


                                        final double qty =  (trade.quantity ?? 0).toDouble();


                                        totalPnl += (livePrice - openPrice) * qty;

                                      }
                                    }

                                    final bool isProfit = totalPnl >= 0;

                                    return 
                                    //   Text(
                                    //   totalPnl.toStringAsFixed(2),
                                    //   style: TextStyle(
                                    //     color: isProfit
                                    //         ? AppColors.blueColor
                                    //         : AppColors.red,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    // );





                                    LivePriceText(
                                      price: double.parse(Methods.removeTrailingZeros(num.parse(totalPnl.toString()))),
                                      decimals: 2,
                                      fakeMinDelta: 0.01,
                                      fakeMaxDelta: 0.05,
                                      fakeTickEvery:
                                      const Duration(milliseconds: 900),
                                      neutralColor: Colors.transparent,
                                      upColor: Colors.transparent,
                                      downColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      width: null, // ✅ ياخد عرض الأب (Flexible)
                                      alignment: Alignment.centerRight,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                        color: isProfit
                                            ? AppColors.blueColor
                                            : AppColors.red,
                                      ),
                                    );   
                                    
                                    
                                    
                                    
                                    
                                  },
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
////////////////////////////////////////////////////////////////////////////////////////  list of tade group
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

                              return CreatTrade(
                                productTitle: tradeGroup.title ?? '',
                                trade: trade,
                                tradesCubit: tradesCubit,
                                lastIndex: isLast,
                              );
                            }),
                          ),
                          secondChild: CreatTrade(
                            productTitle: tradeGroup.title ?? '',
                            lastIndex: true,
                            trade: summaryTrade,
                            tradesCubit: tradesCubit,
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
//
//   const TradeWidget({
//     super.key,
//     required this.groupKey,
//     required this.tradeGroup,
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
//           (g) => (g.metal ?? '') == groupKey,
//           orElse: () => GroupOfTradesOrOrders(tradesOrOrders: []),
//         );
//         final tradeList = group.tradesOrOrders ?? [];
//
//         // final totalQty = tradeList.fold<double>(
//         //   0.0,
//         //   (sum, t) => sum + (double.tryParse(t.quantity.toString()) ?? 0.0),
//         // );
//         final TradeOrOrder summaryTrade =  tradeList.isNotEmpty ? tradeList.first : TradeOrOrder();
//         // ✅ لو صفقة واحدة: مفيش سهم
//         final bool hasMoreThanOne = tradeList.length > 1;
//         // ✅ لو صفقة واحدة نخليها تظهر كأنها مفتوحة على طول
//         final bool effectiveOpen = hasMoreThanOne ? isOpen : true;
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
//                       Material(
//                         color: AppColors.black,
//                         borderRadius: BorderRadius.circular(50.sp),
//                         child: Row(
//                           children: [
//  ////////////////////////////////////////////////////////////////////////////////////////////  gold image
//                             Padding(
//                               padding: const EdgeInsets.all(6.0),
//                               child: SvgWidget(
//                                 assetName: AppAssets.gold3,
//                                 width: 20.sp,
//                               ),
//                             ),
//                             SizedBox(width: 6.sp),
// ///////////////////////////////////////////////////////////////////////////////////////////  product name
//                             Text(
//                               "${tradeGroup.title}",
//                               style: const TextStyle(color: AppColors.white),
//                             ),
//                             SizedBox(width: 6.w),
//
//
// ////////////////////////////////////////////////////////////////////////////////////////  total onl
// //                             Text(
// //                               "${(livePrice - openPrice)*trade.quantity!,
// //                               style: const TextStyle(color: AppColors.white),
// //                             ),
//
//
//
//                           ],
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
//                       // ✅ السهم يظهر فقط لو فيه أكتر من صفقة
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
//
//                       Expanded(
//                         child: AnimatedCrossFade(
//                           duration: const Duration(milliseconds: 250),
//                           crossFadeState: effectiveOpen
//                               ? CrossFadeState.showFirst
//                               : CrossFadeState.showSecond,
//                           // ✅ OPEN: قائمة trades
//                           firstChild:
//                           Column(
//                             children: List.generate(tradeList.length, (index) {
//                               final trade = tradeList[index];
//                               final isLast = index == tradeList.length - 1||(hasMoreThanOne==false&&index==0);
//                               return CreatTrade(
//                                 productTitle:tradeGroup.title! ,
//                                 trade: trade,
//                                 tradesCubit: tradesCubit,
//                                 lastIndex:isLast,
//                               );
//                             }),
//                           ),
//                           // ✅ CLOSED: ملخص بالتجميعة (يظهر فقط لو فيه أكتر من صفقة)
//                           secondChild: CreatTrade(
//                             productTitle:tradeGroup.title! ,
//                             lastIndex: true,
//                             trade: summaryTrade,
//                             tradesCubit: tradesCubit,
//
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
