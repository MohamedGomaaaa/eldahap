import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../../../../model/payment_methods_model.dart';

import '../../../../../services/translation/locale_keys.g.dart';
import '../../../../../utils/app_color.dart';
import '../../../../../utils/common_method.dart';
import '../../../static_pages/static_page_screen.dart';
import 'bank_details_page.dart';

class PaymentMethodPage extends StatefulWidget {
  final double amount;
  final String currency;
  final int selectedIndex;
  const PaymentMethodPage({
    Key? key,
    required this.amount,
    required this.currency,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  List<PaymentMethod> paymentMethods = [];

  PaymentMethod? selectedMethod;

  void _onContinuePressed() {
    if (selectedMethod != null) {
      // Navigate to bank details page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BankDetailsPage(
            currency: widget.currency,
            selectedIndex: widget.selectedIndex,
            amount: widget.amount,
            paymentMethod: selectedMethod!,
          ),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.choose_payment_method.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        isLoading = true; // بدأ التحميل
      });

      _apiService.gePaymentMethodsWithdraw().then((response) {
        if (response.success) {
          setState(() {
            paymentMethods = [];
            for (int i = 0; i < response.result.length; i++) {
              paymentMethods.add(
                PaymentMethod(
                  id: response.result[i].id,
                  name: response.result[i].name,
                  value: '',
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

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedMethod = method;
          });
        },
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
                onChanged: (value) {
                  setState(() {
                    selectedMethod = value;
                  });
                },
                activeColor: AppColors.yellow,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
            "you will pay ${Methods.removeTrailingZeros(widget.amount)} ${widget.currency} for successful payment",
            style: const TextStyle(
              color: AppColors.textYellow,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
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
          LocaleKeys.payment_methods.tr(),
          style: const TextStyle(
            color: AppColors.textYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 40),
            8.verticalSpace,
////////////////////////////////////////////////////////////////////////////////////// // Title
            Text(
              LocaleKeys.choose_payment_method.tr(), // "اختار طريقة الدفع"
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            16.verticalSpace,
            // Payment Method Option

            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                       backgroundColor:  AppColors.yellow!
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...paymentMethods
                          .map((method) => _buildPaymentMethodTile(method)),
                      if (selectedMethod != null) ...[
                        SizedBox(height: 20.h),
                        _buildSelectedMethodDetails(),
                      ],
                    ],
                  ),

            const Spacer(),

            const Spacer(),

//////////////////////////////////////////////////////////////////////////////////////////////////////////// Continue Button
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              width: double.infinity,
              height: 50,
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
    );
  }
}























