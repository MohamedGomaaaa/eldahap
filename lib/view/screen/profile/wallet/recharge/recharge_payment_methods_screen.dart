import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:official_gold/view/screen/profile/wallet/recharge/payment_confirmation_sheet.dart';
import 'package:official_gold/view/screen/profile/wallet/recharge/recharge_confirmation_screen.dart';


import '../../../../../model/payment_data.dart';
import '../../../../../services/translation/locale_keys.g.dart';
import '../../../../../utils/app_color.dart';
import '../../../../../utils/common_method.dart';
import '../../../../../utils/navigation.dart';
import '../../../static_pages/static_page_screen.dart';

class RechargePaymentMethodsScreen extends StatefulWidget {
  final double amount;

  const RechargePaymentMethodsScreen({
    super.key,
    required this.amount,
  });

  @override
  State<RechargePaymentMethodsScreen> createState() =>
      _RechargePaymentMethodsScreenState();
}

class _RechargePaymentMethodsScreenState
    extends State<RechargePaymentMethodsScreen> {

  bool isLoading = false;

  PaymentData? selectedPaymentData;
  List<PaymentData> paymentData = [];

  void _onContinue() {
    if (selectedPaymentData != null) {
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
        paymentData: selectedPaymentData!,
        onConfirm: () {
          Navigator.pop(context);
          Navigation.push(
            context,
            RechargeConfirmationScreen(
              amount: widget.amount,
              paymentData: selectedPaymentData!,
            ),
          );
        },
      ),
    );
  }

  final ApiService _apiService = ApiService();

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
            paymentData = [];
            for (int i = 0; i < response.result.length; i++) {
              paymentData.add(
                PaymentData(
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
      })
          .catchError((error) {
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
                    child: CircularProgressIndicator(
                      color: AppColors.yellow,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...paymentData
                          .map((method) => _buildPaymentMethodTile(method)),
                      if (selectedPaymentData != null &&
                          selectedPaymentData!.isEnabled) ...[
                        SizedBox(height: 20.h),
                        _buildSelectedMethodDetails(),
                      ],
                    ],
                  ),
            const Spacer(),
///////////////////////////////////////////////////////////////////////////////////////// continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedPaymentData != null &&
                        selectedPaymentData!.isEnabled
                    ? _onContinue
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPaymentData != null &&
                          selectedPaymentData!.isEnabled
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
    );
  }

/////////////////////////////////////////////////////////////////////// payment method widget
  Widget _buildPaymentMethodTile(PaymentData method) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: method.isEnabled
            ? () {
                setState(() {
                  selectedPaymentData = method;
                });
              }
            : null,
        child: Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedPaymentData?.id == method.id
                  ? AppColors.yellow
                  : AppColors.yellowBorder,
              width: selectedPaymentData?.id == method.id ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: AppColors.backgroundGrey,
          ),
          child: Row(
            children: [
              Radio<PaymentData>(
                value: method,
                groupValue: selectedPaymentData,
                onChanged: method.isEnabled
                    ? (value) {
                        setState(() {
                          selectedPaymentData = value;
                        });
                      }
                    : null,
                activeColor: AppColors.yellow,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        color: method.isEnabled
                            ? AppColors.yellow
                            : AppColors.greyText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // if (method.accountNumber != null) ...[
                    //   SizedBox(height: 4.h),
                    //   Text(
                    //     "${LocaleKeys.account_number.tr()}: ${method.accountNumber}",
                    //     style: const TextStyle(
                    //       color: AppColors.greyText,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
              12.horizontalSpace,
            ],
          ),
        ),
      ),
    );
  }

/////////////////////////////////////////////////////////////////////// amount title u will pay
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
              namedArgs: {'amount': Methods.removeTrailingZeros(widget.amount)},
            ),
            style: const TextStyle(
              color: AppColors.textYellow,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
