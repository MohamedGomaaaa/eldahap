import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/metal_price_model.dart';
import '../../../../../model/trade_order_model.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../../view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../../../../components/live_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../trade_details_screen.dart';

class CreatTrade extends StatelessWidget {
  final TradeOrOrder trade;
  final TradesCubit tradesCubit;

   final bool lastIndex;
   final String productTitle;
  const CreatTrade({
    super.key,
    required this.trade,

    required this.tradesCubit,
     required this.lastIndex,
     required this.productTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivePriceCubit, LivePriceState>(
      builder: (context, liveState) {
        final String currencyKey = (trade.currency ?? 'USD').toUpperCase();

        MetalPrices? mp;
        if (liveState is LivePriceLive) {
          mp = liveState.metals[currencyKey];
        }

        final double livePrice = (mp?.buy ?? 0).toDouble()*trade.unitGramWeight!;
        final double openPrice = (trade.openPrice ?? 0).toDouble();

        // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
        final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;

        final double pnl = (livePrice - openPrice)*trade.quantity!;
        final bool isProfit = pnl >= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: lastIndex == true
              ? null
              : const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.yellow, width: 1.0),
                  ),
                ),
          padding: EdgeInsets.only(
            top: 4.sp,
            right: 8.sp,
            left: 8.sp,
            bottom: 8.sp,
          ),
          child: Row(
            children: [
/////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ LEFT (ياخد المساحة المتاحة)
              Expanded(
                flex: 6,
                child: InkWell(
                  // ✅ ميروحش على التفاصيل لو مفيش live
                  onTap: hasLive
                      ? () => Navigation.push(
                            context,

                            TradeDetailsScreen(
                              trade: trade,
                              productTitle: productTitle,
                            ),
                          )
                      : null,
                  child: Opacity(
                    // ✅ نفس فكرة CreatOrder
                    opacity: hasLive ? 1.0 : 0.35,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
//////////////////////////////////////////////////////////////////////////////////////////////////// quantity in blue container
                        Material(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(8.sp),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.sp,
                              vertical: 5.h,
                            ),
                            child: Text(
                              '+${trade.quantity?.toString() ?? "0"} of ${Methods.removeTrailingZeros(trade.unitGramWeight!)} gm',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
/////////////////////////////////////////////////////////////////////////////////////////////// _creat Low And High Price
                        _creatLowAndHighPrice(
                          context: context,
                          openPrice: openPrice,
                          livePrice: livePrice,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ RIGHT (Close + P&L)
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: hasLive
                      ? () => showCloseTradeSheet(
                            context,
                            trade,
                            tradesCubit,
                            livePrice,
                          )
                      : null,
                  child: Opacity(
                    opacity: hasLive ? 1.0 : 0.35,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
//////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ P&L بيتحرك لايف
                            Flexible(
                              child: LivePriceText(
                                price: pnl,
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
                              ),
                            ),
                            SizedBox(width: 6.w),
                            const Text('P&L'),
                          ],
                        ),
                        SizedBox(height: 6.h),
  //////////////////////////////////////////////////////////////////////////////////////////////////////////// close icon
                        CircleAvatar(
                          backgroundColor: AppColors.red,
                          radius: 10.r,
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }





  Widget _creatLowAndHighPrice({
    required BuildContext context,
    required double openPrice,
    required double livePrice,
  })
  {
    return Row(
      children: [
        Text(
         Methods.removeTrailingZeros( openPrice),
          style: const TextStyle(color: AppColors.greyText),
        ),
        SizedBox(width: 6.w),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.yellow2,
          size: 12.sp,
        ),
        SizedBox(width: 6.w),

        /// ✅ live price ياخد باقي السطر
        Expanded(
          child:
          LivePriceText(
            alignment: Alignment.centerLeft,
            price: livePrice,
            decimals: 2,
            fakeMinDelta: 0.01,
            fakeMaxDelta: 0.05,
            fakeTickEvery: const Duration(milliseconds: 900),
            neutralColor: Colors.transparent,
            upColor: Colors.transparent,
            downColor: Colors.transparent,
            padding: EdgeInsets.zero,
            width: null,
            style: const TextStyle(color: AppColors.greyText),
          ),
        ),
      ],
    );
  }

  void showCloseTradeSheet(
    BuildContext context,
    TradeOrOrder trade,
    TradesCubit tradesCubit,
    double livePrice,
  )
  {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final open = (trade.openPrice ?? 0).toDouble();
        final pnl = livePrice - open;
        final isProfit = pnl >= 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Close trade?",
                style: TextStyle(
                  color: AppColors.yellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isProfit ? "Profit" : "Lose",
                style: TextStyle(
                  color: isProfit ? AppColors.blueColor : AppColors.red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pnl.toStringAsFixed(2),
                style: TextStyle(
                  color: isProfit ? AppColors.blueColor : AppColors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    tradesCubit.closeTrade(
                      orderId: trade.id,
                      closePrice: pnl.abs().toStringAsFixed(2),
                    );

                    Navigator.pop(context, true);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow2,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:(){Navigator.pop(context, false);},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow2,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:  const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
























// class CreatTrade extends StatelessWidget {
//   final TradeOrOrder trade;
//   final TradesCubit tradesCubit;
//   final String? displayQty;
//
//   const CreatTrade({
//     super.key,
//     required this.trade,
//     required this.displayQty,
//     required this.tradesCubit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LivePriceCubit, LivePriceState>(
//       builder: (context, liveState) {
//         // ✅ هات العملة من trade (fallback USD)
//         final String currencyKey = (trade.currency ?? 'USD').toUpperCase();
//
//         MetalPrices? mp;
//         if (liveState is LivePriceLive) {
//           mp = liveState.metals[currencyKey];
//         }
//
//         // ✅ السعر اللايف "زي ما هو" من السوكت (بدون ضرب)
//         final double livePrice = (mp?.buy ?? 0).toDouble();
//         // final double livePrice = (mp?.sell ?? 0).toDouble();
//
//         // ✅ openPrice
//         final double openPrice = (trade.openPrice ?? 0).toDouble();
//
//         // ✅ لو السوكت لسه ما جابش سعر
//         final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;
//         final double pnl = livePrice - openPrice;
//         final bool isProfit = pnl >= 0;
//         return Container(
//           margin: const EdgeInsets.only(bottom: 10),
//           decoration: const BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: AppColors.yellow,
//                 width: 1.0,
//               ),
//             ),
//           ),
//           padding: EdgeInsets.only(
//             top: 4.sp,
//             right: 8.sp,
//             left: 8.sp,
//             bottom: 8.sp,
//
//           ),
//           child:
//           Row(
//             children: [
//               Container(
//                 width:getSize(context: context).width*0.5,
//                 color: Colors.green,
//                 child: InkWell(
//                   onTap: () {
//                     Navigation.push(context, TradeDetailsScreen(trade));
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Material(
//                         color: AppColors.blueColor,
//                         borderRadius: BorderRadius.circular(8.sp),
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 14.sp,
//                             vertical: 5.h,
//                           ),
//                           child: Text(
//                             '+${displayQty ?? (trade.qty?.toString() ?? "0")}',
//                             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                               color: AppColors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 6.sp),
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ open -> live
//                       _creatLowAndHighPrice(
//                         context: context,
//                         openPrice: openPrice,
//                         livePrice: livePrice,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(width: 6.sp),
// ////////////////////////////////////////////////////////////////////////////////////////////// ✅ Close (Disabled لو مفيش live)
//               InkWell(
//                 onTap: hasLive
//                     ? () {
//                   showCloseTradeSheet(
//                     context,
//                     trade,
//                     tradesCubit,
//                     livePrice,
//                   );
//                 }
//                     : null,
//                 child: Opacity(
//                   opacity: hasLive ? 1.0 : 0.35,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Container(
//                              color: Colors.yellow,
//                             child: SizedBox(
//                                 width:getSize(context: context).width*0.5, // أو أي عرض يناسبك
//                               child: LivePriceText(
//                                 price: double.parse("7787"),//pnl
//                                 decimals: 2,
//                                 fakeMinDelta: 0.01,
//                                 fakeMaxDelta: 0.05,
//                                 fakeTickEvery: const Duration(milliseconds: 900),
//                                 neutralColor: Colors.transparent,
//                                 upColor: Colors.transparent,
//                                 downColor: Colors.transparent,
//                                 padding: EdgeInsets.zero,
//                                 alignment: Alignment.center, // لو عايزه يمين
//                                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                   color: isProfit ? AppColors.blueColor : AppColors.red,
//                                 ),
//                               ),
//                             ),
//                           ),
//                            SizedBox(width: 6.sp),
//                           const Text('P&L'),
//
//
//
//                           // Text(
//                           //   (livePrice - openPrice).toStringAsFixed(2),
//                           //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           //     color: openPrice < livePrice
//                           //         ? AppColors.blueColor
//                           //         : AppColors.red,
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                       SizedBox(height: 6.sp),
//                       CircleAvatar(
//                         backgroundColor: AppColors.red,
//                         radius: 10.r,
//                         child: Icon(
//                           Icons.close,
//                           size: 16.sp,
//                           color: AppColors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//
//   Widget _creatLowAndHighPrice({
//     required BuildContext context,
//     required double openPrice,
//     required double livePrice,
//   })
//   {
//     return Container(
//       color: Colors.red,
//       child: Row(
//         children: [
//           Text(
//             openPrice.toStringAsFixed(2),
//             style: const TextStyle(color: AppColors.greyText),
//           ),
//           SizedBox(width: 6.sp),
//           Icon(
//             Icons.arrow_forward_ios_rounded,
//             color: AppColors.yellow2,
//             size: 12.sp,
//           ),
//           SizedBox(width: 6.sp),
//           SizedBox(
//             width:getSize(context: context).width*0.5,
//             child: LivePriceText(
//               alignment: Alignment.centerLeft,
//               price: livePrice,
//               decimals: 2,
//               fakeMinDelta: 0.01,
//               fakeMaxDelta: 0.05,
//               fakeTickEvery: const Duration(milliseconds: 900),
//               neutralColor: Colors.transparent,
//               upColor: Colors.transparent,
//               downColor: Colors.transparent,
//               padding: EdgeInsets.zero,
//               style: const TextStyle(color: AppColors.greyText),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   void showCloseTradeSheet(
//       BuildContext context,
//       TradeOrOrder trade,
//       TradesCubit tradesCubit,
//       double livePrice,
//       )
//   {
//     showModalBottomSheet(
//       context: context,
//       isDismissible: false,
//       backgroundColor: AppColors.background,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Close trade?",
//                 style: TextStyle(
//                   color: AppColors.yellow,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 trade.openPrice! < livePrice ? "Profit" : "lose",
//                 style: TextStyle(
//                   color: trade.openPrice! < livePrice
//                       ? AppColors.blueColor
//                       : AppColors.red,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 (livePrice - trade.openPrice!).toStringAsFixed(2),
//                 style: TextStyle(
//                   color: trade.openPrice! < livePrice
//                       ? AppColors.blueColor
//                       : AppColors.red,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     tradesCubit.closeTrade(
//                       orderId: trade.id,
//                       closePrice: (livePrice - trade.openPrice!)
//                           .abs()
//                           .toStringAsFixed(2),
//                     );
//                     Navigator.pop(context, true);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.yellow2,
//                     foregroundColor: AppColors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     "Close",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context, false),
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(
//                     color: AppColors.yellow2,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
// }

// class CreatTrade extends StatelessWidget {
//   final TradeOrOrder trade;
//   final TradesCubit tradesCubit;
//   // final VoidCallback onCloseTap;
//   final String? displayQty;
//
//   const CreatTrade({
//     super.key,
//     required this.trade,
//     // required this.onCloseTap,
//     required this.displayQty,
//     required this.tradesCubit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LivePriceCubit, LivePriceState>(
//       builder: (context, liveState) {
//        // ✅ هات العملة من trade (fallback USD)
//         final String currencyKey = (trade.currency ?? 'USD').toUpperCase();
//         MetalPrices? mp;
//         if (liveState is LivePriceLive) {
//           mp = liveState.metals[currencyKey];
//         }
//         // ✅ السعر اللايف "زي ما هو" من السوكت (بدون ضرب)
//         // اختار BUY أو SELL حسب ما تحب
//         final double livePrice = (mp?.buy ?? 0).toDouble();
//          // final double livePrice = (mp?.sell ?? 0).toDouble();
//          // ✅ openPrice من الموديل (num?) لو null خليه 0
//         final double openPrice = (trade.openPrice ?? 0).toDouble();
//
//         return Container(
//           padding:
//               EdgeInsets.only(top: 4.sp, right: 8.sp, left: 8.sp, bottom: 8.sp),
//           child: Row(
//             children: [
//               Expanded(
//                 flex: 8,
//                 child: InkWell(
//                   onTap: () {
//                     Navigation.push(context, TradeDetailsScreen(trade));
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Material(
//                         color: AppColors.blueColor,
//                         borderRadius: BorderRadius.circular(8.sp),
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 14.sp,
//                             vertical: 5.h,
//                           ),
//                           child: Text(
//                             '+${displayQty ?? (trade.qty?.toString() ?? "0")}',
//                             style:
//                                 Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                       color: AppColors.white,
//                                     ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 6.sp),
//
// // ✅ عرض open -> live (لايف بيتحرك)
//                       _creatLowAndHighPrice(
//                         context: context,
//                         openPrice: openPrice,
//                         livePrice: livePrice,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(width: 6.sp),
//               InkWell(
//                 onTap: () {
//                   showCloseTradeSheet(
//                     context,
//                     trade,
//                     tradesCubit,
//                     livePrice,
//                   );
//                 },
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         const Text('P&L'),
//                         SizedBox(width: 6.sp),
//                         Text(
//                           (livePrice - openPrice).toStringAsFixed(2),
//                           style:
//                               Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                     color: openPrice < livePrice
//                                         ? AppColors.blueColor
//                                         : AppColors.red,
//                                   ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 6.sp),
//                     CircleAvatar(
//                       backgroundColor: AppColors.red,
//                       radius: 10.r,
//                       child: Icon(
//                         Icons.close,
//                         size: 16.sp,
//                         color: AppColors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void showCloseTradeSheet(
//     BuildContext context,
//     TradeOrOrder trade,
//     TradesCubit tradesCubit,
//     double livePrice,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isDismissible: false,
//       backgroundColor: AppColors.background,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Close trade?",
//                 style: TextStyle(
//                   color: AppColors.yellow,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 trade.openPrice! < livePrice ? "Profit" : "lose",
//                 style: TextStyle(
//                   color: trade.openPrice! < livePrice
//                       ? AppColors.blueColor
//                       : AppColors.red,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 (livePrice - trade.openPrice!).toStringAsFixed(2),
//                 style: TextStyle(
//                   color: trade.openPrice! < livePrice
//                       ? AppColors.blueColor
//                       : AppColors.red,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     tradesCubit.closeTrade(
//                         orderId: trade.id,
//                         closePrice: (livePrice - trade.openPrice!)
//                             .abs()
//                             .toStringAsFixed(2));
//                     Navigator.pop(context, true);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.yellow2,
//                     foregroundColor: AppColors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     "Close",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context, false),
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(
//                     color: AppColors.yellow2,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _creatLowAndHighPrice({
//     required BuildContext context,
//     required double openPrice,
//     required double livePrice,
//   }) {
//     return Row(
//       children: [
//         Text(
//           openPrice.toStringAsFixed(2),
//           style: const TextStyle(color: AppColors.greyText),
//         ),
//         SizedBox(width: 6.sp),
//         Icon(
//           Icons.arrow_forward_ios_rounded,
//           color: AppColors.yellow2,
//           size: 12.sp,
//         ),
//         SizedBox(width: 6.sp),
// // ✅ ده اللايف الحقيقي من السوكت زي ما هو (وبيتحرك)
//         SizedBox(
//           width: 120.w,
//           child: LivePriceText(
//             alignment: Alignment.centerLeft, //
//             price: livePrice,
//             decimals: 2,
//             fakeMinDelta: 0.01,
//             fakeMaxDelta: 0.05,
//             fakeTickEvery: const Duration(
//                 milliseconds: 900), // لو عايز نفس اللون الرمادي ومفيش خلفيات
//             neutralColor: Colors.transparent,
//             upColor: Colors.transparent,
//             downColor: Colors.transparent,
//             padding: EdgeInsets.zero,
//             style: const TextStyle(color: AppColors.greyText),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class CreatTrade extends StatelessWidget {
//   final TradeOrOrder trade;
//   final VoidCallback onCloseTap;
//   final String? displayQty;
//   CreatTrade({
//     super.key,
//     required this.trade,
//     required this.onCloseTap,
//     required this.displayQty,
//   });
//
//   num livePrice = 2000;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding:
//           EdgeInsets.only(top: 4.sp, right: 8.sp, left: 8.sp, bottom: 8.sp),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 8,
//             child: InkWell(
//               onTap: () {
//                 Navigation.push(context, TradeDetailsScreen(trade));
//               },
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Material(
//                     color: AppColors.blueColor,
//                     borderRadius: BorderRadius.circular(8.sp),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 14.sp,
//                         vertical: 5.h,
//                       ),
//                       child: Text(
//                         // '+${trade.qty ?? "0"}',
//                         '+${displayQty ?? (trade.qty ?? "0")}',
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                               color: AppColors.white,
//                             ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 6.sp,
//                   ),
// //////////////////////////////////////////////////////////////////////////////////////////////// Low And High Price
//                   creatLowAndHighPrice(),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 6.sp,
//           ),
// //////////////////////////////////////////////////////////////////////////////////////////////// second column
//
//           InkWell(
//             onTap: onCloseTap,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     const Text('P&L'),
//                     SizedBox(width: 6.sp),
//                     Text(
//                       (livePrice - trade.openPrice!)
//                           .toStringAsFixed(2),
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color: trade.openPrice! < livePrice
//                                 ? AppColors.blueColor
//                                 : AppColors.red,
//                           ),
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(
//                   height: 6.sp,
//                 ),
//                 ////////////////////////////////////////////////////////////////////////////////////////////////  cancel button
//                 CircleAvatar(
//                   backgroundColor: AppColors.greyText,
//                   radius: 10.r,
//                   child: Icon(
//                     Icons.close,
//                     size: 16.sp,
//                     color: AppColors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
// ////////////////////////////////////////////////////////////////////////////////////////////////  space
//
//           // SizedBox(height: 6.h),
//         ],
//       ),
//     );
//   }
//
//   Widget creatLowAndHighPrice() {
//     return Row(
//       children: [
//         Text(
//           trade.openPrice!.toStringAsFixed(2),
//           style: const TextStyle(color: AppColors.greyText),
//         ),
//         SizedBox(width: 6.sp),
//         Icon(
//           Icons.arrow_forward_ios_rounded,
//           color: AppColors.yellow2,
//           size: 12.sp,
//         ),
//         SizedBox(width: 6.sp),
//         Text(
//           'live price $livePrice',
//           style: const TextStyle(color: AppColors.greyText),
//         ),
//       ],
//     );
//   }
// }
