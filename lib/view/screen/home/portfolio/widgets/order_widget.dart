import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../model/new_trades.dart';
import '../../../../../view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../../view_model/utils/assets.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../../../../components/svg_widget.dart';
import '../../order_details/order_details_screen.dart';
import 'creat_order.dart';

class OrderWidget extends StatelessWidget {
  final String wholeOrderName;
  final String groupKey;

  const OrderWidget({
    super.key,
    required this.wholeOrderName,
    required this.groupKey,
  });

  @override
  Widget build(BuildContext context) {
    final tradesCubit = context.read<TradesCubit>();

    return BlocBuilder<TradesCubit, TradesState>(
      // ✅ خليه يسمع أي state يغير الداتا أو الفتح/القفل
      builder: (context, state) {
        final isOpen = tradesCubit.isOrderGroupExpanded(groupKey);
        /// ✅ نجيب orderList من الكيوبت كل مرة (ده اللي بيخلي الحذف يظهر فورًا)
        final group = tradesCubit.wholeOrders.firstWhere(
          (g) => (g.metal ?? '') == groupKey,
          orElse: () => Result(orders: []),
        );
        final orderList =
            group.orders ?? []; // ✅ هنا نفس موديل Result.orders (List<Trade>)
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
                        color: AppColors.black, //black
                        borderRadius: BorderRadius.circular(50.sp),
                        child: Row(
                          children: [
/////////////////////////////////////////////////////////////////////////////////////// image
                            Container(  padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 4),
                              decoration: const BoxDecoration(
                                // shape: BoxShape.circle,
                              ),
                              child:
                              SvgWidget(
                                assetName: AppAssets.gold3,
                                width: 20.sp,
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.all(6.0),
                              //   child: SvgWidget(
                              //     assetName: AppAssets.gold3,
                              //     width: 20.sp,
                              //   ),
                              // ),
                            ),
                            SizedBox(width: 6.sp),

//////////////////////////////////////////////////////////////////////////////////////// whole order type
                            Text(
                              wholeOrderName,
                              style: const TextStyle(
                                color: AppColors.white,
                              ),
                            ),
                            SizedBox(width: 6.w),

//////////////////////////////////////////////////////////////////////////////////////// open order button
                            IconButton(
                              onPressed: () {
                                tradesCubit.toggleOrderGroup(groupKey);
                              },
                              icon: AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: isOpen ? 0.5 : 0.0,
                                child: const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: AppColors.yellow2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(),
                    ],
                  ),
                ),
                isOpen == true
                    ? const Padding(
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
                      )
                    : const SizedBox(),
//////////////// ================= Body (Expandable List) =================
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isOpen
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    children: orderList.map((order) {
                      return CreatOrder(
                        trade: order,
                        onCloseTap: () {},
                      );
                    }).toList(),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////// old

//
// class OrderWidget extends StatelessWidget {
//   const OrderWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AppColors.backgroundGrey2,
//       borderRadius: BorderRadius.circular(12.sp),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12.sp),
//           border: Border.all(
//             color: AppColors.yellow2,
//             width: 1.sp,
//           ),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left:8.sp,right: 8.sp,top: 8.sp,bottom: 4.sp),
//               child: Row(
//                 children: [
//                   Material(
//                     color: AppColors.black,//black
//                     borderRadius: BorderRadius.circular(50.sp),
//                     child: Container(
//                       padding: EdgeInsets.all(0.sp),
//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               // color: AppColors.white,//black
//                               shape: BoxShape.circle,
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(6.0),
//                               child: SvgWidget(
//                                 assetName: AppAssets.gold3,
//                                 // color: AppColors.transparent,
//                                 width: 20.sp,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 6.sp,
//                           ),
//                           Text(
//                             LocaleKeys.gold.tr().toUpperCase(),
//                             style: const TextStyle(
//                               color: AppColors.white,
//                             ),
//                           ),
//                           SizedBox(
//                             width: 6.w,
//                           ),
//                           const Icon(
//                             Icons.arrow_forward_ios_rounded,
//                             color: AppColors.yellow2,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // const Expanded(
//                   //   child: Center(
//                   //     child: Text(
//                   //       '',
//                   //       textAlign: TextAlign.center,
//                   //       style: TextStyle(
//                   //         color: AppColors.greyText,
//                   //       ),
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 1.0),
//               child: const SizedBox(
//                 height: 1,
//                 child: Divider(
//                   thickness: 1,
//                   height: 1,   // removes extra vertical space
//                   indent: 0,   // removes left padding
//                   endIndent: 0, // removes right padding
//                   color: AppColors.yellow2,
//                 ),
//               ),
//             ),
//
//             InkWell(
//                 onTap: (){
//
//
//                   Navigation.push(context,  OrderDetailsPage());
//
//                 },
//                 child: DetailsWidget()),
//             // Padding(
//             //   padding: const EdgeInsets.symmetric(vertical: 1.0),
//             //   child: const SizedBox(
//             //     height: 1,
//             //     child: Divider(
//             //       thickness: 1,
//             //       height: 1,   // removes extra vertical space
//             //       indent: 0,   // removes left padding
//             //       endIndent: 0, // removes right padding
//             //       color: Colors.grey, // optional
//             //     ),
//             //   ),
//             // ),
//             //const DetailsWidget(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DetailsWidget extends StatelessWidget {
//   const DetailsWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(8.sp),
//       child: Column(
//         children: [
//           Row(
//             children: [
//
//               const Align(
//                 alignment: AlignmentDirectional.centerStart,
//                 child: Text(
//                   '2.5494',
//                   textAlign: TextAlign.start,
//                   style: TextStyle(
//                     color: AppColors.greyText,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 6.h,
//               ),
//               Material(
//                 color: AppColors.transparent,
//                 borderRadius: BorderRadius.circular(8.sp),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 14.sp,
//                     vertical: 5.h,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.sp),
//                     border: Border.all(
//                       color: AppColors.blueColor,
//                       width: 1.sp,
//                     ),
//                   ),
//                   child: const Text(
//                     '+1',
//                     style: TextStyle(
//                       color: AppColors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 6.sp,
//               ),
//               Expanded(
//                 child: Row(
//                   children: [
//                     const Text(
//                       '@',
//                       style: TextStyle(
//                         color: AppColors.greyText,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 6.sp,
//                     ),
//                     Text(
//                       '+14.854',
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineSmall
//                           ?.copyWith(),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: 6.sp,
//               ),
//               CircleAvatar(
//                 backgroundColor: AppColors.greyText,
//                 radius: 10.r,
//                 child: Icon(
//                   Icons.close,
//                   size: 16.sp,
//                   color: AppColors.grey,
//                 ),
//               ),
//             ],
//           ),
//
//         ],
//       ),
//     );
//   }
// }
