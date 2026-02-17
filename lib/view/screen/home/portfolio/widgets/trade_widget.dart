import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/new_trades.dart';
import '../../../../../model/trade_model.dart';
import '../../../../../view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../../view_model/utils/assets.dart';
import '../../../../../view_model/utils/colors.dart';
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
          (g) => (g.metal ?? '') == groupKey,
          orElse: () => GroupOfTradesOrOrders(tradesOrOrders: []),
        );
        final tradeList = group.tradesOrOrders ?? [];

        // final totalQty = tradeList.fold<double>(
        //   0.0,
        //   (sum, t) => sum + (double.tryParse(t.quantity.toString()) ?? 0.0),
        // );
        final TradeOrOrder summaryTrade =  tradeList.isNotEmpty ? tradeList.first : TradeOrOrder();
        // ✅ لو صفقة واحدة: مفيش سهم
        final bool hasMoreThanOne = tradeList.length > 1;
        // ✅ لو صفقة واحدة نخليها تظهر كأنها مفتوحة على طول
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
                      Material(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(50.sp),
                        child: Row(
                          children: [
 ////////////////////////////////////////////////////////////////////////////////////////////  gold image
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: SvgWidget(
                                assetName: AppAssets.gold3,
                                width: 20.sp,
                              ),
                            ),
                            SizedBox(width: 6.sp),
///////////////////////////////////////////////////////////////////////////////////////////  product name
                            Text(
                              "${tradeGroup.title}",
                              style: const TextStyle(color: AppColors.white),
                            ),
                            SizedBox(width: 6.w),
                          ],
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
                      // ✅ السهم يظهر فقط لو فيه أكتر من صفقة
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
                          // ✅ OPEN: قائمة trades
                          firstChild:
                          Column(
                            children: List.generate(tradeList.length, (index) {
                              final trade = tradeList[index];
                              final isLast = index == tradeList.length - 1||(hasMoreThanOne==false&&index==0);
                              return CreatTrade(
                                productTitle:tradeGroup.title! ,
                                trade: trade,
                                tradesCubit: tradesCubit,
                                lastIndex:isLast,
                              );
                            }),
                          ),
                          // ✅ CLOSED: ملخص بالتجميعة (يظهر فقط لو فيه أكتر من صفقة)
                          secondChild: CreatTrade(
                            productTitle:tradeGroup.title! ,
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
// num livePrice=2000;
// void showCloseTradeSheet(
//   BuildContext context,
//
//   TradeOrOrder trade,
//   TradesCubit tradesCubit,
// )
// {
//   showModalBottomSheet(
//     context: context,
//     isDismissible: false,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Close trade?",
//               style: TextStyle(
//                 color: AppColors.yellow,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//              Text(
//
//
//              trade.openPrice! < livePrice
//                   ? "Profit"
//                   : "lose",
//
//
//
//
//               style: TextStyle(
//                 color: trade.openPrice! < livePrice
//                     ? AppColors.blueColor
//                     : AppColors.red,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               (livePrice - trade.openPrice!)
//                   .toStringAsFixed(2),
//               style: TextStyle(
//
//                 color:trade.openPrice! < livePrice
//                     ? AppColors.blueColor
//                     : AppColors.red,
//
//
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   tradesCubit.closeTrade(
//                       orderId: trade.id, closePrice:
//                   (livePrice - trade.openPrice!).abs()
//                       .toStringAsFixed(2)
//
//                   );
//                   Navigator.pop(context, true);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.yellow2,
//                   foregroundColor: AppColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   "Close",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             GestureDetector(
//               onTap: () => Navigator.pop(context, false),
//               child: const Text(
//                 "Cancel",
//                 style: TextStyle(
//                   color: AppColors.yellow2,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       );
//     },
//   );
// }

//////////////////////////////////////////////////////////////////// before osama in creat trade and trade widget and trade details

//
// class TradeWidget extends StatelessWidget {
//   // final String wholeTradeName;
//   final  GroupOfTradesOrOrders tradeGroup;
//   final String groupKey;
//
//   const TradeWidget({
//     super.key,
//     // required this.wholeTradeName,
//     required this.groupKey, required this.tradeGroup,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final tradesCubit = context.read<TradesCubit>();
//
//     return BlocBuilder<TradesCubit, TradesState>(
//       builder: (context, state) {
//         final isOpen = tradesCubit.isGroupExpanded(groupKey);
//
//         final group = tradesCubit.groupOfTradesOrOrders.firstWhere(
//               (g) => (g.metal ?? '') == groupKey,
//           orElse: () => GroupOfTradesOrOrders(tradesOrOrders: []),
//         );
//         final tradeList = group.tradesOrOrders ?? [];
//
//         final totalQty = tradeList.fold<double>(
//           0.0,
//               (sum, t) => sum + (double.tryParse(t.qty ?? "0") ?? 0.0),
//         );
//
//         final TradeOrOrder summaryTrade =
//         tradeList.isNotEmpty ? tradeList.first : TradeOrOrder();
//
//         // ✅ لو صفقة واحدة: مفيش سهم
//         final bool hasMoreThanOne = tradeList.length > 1;
//
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
//                             Padding(
//                               padding: const EdgeInsets.all(6.0),
//                               child: SvgWidget(
//                                 assetName: AppAssets.gold3,
//                                 width: 20.sp,
//                               ),
//                             ),
//                             SizedBox(width: 6.sp),
//                             Text(
//                               tradeGroup.title!,
//                               style: const TextStyle(color: AppColors.white),
//                             ),
//                             SizedBox(width: 6.w),
//                           ],
//                         ),
//                       ),
//
// //////////////////////////////////////////////////////  المتغير اليومي لو بعتهولنا اسامه
//                       // const Text(
//                       //   '1234.4',
//                       //   style: TextStyle(color: AppColors.blueColor),
//                       // ),
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
//
//                           // ✅ OPEN: قائمة trades
//                           firstChild: Column(
//                             children: tradeList.map((trade) {
//                               return CreatTrade(
//                                 trade: trade,
//                                 displayQty: null,
//                                 onCloseTap: () {
//                                   showCloseTradeSheet(
//                                     context,
//                                     trade,
//                                     tradesCubit,
//                                   );
//                                 },
//                               );
//                             }).toList(),
//                           ),
//
//                           // ✅ CLOSED: ملخص بالتجميعة (يظهر فقط لو فيه أكتر من صفقة)
//                           secondChild: CreatTrade(
//                             trade: summaryTrade,
//                             displayQty: totalQty.toStringAsFixed(2),
//                             onCloseTap: () {
//                               tradesCubit.toggleGroup(groupKey);
//                             },
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
// num livePrice=2000;
// void showCloseTradeSheet(
//     BuildContext context,
//
//     TradeOrOrder trade,
//     TradesCubit tradesCubit,
//     )
// {
//   showModalBottomSheet(
//     context: context,
//     isDismissible: false,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Close trade?",
//               style: TextStyle(
//                 color: AppColors.yellow,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//
//
//               num.parse(trade.openPrice!) < livePrice
//                   ? "Profit"
//                   : "lose",
//
//
//
//
//               style: TextStyle(
//                 color: num.parse(trade.openPrice!) < livePrice
//                     ? AppColors.blueColor
//                     : AppColors.red,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               (livePrice - num.parse(trade.openPrice!))
//                   .toStringAsFixed(2),
//               style: TextStyle(
//
//                 color: num.parse(trade.openPrice!) < livePrice
//                     ? AppColors.blueColor
//                     : AppColors.red,
//
//
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   tradesCubit.closeTrade(
//                       orderId: trade.id, closePrice:
//                   (livePrice - num.parse(trade.openPrice!)).abs()
//                       .toStringAsFixed(2)
//
//                   );
//                   Navigator.pop(context, true);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.yellow2,
//                   foregroundColor: AppColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   "Close",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             GestureDetector(
//               onTap: () => Navigator.pop(context, false),
//               child: const Text(
//                 "Cancel",
//                 style: TextStyle(
//                   color: AppColors.yellow2,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       );
//     },
//   );
// }
//

////////////////////////////////////////////////////////////////////////////////////// old

// class TradeWidget extends StatelessWidget {
//   final Trade product;
//   final void Function()? onTap;
//   final TradesCubit tradesCubit;
//   const TradeWidget({required this.product, this.onTap, super.key, required this.tradesCubit});
//
//   @override
//   Widget build(BuildContext context) {
//     return
//
//       BlocProvider.value(
//           value: tradesCubit,
//           child:
//           Material(
//             color: AppColors.transparent,
//             borderRadius: BorderRadius.circular(12.sp),
//             child: InkWell(
//               onTap: onTap,
//               borderRadius: BorderRadius.circular(12.sp),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12.sp),
//                   border: Border.all(
//                     color: AppColors.yellow2,
//                     width: 1.sp,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(8.sp),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
//                         children: [
//                           Material(
//                             color: AppColors.black,//black
//                             borderRadius: BorderRadius.circular(50.sp),
//                             child: Container(
//                               padding: EdgeInsets.all(0.sp),
//                               child: Row(
//                                 children: [
// ///////////////////////////////////////////////////////////////////////////////////////////////////// gold image
//                                   Padding(
//                                     padding: const EdgeInsets.all(6.0),
//                                     child: SvgWidget(
//                                       assetName: AppAssets.gold3,
//                                       // color: AppColors.transparent,
//                                       width: 20.sp,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 6.sp,
//                                   ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////// gold name
//                                   Text(
//                                     LocaleKeys.gold.tr().toUpperCase(),
//                                     style: const TextStyle(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 6.w,
//                                   ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////// icon
//                                   const Icon(
//                                     Icons.arrow_forward_ios_rounded,
//                                     color: AppColors.yellow2,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////// price
//                           Center(
//                             child: Text(
//                               '+${product.price}',
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 color: AppColors.blueColor,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// divider
//                     const Divider(  color: AppColors.yellow2,),
//
//
//
//                     Padding(
//                       padding: EdgeInsets.all(8.sp),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Material(
//                                 color: AppColors.blueColor,
//                                 borderRadius: BorderRadius.circular(8.sp),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 14.sp,
//                                     vertical: 5.h,
//                                   ),
//                                   child: Text('+${product.qty}',style:     Theme.of(context)
//                                       .textTheme
//                                       .bodyLarge
//                                       ?.copyWith(
//                                     color: AppColors.white,
//                                   ),),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 6.sp,
//                               ),
//                               Expanded(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     const Text(
//                                       'P&L',
//                                     ),
//                                     SizedBox(
//                                       width: 6.sp,
//                                     ),
//                                     Text(
//                                       '+14.854',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyLarge
//                                           ?.copyWith(
//                                             color: AppColors.blueColor,
//                                           ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 6.h,
//                           ),
//                           Row(
//                             children: [
//                               const Text(
//                                 '2.5494',
//                                 style: TextStyle(
//                                   color: AppColors.greyText,
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 6.sp,
//                               ),
//                               Icon(
//                                 Icons.arrow_forward_ios_rounded,
//                                 color: AppColors.yellow2,
//                                 size: 12.sp,
//                               ),
//                               SizedBox(
//                                 width: 6.sp,
//                               ),
//                               const Text(
//                                 '2.5494',
//                                 style: TextStyle(
//                                   color: AppColors.greyText,
//                                 ),
//                               ),
//                               const Spacer(),
//                               InkWell(
//                                 onTap: (){
//                                   showCloseTradeSheet(context, 0.15,product);
//                                 },
//                                 child: CircleAvatar(
//                                   backgroundColor: AppColors.greyText,
//                                   radius: 10.r,
//                                   child: Icon(
//                                     Icons.close,
//                                     size: 16.sp,
//                                     color: AppColors.grey,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//
//
//                   ],
//                 ),
//               ),
//             ),
//           )
//       )  ;
//
//
//
//
//
//
//
//
//
//
//   }
// }
// void showCloseTradeSheet(BuildContext context, double profit, Trade trad) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Close trade?",
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               "Profit",
//               style: TextStyle(
//                 color: AppColors.greyText,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               "${profit >= 0 ? "+" : ""}\$${profit.toStringAsFixed(2)}",
//               style: TextStyle(
//                 color: profit >= 0 ? AppColors.green : AppColors.red,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   AppLoader.showLoader(context, ValueKey("sell_price"));
//                   ApiService _appService =ApiService();
//                   await _appService.sellOrder(orderId: trad.id ?? 0, ctx: context);
//                   Navigator.pop(context, true); // رجع قيمة لو تبغى
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.yellow2,
//                   foregroundColor: AppColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   "Close",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             GestureDetector(
//               onTap: () => Navigator.pop(context, false),
//               child: const Text(
//                 "Cancel",
//                 style: TextStyle(
//                   color: AppColors.yellow2,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
