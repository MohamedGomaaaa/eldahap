import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/home/profile/wallet/recharge/recharge_payment_methods_screen.dart';
import 'package:official_gold/view_model/utils/common_method.dart';
import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../view_model/utils/colors.dart';
import '../../../../../../view_model/utils/navigation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../../../../../view_model/utils/validator.dart';

class RechargeAmountScreen extends StatefulWidget {
  const RechargeAmountScreen({super.key});

  @override
  State<RechargeAmountScreen> createState() => _RechargeAmountScreenState();
}

class _RechargeAmountScreenState extends State<RechargeAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final cubit = WalletCubit.get(context);
    cubit.depositEgpAmount = 0; // ✅ تصفير
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      // لو المحفظة مش متجابه بالفعل
      if (cubit.walletDollar == 0 && cubit.walletEgp == 0) {
        await cubit.getWallet();
      }
      await cubit.getExchangeRate();
    });
    _amountController.addListener(_onAmountChanged);
  }
  void _onAmountChanged() {
    WalletCubit.get(context).calculateDepositInEgp(_amountController.text);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());

      Navigation.push(
        context,
        RechargePaymentMethodsScreen(amount: amount),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.yellow),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          LocaleKeys.rechargeWallet.tr(),
          style: const TextStyle(
            color: AppColors.textYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.enterAmount.tr(),
                style: const TextStyle(
                  color: AppColors.textYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),
////////////////////////////////////////////////////////////////////////////////////////////////////////// Amount Input
              BlocBuilder<WalletCubit, WalletState>(
                buildWhen: (previous, current) {
                  return current is GetWalletSuccessState ||
                      current is GetWalletLoadingState ||
                      current is GetExchangeRateSuccessState ||
                      current is GetExchangeRateLoadingState ||
                      current is CalculateDepositAmountState;
                },
                builder: (context, state) {
                  final cubit = WalletCubit.get(context);

                  return TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "0.0",
                      hintStyle: const TextStyle(color: AppColors.yellow),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Dollar",
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      return Validator.validateDepositAmount(
                        value: value,
                        walletDollar: cubit.walletDollar,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 8.h),
////////////////////////////////////////////////////////////////////////////////////////////////////////// egy Amount Input
              BlocBuilder<WalletCubit, WalletState>(
                buildWhen: (previous, current) {
                  return current is CalculateDepositAmountState ||
                      current is GetExchangeRateLoadingState ||
                      current is GetExchangeRateSuccessState ||
                      current is GetExchangeRateErrorState;
                },
                builder: (context, state) {
                  final cubit = WalletCubit.get(context);

                  return _egpWidget(
                    egpAmount: cubit.depositEgpAmount,
                    isLoading: state is GetExchangeRateLoadingState,
                  );
                },
              ),
 ////////////////////////////////////////////////////////////////////////////////////////////////////////// Button
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.continueKey.tr(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _egpWidget({
    required num egpAmount,
    required bool isLoading,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  Methods.removeTrailingZeros(egpAmount),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          const Text(
            "Pounds",
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
































// class RechargeAmountScreen extends StatefulWidget {
//   const RechargeAmountScreen({super.key});
//
//   @override
//   State<RechargeAmountScreen> createState() => _RechargeAmountScreenState();
// }
//
// class _RechargeAmountScreenState extends State<RechargeAmountScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   void _onContinue() {
//     if (_formKey.currentState!.validate()) {
//       final amount = double.parse(_amountController.text);
//       // Navigation.push(
//       //   context,
//       //   RechargePaymentMethodsScreen(amount: amount),
//       // );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.yellow),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           LocaleKeys.rechargeWallet.tr(),
//           style: const TextStyle(
//             color: AppColors.textYellow,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: false,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.sp),
//         child: Form(
//           key: _formKey,
//           child: Column(
//
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
// //////////////////////////////////////////////////////////////////////////////////////////////////////// title
//               Text(
//                 LocaleKeys.enterAmount.tr(),
//                 style: const TextStyle(
//                   color: AppColors.textYellow,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               SizedBox(height: 20.h),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////// Deposut field widget
//               TextFormField(
//                 controller: _amountController,
//                 keyboardType:
//                     const TextInputType.numberWithOptions(decimal: true),
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//                 ],
//                 style: const TextStyle(color: AppColors.white),
//                 decoration: InputDecoration(
//                   border: InputBorder.none,
//                   hintText: "0.0",
//                   hintStyle: const TextStyle(color: AppColors.yellow),
//                   suffixIcon: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Text(
//                       "Dollar",
//                       // LocaleKeys.currency.tr(),
//                       style:
//                           TextStyle(color: AppColors.yellow, fontSize: 18.sp),
//                     ),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return LocaleKeys.amountRequired.tr();
//                   }
//                   final amount = double.tryParse(value);
//                   if (amount == null || amount <= 0) {
//                     return LocaleKeys.amountInvalid.tr();
//                   }
//                   return null;
//                 },
//               ),
//
//               SizedBox(height: 8.h),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////// egy widget
//               egyWidget(),
//               const Spacer(),
// /////////////////////////////////////////////////////////////////////////////////////////////////////////// button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _onContinue,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.yellow,
//                     padding: EdgeInsets.symmetric(vertical: 10.h),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                   ),
//                   child: Text(
//                     LocaleKeys.continueKey.tr(),
//                     style: const TextStyle(
//                       color: AppColors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 30,
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget egyWidget() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.yellow,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text("1213",
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               )),
//           Text(
//             "Pounnds",
//             style: TextStyle(
//               color: AppColors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
