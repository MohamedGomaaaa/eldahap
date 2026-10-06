// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:official_gold/view/screen/profile/wallet/recharge/recharge_amount_screen.dart';
// import 'package:official_gold/view/screen/profile/wallet/widgets/transaction_details_bottom_sheet.dart';
// import 'package:official_gold/view/screen/profile/wallet/withdraw/withdraw_alAmount_page.dart';
//
// import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';
// import '../../../../../model/user.dart';
// import '../../../../../services/translation/locale_keys.g.dart';
// import '../../../../../utils/app_color.dart';
// import '../../../../../utils/common_method.dart';
// import '../../../../../utils/text_style.dart';
// import '../../../../../utils/validator.dart';
// import '../../../../../view_model/cubit/home_cubit/home_cubit.dart';
// import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
// import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';
// import '../../../../../model/transaction_model.dart';
// import '../../../../../model/metal_price_model.dart';
// import '../../../../components/live_text.dart';
//
// class CreatWalletCard extends StatelessWidget {
//   final bool hasLive;
//   const CreatWalletCard({super.key, required this.hasLive});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<WalletCubit, WalletState>(
//       builder: (context, state) {
//         final cubit = WalletCubit.get(context);
//         final isLoading =
//             cubit.isWalletLoading || state is ConvertCurrencyLoadingState;
//
//         // ✅ استخدام القيمة الإجمالية التراكمية إذا كانت أكبر من صفر، وإلا استخدام قيمة المحفظة العادية
//
//         // final displayUsd = cubit.cachedUsdTotal + cubit.walletDollar+cubit.totalUsdOpenTrades;
//         // final displayEgp = cubit.cachedEgpTotal + cubit.walletEgp+cubit.totalEgpOpenTrades;
//         final displayUsd = cubit.equityUsd;
//         final displayEgp = cubit.equityEgp;
//
//         return Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: _balanceCard(
//                     icon: Icons.account_balance_wallet_outlined,
//                     title: LocaleKeys.dollarBalance.tr(),
//                     livePriceWidget: !hasLive
//                         ? const SizedBox()
//                         : cubit.usdTrades.isEmpty
//                             ? Text(
//                                 Methods.removeTrailingZeros(displayUsd),
//                                 style: WhiteTitle.display5(context),
//                               )
//                             : LivePriceText(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 4, vertical: 10),
//                                 fontSize: 14,
//                                 price: !hasLive
//                                     ? 0
//                                     : double.parse(displayUsd
//                                         .toString()), // ✅ يعرض الإجمالي التراكمي المحدث من التايمر بالدولار
//                                 decimals: 2,
//                                 fakeMinDelta: 0.01,
//                                 fakeMaxDelta: 0.05,
//                                 fakeTickEvery:
//                                     const Duration(milliseconds: 900),
//                               ),
//                     testWidget: !hasLive || cubit.usdTrades.isEmpty
//                         ? const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text(
//                               "    ",
//                             ),
//                           )
//                         : pnlWidget(
//                             totalPnl: cubit.cachedUsdTotal,
//                           ),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: _balanceCard(
//                     icon: Icons.account_balance,
//                     title: LocaleKeys.egyBalance.tr(),
//                     livePriceWidget: !hasLive
//                         ? const SizedBox()
//                         : cubit.egpTrades.isEmpty
//                             ? Text(
//                                 Methods.removeTrailingZeros(displayEgp),
//                                 style: WhiteTitle.display5(context),
//                               )
//                             : LivePriceText(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 4, vertical: 10),
//                                 fontSize: 14,
//                                 price: !hasLive
//                                     ? 0
//                                     : double.parse(displayEgp.toString()),
//                                 // ✅ يعرض الإجمالي التراكمي المحدث من التايمر بالجنيه
//                                 decimals: 2,
//                                 fakeMinDelta: 0.01,
//                                 fakeMaxDelta: 0.05,
//                                 fakeTickEvery:
//                                     const Duration(milliseconds: 900),
//                               ),
//                     testWidget: !hasLive || cubit.egpTrades.isEmpty
//                         ? const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text(
//                               "    ",
//                             ),
//                           )
//                         : pnlWidget(
//                             totalPnl: cubit.cachedEgpTotal,
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//
//             // Container(
//             //   // color: Colors.red,
//             //   margin: const EdgeInsets.only(top: 5),
//             //   child: Row(
//             //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //     children: [
//             //       Text(
//             //         "usd : ${cubit.walletDollar}",
//             //         style: const TextStyle(fontSize: 15),
//             //       ),
//             //       Text(
//             //         "egy : ${cubit.walletEgp}",
//             //         style: const TextStyle(fontSize: 15),
//             //       )
//             //     ],
//             //   ),
//             // ),
//
// //////////////////////////////////////////////////////////////////////////////////////// convert button
//             Container(
//               margin: const EdgeInsets.only(top: 20),
//               child: isLoading
//                   ? const CircularProgressIndicator(color: AppColors.yellow)
//                   : ElevatedButton.icon(
//                       onPressed: () async {
//                         final amount = await showModalBottomSheet<num>(
//                           backgroundColor: AppColors.background,
//                           context: context,
//                           isScrollControlled: true,
//                           builder: (context) => convertAmountSheet(
//                             context,
//                             cubit.walletDollar,
//                           ),
//                         );
//
//                         if (amount != null) {
//                           cubit.convertCurrency(amount: amount);
//                         }
//                       },
//                       icon: const Icon(Icons.currency_exchange,
//                           color: AppColors.white),
//                       label: const Text(
//                         "Convert to pounds",
//                         style: TextStyle(
//                             color: AppColors.white,
//                             fontWeight: FontWeight.w600),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//
//   Widget _balanceCard(
//       {required IconData icon,
//       required String title,
//       required Widget livePriceWidget,
//       required Widget testWidget,
//
//       required num totalPnl,
//
//       required BuildContext context
//
//       }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: EdgeInsets.all(16.sp),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundGrey,
//         border: Border.all(color: AppColors.yellowBorder),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Icon(icon, color: AppColors.yellow, size: 28.sp),
//           SizedBox(height: 8.h),
//           Text(
//             title,
//             style: const TextStyle(color: AppColors.greyText, fontSize: 14),
//           ),
//
//
// //////////////////////////////////////////////////////////////////////////////////// live price
//
//
//           SizedBox(height: 6.h),
//        !hasLive
//               ? const SizedBox()
//               : cubit.usdTrades.isEmpty
//               ? Text(
//             Methods.removeTrailingZeros(displayUsd),
//             style: WhiteTitle.display5(context),
//           )
//               : LivePriceText(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 4, vertical: 10),
//             fontSize: 14,
//             price: !hasLive
//                 ? 0
//                 : double.parse(displayUsd
//                 .toString()), // ✅ يعرض الإجمالي التراكمي المحدث من التايمر بالدولار
//             decimals: 2,
//             fakeMinDelta: 0.01,
//             fakeMaxDelta: 0.05,
//             fakeTickEvery:
//             const Duration(milliseconds: 900),
//           ),
//
// ////////////////////////////////////////////////////////////////////////////////////// pnl
//
//           !hasLive || cubit.egpTrades.isEmpty
//               ? const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text(
//               "    ",
//             ),
//           ):
//
//          Container(
//             margin: const EdgeInsets.only(top: 3),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     Methods.removeTrailingZeros(totalPnl),
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                     style: MainTitle.display5(context).copyWith(
//                         color:
//                         totalPnl > 0 ? AppColors.blueColor : AppColors.redColor,
//                         fontSize: 13),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget convertAmountSheet(BuildContext context, num walletDollar)
//   {
//     final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//     final TextEditingController controller = TextEditingController();
//
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         left: 16,
//         right: 16,
//         top: 20,
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 return Validator.validateAmount(
//                     value: value, walletDollar: walletDollar);
//               },
//               decoration: InputDecoration(
//                 hintText: "enter amount",
//                 suffixText: "USD",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
//               ],
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     final amount = num.parse(controller.text.trim());
//                     Navigator.pop(context, amount);
//                   }
//                 },
//                 child: const Text(
//                   "convert",
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
// }
