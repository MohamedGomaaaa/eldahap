import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/home/profile/wallet/withdraw/payment_method_page.dart';

import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../../../../../view_model/utils/colors.dart';

class WithdrawalAmountPage extends StatefulWidget {
  const WithdrawalAmountPage({Key? key}) : super(key: key);

  @override
  State<WithdrawalAmountPage> createState() => _WithdrawalAmountPageState();
}

class _WithdrawalAmountPageState extends State<WithdrawalAmountPage> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double walletBalance = 0.0; // This should come from your state management
  String? errorMessage;

  @override
  void initState() {
    walletBalance = WalletCubit.get(context).wallet.toDouble();

    super.initState();
  }
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.amount_required.tr(); // "يجب كتابة المبلغ"
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return LocaleKeys.amount_greater_than_zero.tr(); // "المبلغ يجب أن يكون أكبر من صفر"
    }

    if (amount > walletBalance) {
      return LocaleKeys.insufficient_balance.tr(); // "الرصيد غير كافي"
    }

    return null;
  }

  void _onContinuePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      // Navigate to payment method page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodPage(amount: amount),
        ),
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
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.black,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocaleKeys.withdrawal_title.tr(), // "سحب"
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: AppColors.yellow,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.yellow,
                  size: 30,
                ),
                8.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      '${LocaleKeys.wallet_balance.tr()}', // "رصيد المحفظة"
                      style: const TextStyle(
                        color: AppColors.greyText,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${walletBalance.toStringAsFixed(1)} ${LocaleKeys.currency.tr()}', // "رصيد المحفظة"
                      style: const TextStyle(
                        color: AppColors.yellow2,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Title
              Text(
                LocaleKeys.enter_amount_hint.tr(), // "ادخل المبلغ الذي تريد سحبه"
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: AppColors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              12.verticalSpace,
              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "0.0",
                  hintStyle: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(top:10.0),
                    child: Text(
                      LocaleKeys.currency.tr(),
                      style:  TextStyle(color: AppColors.yellow,

                          fontSize: 18.sp
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,


                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.amountRequired.tr();
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return LocaleKeys.amountInvalid.tr();
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    errorMessage = null;
                  });
                },
              ),


              const SizedBox(height: 16),

              // Pay with wallet text
              Text(
                LocaleKeys.pay_with_wallet.tr(), // "الدفع بواسطة جنيه"
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 14,
                ),
              ),

              const Spacer(),



              const Spacer(),

              // Continue Button
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: _onContinuePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    LocaleKeys.continueKey.tr(), // "استمرار"
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}