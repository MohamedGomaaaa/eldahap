import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/trade_model.dart';
import '../../../../../view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../../../../../view_model/utils/toast.dart';
import '../../../../components/live_text.dart';
import '../../order_details/order_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../model/metal_price_model.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';



class CreatOrder extends StatelessWidget {
  final TradeOrOrder order;
  final TradesCubit tradesCubit;
  final bool lastIndex;
  final String productTitle;
  const CreatOrder({
    super.key,
    required this.order,
    required this.tradesCubit,
    required this.lastIndex,
    required this.productTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivePriceCubit, LivePriceState>(
      builder: (context, liveState) {
        // ✅ العملة من order (fallback USD)
        final String currencyKey = (order.currency ?? 'USD').toUpperCase();
        MetalPrices? mp;
        if (liveState is LivePriceLive) {
          mp = liveState.metals[currencyKey];
        }
        // ✅ livePrice من السوكت
        final double livePrice = (mp?.buy ?? 0).toDouble()*order.unitGramWeight!;
        // لو عايز sell بدل buy:
        // final double livePrice = (mp?.sell ?? 0).toDouble();
        // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
        final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;
        return Container(
          padding: EdgeInsets.all(8.sp),
          child: Column(
            children: [
              Row(
                children: [
///////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ disable if no live
                  Expanded(
                    child: InkWell(
                      onTap: hasLive
                          ? () {
                        Navigation.push(
                          context,
                          OrderDetailsScreen(
                            order: order,
                            productTitle: productTitle,
                          ),
                        );
                      }
                          : null,
                      child: Opacity(
                        opacity: hasLive ? 1.0 : 0.35,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
///////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ quantity
                                    Material(
                                      color: AppColors.transparent,
                                      borderRadius: BorderRadius.circular(8.sp),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.sp,
                                          vertical: 5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(8.sp),
                                          border: Border.all(
                                            color: AppColors.blueColor,
                                            width: 1.sp,
                                          ),
                                        ),
                                        child: Text(
                                          '+${order.quantity}',
                                          style: const TextStyle(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.sp),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////// // ✅ @ openPrice
                                    Row(
                                      children: [
                                        const Text(
                                          '@',
                                          style: TextStyle(
                                            color: AppColors.greyText,
                                          ),
                                        ),
                                        SizedBox(width: 6.sp),
                                        Text(
                                          Methods. removeTrailingZeros(order.sellWhenPrice??0),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ live price الحقيقي من السوكت (وبيتحرك)
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 140.w,
                                      child: LivePriceText(
                                        price: livePrice,
                                        decimals: 2,
                                        fakeMinDelta: 0.01,
                                        fakeMaxDelta: 0.05,
                                        fakeTickEvery:
                                        const Duration(milliseconds: 900),
                                        neutralColor: Colors.transparent,
                                        upColor: Colors.transparent,
                                        downColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                        width: null,
                                        alignment: Alignment.centerLeft,
                                        style: const TextStyle(
                                          color: AppColors.greyText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.sp),
////////////////////////////////////////////////////////////////////////////////////////////////////////////// // ✅ Delete (Disabled لو مفيش live)
                  InkWell(
                    onTap: hasLive
                        ? () {
                      showDeleteOrderSheet(
                        context: context,
                        order: order,
                        tradesCubit: tradesCubit,
                      );
                    }
                        : null,
                    child: Opacity(
                      opacity: hasLive ? 1.0 : 0.35,
                      child: CircleAvatar(
                        backgroundColor: AppColors.red,
                        radius: 10.r,
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                color: lastIndex ? Colors.transparent : AppColors.yellow2,
              ),
            ],
          ),
        );
      },
    );
  }



  void showDeleteOrderSheet({
    required BuildContext context,
    required TradeOrOrder order,
    required TradesCubit tradesCubit,
  })
  {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Delete order?",
                style: TextStyle(
                  color: AppColors.yellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (order.status == "pending" && order.type == "order") {
                      tradesCubit.closeOrder(orderId: order.id);
                      Navigator.pop(context, true);
                    } else {
                      Toast.showMsg(msg: "this order is not pending");
                    }
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
                    "Delete",
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
//////////////////////////////////////////////////////////////////////////////////////////////// old
// class CreatOrder extends StatelessWidget {
//   final TradeOrOrder order;
//   final TradesCubit tradesCubit;
//   final bool lastIndex;
//   const CreatOrder({
//     super.key,
//     required this.order,
//     required this.tradesCubit,
//     required this.lastIndex,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(8.sp),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: InkWell(
//                   onTap: () {
//                     Navigation.push(
//                         context,
//                         OrderDetailsScreen(
//                           orderId: order.id!,
//                         ));
//                   },
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               //////////////////////////////////////////////////////////////////////////////////////////// quantity
//                               Material(
//                                 color: AppColors.transparent,
//                                 borderRadius: BorderRadius.circular(8.sp),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 14.sp,
//                                     vertical: 5.h,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(8.sp),
//                                     border: Border.all(
//                                       color: AppColors.blueColor,
//                                       width: 1.sp,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     '+${order.qty}',
//                                     style: const TextStyle(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 6.sp,
//                               ),
//
//                               //////////////////////////////////////////////////////////////////////////////////////////////////////// price 2
//                               Row(
//                                 children: [
//                                   const Text(
//                                     '@',
//                                     style: TextStyle(
//                                       color: AppColors.greyText,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 6.sp,
//                                   ),
//                                   Text(
//                                     '+${order.openPrice}',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headlineSmall
//                                         ?.copyWith(),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//
//                           //////////////////////////////////////////////////////////////////////////////////////////////  live price
//                           SizedBox(height: 5),
//                           Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 6.0),
//                             child: Text(
//                               " live price,",
//                               textAlign: TextAlign.start,
//                               style: TextStyle(
//                                 color: AppColors.greyText,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 10.sp,
//               ),
//               /////////////////////////////////////////////////////////////////////////////////////////// close
//               InkWell(
//                 onTap: () {
//                   showCloseTradeSheet(
//                     context,
//                     0.15,
//                     order,
//                     tradesCubit,
//                   );
//                 },
//                 child: CircleAvatar(
//                   backgroundColor: AppColors.red,
//                   radius: 10.r,
//                   child: Icon(
//                     Icons.close,
//                     size: 16.sp,
//                     color: AppColors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Divider(
//               color:
//                   lastIndex == true ? Colors.transparent : AppColors.yellow2),
//         ],
//       ),
//     );
//   }
//
//   void showCloseTradeSheet(
//     BuildContext context,
//     double profitOrLosePrice,
//     TradeOrOrder order,
//     TradesCubit tradesCubit,
//       // double livePrice,
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
//                 "Delete trade?",
//                 style: TextStyle(
//                   color: AppColors.yellow,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (order.status == "pending" && order.type == "order") {
//                       tradesCubit.closeOrder(
//                         orderId: order.id,
//                       );
//                     } else {
//                       Toast.showMsg(msg: "this order is not pending");
//                     }
//
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
//                     "Delete",
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
// }

//////////////////////////////////////////////////////////////////////////////////////////////////////  very old
// class CreatOrder extends StatelessWidget {
//   final TradeOrOrder order;
//   final TradesCubit tradesCubit;
//   final bool lastIndex;
//   final String productTitle;
//   const CreatOrder({
//     super.key,
//     required this.order,
//     required this.tradesCubit,
//     required this.lastIndex,
//     required this.productTitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LivePriceCubit, LivePriceState>(
//       builder: (context, liveState) {
//         // ✅ العملة من order (fallback USD)
//         final String currencyKey = (order.currency ?? 'USD').toUpperCase();
//         MetalPrices? mp;
//         if (liveState is LivePriceLive) {
//           mp = liveState.metals[currencyKey];
//         }
//         // ✅ livePrice من السوكت
//         final double livePrice = (mp?.buy ?? 0).toDouble()*order.unitGramWeight!;
//         // لو عايز sell بدل buy:
//         // final double livePrice = (mp?.sell ?? 0).toDouble();
//         // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
//         final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;
//         return Container(
//           padding: EdgeInsets.all(8.sp),
//           child: Column(
//             children: [
//               Row(
//                 children: [
// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ disable if no live
//                   Expanded(
//                     child: InkWell(
//                       onTap: hasLive
//                           ? () {
//                               Navigation.push(
//                                 context,
//                                 OrderDetailsScreen(
//                                   order: order,
//                                   productTitle: productTitle,
//                                 ),
//                               );
//                             }
//                           : null,
//                       child: Opacity(
//                         opacity: !hasLive ? 1.0 : 0.35,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ quantity
//                                     Material(
//                                       color: AppColors.transparent,
//                                       borderRadius: BorderRadius.circular(8.sp),
//                                       child: Container(
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 14.sp,
//                                           vertical: 5.h,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(8.sp),
//                                           border: Border.all(
//                                             color: AppColors.blueColor,
//                                             width: 1.sp,
//                                           ),
//                                         ),
//                                         child: Text(
//                                           '+${order.quantity}',
//                                           style: const TextStyle(
//                                             color: AppColors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 6.sp),
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////// // ✅ @ openPrice
//                                     Row(
//                                       children: [
//                                         const Text(
//                                           '@',
//                                           style: TextStyle(
//                                             color: AppColors.greyText,
//                                           ),
//                                         ),
//                                         SizedBox(width: 6.sp),
//                                         Text(
//                                             Methods. removeTrailingZeros(order.sellWhenPrice??0),
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .headlineSmall
//                                               ?.copyWith(),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 6.h),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ live price الحقيقي من السوكت (وبيتحرك)
//                                 Row(
//                                   children: [
//                                     // const Text(
//                                     //   "live price",
//                                     //   style:
//                                     //   TextStyle(color: AppColors.greyText),
//                                     // ),
//                                     // SizedBox(width: 6.w),
//                                     SizedBox(
//                                       width: 140.w,
//                                       child: LivePriceText(
//                                         price: livePrice,
//                                         decimals: 2,
//                                         fakeMinDelta: 0.01,
//                                         fakeMaxDelta: 0.05,
//                                         fakeTickEvery:
//                                             const Duration(milliseconds: 900),
//                                         neutralColor: Colors.transparent,
//                                         upColor: Colors.transparent,
//                                         downColor: Colors.transparent,
//                                         padding: EdgeInsets.zero,
//                                         width: null,
//                                         alignment: Alignment.centerLeft,
//                                         style: const TextStyle(
//                                           color: AppColors.greyText,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10.sp),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////// // ✅ Delete (Disabled لو مفيش live)
//                   InkWell(
//                     onTap: hasLive
//                         ? () {
//                             showDeleteOrderSheet(
//                               context: context,
//                               order: order,
//                               tradesCubit: tradesCubit,
//                             );
//                           }
//                         : null,
//                     child: Opacity(
//                       opacity: !hasLive ? 1.0 : 0.35,
//                       child: CircleAvatar(
//                         backgroundColor: AppColors.red,
//                         radius: 10.r,
//                         child: Icon(
//                           Icons.close,
//                           size: 16.sp,
//                           color: AppColors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Divider(
//                 color: lastIndex ? Colors.transparent : AppColors.yellow2,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//
//
//   void showDeleteOrderSheet({
//     required BuildContext context,
//     required TradeOrOrder order,
//     required TradesCubit tradesCubit,
//   })
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
//                 "Delete order?",
//                 style: TextStyle(
//                   color: AppColors.yellow,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (order.status == "pending" && order.type == "order") {
//                       tradesCubit.closeOrder(orderId: order.id);
//                       Navigator.pop(context, true);
//                     } else {
//                       Toast.showMsg(msg: "this order is not pending");
//                     }
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
//                     "Delete",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed:(){Navigator.pop(context, false);},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.yellow2,
//                     foregroundColor: AppColors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child:  const Text(
//                     "Cancel",
//                     style: TextStyle(fontWeight: FontWeight.bold),
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
// }















































// class CreatOrder extends StatelessWidget {
//   final TradeOrOrder order;
//   final TradesCubit tradesCubit;
//   final bool lastIndex;
//   const CreatOrder({
//     super.key,
//     required this.order,
//     required this.tradesCubit,
//     required this.lastIndex,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(8.sp),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: InkWell(
//                   onTap: () {
//                     Navigation.push(
//                         context,
//                         OrderDetailsScreen(
//                           orderId: order.id!,
//                         ));
//                   },
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               //////////////////////////////////////////////////////////////////////////////////////////// quantity
//                               Material(
//                                 color: AppColors.transparent,
//                                 borderRadius: BorderRadius.circular(8.sp),
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 14.sp,
//                                     vertical: 5.h,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(8.sp),
//                                     border: Border.all(
//                                       color: AppColors.blueColor,
//                                       width: 1.sp,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     '+${order.qty}',
//                                     style: const TextStyle(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 6.sp,
//                               ),
//
//                               //////////////////////////////////////////////////////////////////////////////////////////////////////// price 2
//                               Row(
//                                 children: [
//                                   const Text(
//                                     '@',
//                                     style: TextStyle(
//                                       color: AppColors.greyText,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 6.sp,
//                                   ),
//                                   Text(
//                                     '+${order.openPrice}',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headlineSmall
//                                         ?.copyWith(),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//
//                           //////////////////////////////////////////////////////////////////////////////////////////////  live price
//                           SizedBox(height: 5),
//                           Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 6.0),
//                             child: Text(
//                               " live price,",
//                               textAlign: TextAlign.start,
//                               style: TextStyle(
//                                 color: AppColors.greyText,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 10.sp,
//               ),
//               /////////////////////////////////////////////////////////////////////////////////////////// close
//               InkWell(
//                 onTap: () {
//                   showCloseTradeSheet(
//                     context,
//                     0.15,
//                     order,
//                     tradesCubit,
//                   );
//                 },
//                 child: CircleAvatar(
//                   backgroundColor: AppColors.red,
//                   radius: 10.r,
//                   child: Icon(
//                     Icons.close,
//                     size: 16.sp,
//                     color: AppColors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Divider(
//               color:
//                   lastIndex == true ? Colors.transparent : AppColors.yellow2),
//         ],
//       ),
//     );
//   }
//
//   void showCloseTradeSheet(
//     BuildContext context,
//     double profitOrLosePrice,
//     TradeOrOrder order,
//     TradesCubit tradesCubit,
//       // double livePrice,
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
//                 "Delete trade?",
//                 style: TextStyle(
//                   color: AppColors.yellow,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (order.status == "pending" && order.type == "order") {
//                       tradesCubit.closeOrder(
//                         orderId: order.id,
//                       );
//                     } else {
//                       Toast.showMsg(msg: "this order is not pending");
//                     }
//
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
//                     "Delete",
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
// }
