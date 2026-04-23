import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:official_gold/view/components/app_loader.dart';

import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../view_model/utils/colors.dart';
import '../../../../../../view_model/utils/common_method.dart';
import '../../../../static_pages/static_page_screen.dart';

// payment_method.dart - Model class
class PaymentMethod {
  final String id;
  final String name;
  final bool isEnabled;
  final String? accountNumber;
  final String? bankName;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.isEnabled,
    this.accountNumber,
    this.bankName,
  });
}

// Collected Data Model
class RechargeData {
  final String name;
  final String phone;
  final File image;
  final PaymentMethod paymentMethod;
  final double amount;

  RechargeData({
    required this.name,
    required this.phone,
    required this.image,
    required this.paymentMethod,
    required this.amount,
  });
}

class RechargeConfirmationScreen extends StatefulWidget {
  final double amount;
  final PaymentMethod paymentMethod;

  const RechargeConfirmationScreen({
    super.key,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  State<RechargeConfirmationScreen> createState() =>
      _RechargeConfirmationScreenState();
}

class _RechargeConfirmationScreenState
    extends State<RechargeConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _uploadedImage;


  final ApiService _apiService= ApiService();


  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _uploadedImage = File(pickedFile.path);
        });
      }
    }
  }

  bool _isEgyptianPhone(String phone) {
    final regex = RegExp(r'^01[0-9]{9}$');
    return regex.hasMatch(phone);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_uploadedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.upload_file_label.tr())),
        );
        return;
      }

      final rechargeData = RechargeData(
        name: _nameController.text,
        phone: _phoneController.text.trim(),
        image: _uploadedImage!,
        paymentMethod: widget.paymentMethod,
        amount: widget.amount,
      );

      debugPrint("Collected Data: ${rechargeData.name}, "
          "${rechargeData.phone}, ${rechargeData.image.path}");
      /*
          required String amount,
    required String paymentMethodId,
    required String payerName,
    required String payerPhone,
    required String note,
    required String receiptPath, // 🖼️ مسار الصورة
       */
      AppLoader.showLoader(context, ValueKey("makeDeposit"));
      await _apiService.makeDeposit(
        amount: rechargeData.amount.toString(),
        paymentMethodId: rechargeData.paymentMethod.id,
        payerName: rechargeData.name,
        payerPhone: rechargeData.phone,
        note: 'Recharge via ${rechargeData.paymentMethod.name}',
        receiptPath: rechargeData.image.path,
      );
      AppLoader.closeLoader(context, ValueKey("makeDeposit"));
      _showSuccessDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          LocaleKeys.success_title.tr(),
          style: const TextStyle(color: AppColors.textYellow),
        ),
        content: Text(
          LocaleKeys.success_message.tr(),
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              int count = 0;
              Navigator.of(context).popUntil((route) {
                count++;
                return count == 5; // يوقف عند ثاني Route
              });            },
            child: Text(
              LocaleKeys.ok_button.tr(),
              style: const TextStyle(color: AppColors.yellow),
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
      resizeToAvoidBottomInset: true, // let screen resize when keyboard appears
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.yellow),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          LocaleKeys.recharge_wallet_title.tr(),
          style: const TextStyle(
            color: AppColors.textYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
//////////////////////////////////////////////////////////////////////////// amount tiitle Info
                Text(
                  LocaleKeys.recharge_wallet_message.tr(
                    namedArgs: {
                      'amount':Methods.removeTrailingZeros(widget.amount)
                    },
                  ),
                  style: const TextStyle(
                    color: AppColors.textYellow,
                    fontSize: 14,
                  ),
                ),
//////////////////////////////////////////////////////////////////////////// via payment method
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(
                    "via ${widget.paymentMethod.name}",
                    style:  const TextStyle(
                      color: AppColors.green,
                      fontSize: 18,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

/////////////////////////////////////////////////////////////////////////////////////// Account Info
                Column(
crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
    Text(
    LocaleKeys.account_number.tr(),
    style: const TextStyle(
    color: AppColors.yellow, fontSize: 16,),
    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(16.sp),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        border: Border.all(color: AppColors.yellowBorder),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance,
                              color: AppColors.yellow, size: 24.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child:    Text(
                              "${widget.paymentMethod.accountNumber}",
                              style: const TextStyle(
                                  color: AppColors.greyText, fontSize: 14),
                            ),
                            // Text(
                            //   "${widget.paymentMethod.accountNumber}",
                            //   style: const TextStyle(
                            //       color: AppColors.greyText, fontSize: 14),
                            // ),
                          ),
                          IconButton(
                            onPressed: () {
                              _copyToClipboard(widget.paymentMethod.accountNumber ?? '');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                  Text(LocaleKeys.copied_account_number.tr()),
                                  backgroundColor: AppColors.yellow,
                                ),
                              );
                            },
                            icon:
                            const Icon(Icons.copy, color: AppColors.yellow),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
////////////////////////////////////////////////////////////////////////////// user Name
                Text(LocaleKeys.name_label.tr(),
                    style: const TextStyle(
                        color: AppColors.textYellow, fontSize: 14)),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.white),
                  validator: (value) {
                    if (value == null || value.trim().length < 4) {
                      return "Name must be more than 4 letters";
                    }
                    return null;
                  },
                  decoration: _inputDecoration(LocaleKeys.name_label.tr()),
                ),
                SizedBox(height: 16.h),

//////////////////////////////////////////////////////////////////// /// user Phone
                Text(LocaleKeys.phone_label.tr(),
                    style: const TextStyle(
                        color: AppColors.textYellow, fontSize: 14)),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: AppColors.white),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || !_isEgyptianPhone(value.trim())) {
                      return "Enter valid Egyptian phone number";
                    }
                    return null;
                  },
                  decoration: _inputDecoration(LocaleKeys.phone_label.tr()),
                ),
                SizedBox(height: 16.h),

/////////////////////////////////////////////////////////////////////////////////////////// Upload Image
                Text(LocaleKeys.upload_file_label.tr(),
                    style: const TextStyle(
                        color: AppColors.textYellow, fontSize: 14)),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.yellowBorder),
                      borderRadius: BorderRadius.circular(12.r),
                      color: AppColors.backgroundGrey,
                    ),
                    child: _uploadedImage == null
                        ? SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              color: AppColors.yellow, size: 32.sp),
                          SizedBox(height: 8.h),
                          Text(LocaleKeys.click_to_upload.tr(),
                              style: const TextStyle(
                                  color: AppColors.greyText,
                                  fontSize: 14)),
                        ],
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(_uploadedImage!,
                          fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

/////////////////////////////////////////////////////////////////////////////////////////////////// Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.send_button.tr(),
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
      ),
    );

  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.greyText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.yellowBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.yellowBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.yellow),
      ),
      filled: true,
      fillColor: AppColors.backgroundGrey,
    );
  }
}
