// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:official_gold/view/components/gradient_widget.dart';
// import 'package:official_gold/view/components/app_bar_widget.dart';
// import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';
// import '../../../../../l10n/locale_keys.g.dart';
// import '../../../../../view_model/utils/colors.dart';
//
// class WithdrawScreen extends StatelessWidget {
//   const WithdrawScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GradientWidget(
//         child: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView(
//                   padding: EdgeInsets.all(12.sp),
//                   children: [
//                     const AppBarCustom(),
//                     SizedBox(
//                       height: 12.h,
//                     ),
//                     Text(
//                       'Withdraw',
//                       textAlign: TextAlign.center,
//                       style:
//                           Theme.of(context).textTheme.headlineMedium?.copyWith(
//                               // color: AppColors.textYellow,
//                               ),
//                     ),
//                     SizedBox(
//                       height: 6.h,
//                     ),
//                     const Divider(
//                       color: AppColors.textYellow,
//                     ),
//                     SizedBox(
//                       height: 6.h,
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(12.sp),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppColors.yellowBorder,
//                           width: 0.5.w,
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           BlocBuilder<WalletCubit, WalletState>(
//                             buildWhen: (previous, current) {
//                               return current is GetWalletSuccessState ||
//                                   current is GetWalletLoadingState ||
//                                   current is GetWalletErrorState;
//                             },
//                             builder: (context, state) {
//                               return Text(
//                                 '\$ ${WalletCubit.get(context).walletDollar}',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .headlineLarge
//                                     ?.copyWith(
//                                       color: AppColors.textYellow,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               );
//                             },
//                           ),
//                           SizedBox(
//                             height: 6.h,
//                           ),
//                           Text(
//                             LocaleKeys.currentBalance.tr(),
//                             style:
//                                 Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                       color: AppColors.textYellow,
//                                     ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: 12.h,
//                     ),
//                     TextFormField(
//                       controller: WalletCubit.get(context).quantityController,
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                       decoration: InputDecoration(
//                         hintText: LocaleKeys.quantity.tr(),
//                         hintStyle:
//                             Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                   color: AppColors.white,
//                                 ),
//                       ),
//                       keyboardType:
//                           const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
//                       ],
//                       validator: (value) {
//                         if ((value ?? '').isEmpty) {
//                           return LocaleKeys.quantityError.tr();
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(
//                       height: 12.h,
//                     ),
//                     DropdownButtonFormField(
//                       items: const [],
//                       onChanged: (value) {},
//                       hint: Text(
//                         LocaleKeys.selectionOfMethods.tr(),
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                               color: AppColors.white,
//                             ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 12.h,
//                     ),
//                     Text(
//                       LocaleKeys.verifyTheRequiredInformation.tr(),
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: AppColors.red,
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 12.h,
//               ),
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 12.sp),
//                 width: double.infinity,
//                 height: 40.h,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     WalletCubit.get(context).withdraw().then((value) => Navigator.pop(context));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.lightPurple,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                   ),
//                   child: Text(
//                     LocaleKeys.withdrawNow.tr(),
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           color: AppColors.white,
//                         ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
