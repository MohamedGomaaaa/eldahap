import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/home/profile/wallet/recharge/recharge_confirmation_screen.dart';

import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../view_model/utils/colors.dart';
import '../../../../../../view_model/utils/navigation.dart';
import '../../../../static_pages/static_page_screen.dart';

class RechargePaymentMethodsScreen extends StatefulWidget {
  final double amount;

  const RechargePaymentMethodsScreen({
    super.key,
    required this.amount,
  });

  @override
  State<RechargePaymentMethodsScreen> createState() => _RechargePaymentMethodsScreenState();
}

class _RechargePaymentMethodsScreenState extends State<RechargePaymentMethodsScreen> {



  PaymentMethod? selectedMethod;
  bool isLoading = false;
  List<PaymentMethod> paymentMethods = [];

  void _onContinue() {
    if (selectedMethod != null) {
      _showPaymentModal();
    }
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentConfirmationSheet(
        amount: widget.amount,
        paymentMethod: selectedMethod!,
        onConfirm: () {
          Navigator.pop(context);
          Navigation.push(
            context,
            RechargeConfirmationScreen(
              amount: widget.amount,
              paymentMethod: selectedMethod!,
            ),
          );
        },
      ),
    );
  }

  final ApiService _apiService= ApiService();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        isLoading = true; // بدأ التحميل
      });

      _apiService.gePaymentMethodsDeposit().then((response) {
        if (response.success) {
          setState(() {
            paymentMethods = [];
            for (int i = 0; i < response.result.length; i++) {
              paymentMethods.add(
                PaymentMethod(
                  id: response.result[i].id.toString(),
                  name: response.result[i].name,
                  accountNumber: response.result[i].value,
                  isEnabled: true,
                ),
              );
            }
            isLoading = false; // خلص التحميل بنجاح
          });
        } else {
          setState(() {
            isLoading = false; // خلص التحميل لكن فيه خطأ
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message)),
          );
        }
      }).catchError((error) {
        setState(() {
          isLoading = false; // خلص التحميل مع Exception
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    });
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
          LocaleKeys.payment_methods_title.tr(),
          style: const TextStyle(
            color: AppColors.textYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.select_payment_method.tr(),
              style: const TextStyle(
                color: AppColors.textYellow,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20.h),
            isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...paymentMethods.map((method) => _buildPaymentMethodTile(method)),
                if (selectedMethod != null && selectedMethod!.isEnabled) ...[
                  SizedBox(height: 20.h),
                  _buildSelectedMethodDetails(),
                ],
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedMethod != null && selectedMethod!.isEnabled ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMethod != null && selectedMethod!.isEnabled
                      ? AppColors.yellow
                      : AppColors.greyText,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  LocaleKeys.continue_text.tr(),
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
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: method.isEnabled ? () {
          setState(() {
            selectedMethod = method;
          });
        } : null,
        child: Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedMethod?.id == method.id
                  ? AppColors.yellow
                  : AppColors.yellowBorder,
              width: selectedMethod?.id == method.id ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: AppColors.backgroundGrey,
          ),
          child: Row(
            children: [
              Radio<PaymentMethod>(
                value: method,
                groupValue: selectedMethod,
                onChanged: method.isEnabled ? (value) {
                  setState(() {
                    selectedMethod = value;
                  });
                } : null,
                activeColor: AppColors.yellow,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        color: method.isEnabled ? AppColors.yellow : AppColors.greyText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (method.accountNumber != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        "${LocaleKeys.account_number.tr()}: ${method.accountNumber}",
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12,
                        ),
                      ),
                      // Text(
                      //   method.name!,
                      //   style: const TextStyle(
                      //     color: AppColors.greyText,
                      //     fontSize: 12,
                      //   ),
                      // ),
                    ],
                  ],
                ),
              ),
              12.horizontalSpace,

              // if (method.name == 'instapay')
              //   Container(
              //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              //     decoration: BoxDecoration(
              //       color: Colors.purple,
              //       borderRadius: BorderRadius.circular(4.r),
              //     ),
              //     child: const Text(
              //       "IP",
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 12,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMethodDetails() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(0.1),
        border: Border.all(color: AppColors.yellow),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
      LocaleKeys.payment_summary.tr(
      namedArgs: {
      'amount': widget.amount.toStringAsFixed(2),
      },
      ),            style: const TextStyle(
              color: AppColors.textYellow,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentConfirmationSheet extends StatelessWidget {
  final double amount;
  final PaymentMethod paymentMethod;
  final VoidCallback onConfirm;

  const PaymentConfirmationSheet({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.greyText,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            LocaleKeys.payment_confirmation.tr(),
            style: TextStyle(
              color: AppColors.textYellow,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            // LocaleKeys.payment_deduction.tr(args: [amount.toStringAsFixed(2)]),


            LocaleKeys.payment_deduction.tr(
              namedArgs: {
                'amount': amount.toStringAsFixed(2),
              },
            ),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            // LocaleKeys.pay_via.tr(args: ),

            LocaleKeys.pay_via.tr(
              namedArgs: {
                'method': paymentMethod.name,
              },
            ),
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                LocaleKeys.proceed_payment.tr(),
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              LocaleKeys.cancel.tr(),
              style: const TextStyle(color: AppColors.greyText),
            ),
          ),
        ],
      ),
    );
  }
}
