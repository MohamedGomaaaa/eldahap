import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/home/profile/wallet/recharge/recharge_payment_methods_screen.dart';

import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../view_model/utils/colors.dart';
import '../../../../../../view_model/utils/navigation.dart';

class RechargeAmountScreen extends StatefulWidget {
  const RechargeAmountScreen({super.key});

  @override
  State<RechargeAmountScreen> createState() => _RechargeAmountScreenState();
}

class _RechargeAmountScreenState extends State<RechargeAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "0.0",
                        hintStyle: const TextStyle(color: AppColors.greyText),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top:10.0),
                          child: Text(
                            LocaleKeys.currency.tr(),
                            style:  TextStyle(color: AppColors.yellow,

                            fontSize: 18.sp
                            ),
                          ),
                        ),
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
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                LocaleKeys.paymentInCurrency.tr(),
                style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.continueKey.tr(),
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
