import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/home/profile/wallet/withdraw/payment_method_page.dart';

import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../../../../../view_model/utils/colors.dart';
import '../../../../../../view_model/utils/validator.dart';

class WithdrawalAmountPage extends StatefulWidget {
  const WithdrawalAmountPage({Key? key}) : super(key: key);

  @override
  State<WithdrawalAmountPage> createState() => _WithdrawalAmountPageState();
}

class _WithdrawalAmountPageState extends State<WithdrawalAmountPage> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? errorMessage;

  num balanceDollar = 0;
  num balanceEgp = 0;

  @override
  void initState() {
    balanceDollar = WalletCubit.get(context).walletDollar;
    balanceEgp = WalletCubit.get(context).walletEgp;

    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      // Navigate to payment method page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodPage(
            selectedIndex:selectedIndex,
            amount: amount,
            currency: selectedIndex == 0 ? "Dollar" : "LE",
          ),
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
                borderRadius: BorderRadius.all(Radius.circular(12))),
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
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10, top: 15),
                child: const Text(
                  "Pick a wallet for withdrawal: USD or EGP?", // "ادخل المبلغ الذي تريد سحبه"
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // _buildBalanceCards
              _buildBalanceCards(),
              // Title
              Text(
                LocaleKeys.enter_amount_hint
                    .tr(), // "ادخل المبلغ الذي تريد سحبه"
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: "0.0",
                  hintStyle:
                      const TextStyle(color: AppColors.yellow, fontSize: 16),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      selectedIndex == 0 ? "Dollar" : "LE",
                      style:
                          TextStyle(color: AppColors.yellow, fontSize: 18.sp),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  final currency = selectedIndex == 0 ? "Dollar" : "LE";
                  final balance = selectedIndex == 0
                      ? balanceDollar // رصيد الدولار
                      : balanceEgp; // رصيد الجنيه

                  return Validator.validateWithdrawalAmount(
                    value: value,
                    walletBalance: balance,
                    currency: currency,
                  );
                },
                onChanged: (value) {
                  setState(() {
                    errorMessage = null;
                  });
                },
              ),

              const SizedBox(height: 16),

              const Spacer(),

              const Spacer(),

              // Continue Button
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(bottom: 40),
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
                      color: AppColors.white,
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

  int selectedIndex = 0;
  Widget _balanceCard({
    required IconData icon,
    required String title,
    required String balance,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // ✨ أنيميشن ناعمة
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : AppColors.backgroundGrey,
          border: Border.all(
            color: AppColors.yellowBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.yellow,
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.yellow,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              balance,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.yellow,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCards() {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final cubit = WalletCubit.get(context);

        return Container(
          margin: const EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: _balanceCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: LocaleKeys.dollarBalance.tr(),
                  balance: '${cubit.walletDollar}',
                  isSelected: selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _balanceCard(
                  icon: Icons.account_balance,
                  title: LocaleKeys.egyBalance.tr(),
                  balance: '${cubit.walletEgp}',
                  isSelected: selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
