

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../l10n/locale_keys.g.dart';
import '../../../../../../view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../../../../../view_model/utils/colors.dart';
import '../../../../../../view_model/utils/common_method.dart';
import '../../../../static_pages/models/payment_methods_model.dart';
import '../../../../static_pages/static_page_screen.dart';
class BankDetailsPage extends StatefulWidget {
  final double amount;
  final PaymentMethod paymentMethod;
  final int selectedIndex;
  final String currency;
  const BankDetailsPage({
    super.key,
    required this.amount,
    required this.paymentMethod, required this.selectedIndex, required this.currency,
  });

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}



class _BankDetailsPageState extends State<BankDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _binanceIdController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _binanceIdController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return (LocaleKeys.name_required.tr());
    }
    if (value.trim().length <= 4) {
      return (LocaleKeys.name_min_length.tr());
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return (LocaleKeys.phone_required.tr());
    }

    // Egyptian phone number validation
    // Should start with 01 and be 11 digits total
    final RegExp egyptianPhoneRegex = RegExp(r'^01[0125][0-9]{8}$');
    if (!egyptianPhoneRegex.hasMatch(value)) {
      return (LocaleKeys.phone_invalid.tr());
    }

    return null;
  }

  String? _validateBankName(String? value) {
    // if (value == null || value.isEmpty) {
    //   return (LocaleKeys.bank_name_required.tr());
    // }
    return null;
  }

  String? _validateBankAccount(String? value) {
    // if (value == null || value.isEmpty) {
    //   return (LocaleKeys.bank_account_required.tr());
    // }
    // // Additional validation for bank account number length
    // if (value.length < 10) {
    //   return 'رقم الحساب يجب أن يكون 10 أرقام على الأقل';
    // }
    return null;
  }

  Future<void> _onSendPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        // Process the withdrawal request
        await _processWithdrawalRequest();

        if (mounted) {
          _showSuccessDialog();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  final ApiService _apiService= ApiService();





  Future<void> _processWithdrawalRequest() async {
    // Here you would typically make an API call to process the withdrawal
    // For now, we'll simulate the process









    await _apiService.makeWithdraw(
      amount: widget.amount.toString(),
      bankName: _bankNameController.text.trim(),
      bankAccount: _bankAccountController.text.trim(),
      paymentMethodId: widget.paymentMethod.id.toString(),
      accountName: _nameController.text,
      accountPhone:  _phoneController.text.trim(),
      address: _addressController.text ?? '',
      binanceId: _binanceIdController.text ?? '',
      selectedIndex:widget.selectedIndex,
      note: '',
    );
    // Simulate potential API errors
    // Uncomment the line below to test error handling
    // throw Exception('Network error occurred');
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => WillPopScope(
        onWillPop: () async => true,
        child: AlertDialog(
          backgroundColor: AppColors.backgroundGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.green,
                size: 24,
              ),
              8.horizontalSpace,
              Text(
                (LocaleKeys.success_title.tr()),
                style: const TextStyle(
                  color: AppColors.yellow,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(

             '${(LocaleKeys.success_message.tr())}\n${LocaleKeys.amount.tr()} ${Methods.removeTrailingZeros(widget.amount)} ${widget.currency}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('${(LocaleKeys.name.tr())}:', _nameController.text),
                      _buildInfoRow('${(LocaleKeys.phone.tr())}:', _phoneController.text),
                      _buildInfoRow('${(LocaleKeys.bank_account.tr())}:', _bankNameController.text),
                      _buildInfoRow((LocaleKeys.account_number.tr()), _bankAccountController.text),
                      _addressController.text.isNotEmpty?  _buildInfoRow((LocaleKeys.address.tr()), _addressController.text):const SizedBox.shrink(),
                      _binanceIdController.text.isNotEmpty?_buildInfoRow((LocaleKeys.binanceId.tr()), _binanceIdController.text):const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  int count = 0;
                  Navigator.of(context).popUntil((route) {
                    count++;
                    return count == 4; // يوقف عند ثاني Route
                  });


                  WalletCubit.get(context).getWallet();


                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  (LocaleKeys.ok_button.tr()),
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

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error,
              color: AppColors.red,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'خطأ',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'حدث خطأ أثناء إرسال الطلب: $error',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'موافق',
              style: TextStyle(color: AppColors.yellow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 12,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.yellow,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? AppColors.white : AppColors.greyText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.greyText,
              fontSize: 16,
            ),
            contentPadding: const EdgeInsets.all(16),
            border: InputBorder.none,
            prefixIcon: prefixIcon,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 24,
            ),
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellow.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance,
                color: AppColors.yellow,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Withdraw via ${widget.paymentMethod.name}",
                  // (LocaleKeys.withdraw_via_bank.tr()),
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  '${LocaleKeys.amount.tr()}:',
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${Methods.removeTrailingZeros(widget.amount)} ${widget.currency}',
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
          LocaleKeys.withdraw_via_bank.tr(),
          style: const TextStyle(
            color: AppColors.textYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),




      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                10.verticalSpace,
/////////////////////////////////////////////////////////////////////////////// /// Header with withdrawal info
                _buildHeader(),

////////////////////////////////////////////////////////////////////////////////////////// Name Field
                _buildTextField(
                  controller: _nameController,
                  label: (LocaleKeys.name_label.tr()),
                  hint: (LocaleKeys.name_hint.tr()),
                  validator: _validateName,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),

////////////////////////////////////////////////////////////////////////////////////////// Phone Field
                _buildTextField(
                  controller: _phoneController,
                  label: (LocaleKeys.phone_label.tr()),
                  hint: (LocaleKeys.phone_hint.tr()),
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      // Auto-format Egyptian phone number
                      if (newValue.text.isNotEmpty && !newValue.text.startsWith('01')) {
                        if (newValue.text.startsWith('1')) {
                          return TextEditingValue(
                            text: '0${newValue.text}',
                            selection: TextSelection.collapsed(offset: newValue.text.length + 1),
                          );
                        }
                      }
                      return newValue;
                    }),
                  ],
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),

/////////////////////////////////////////////////////////////////////////////////////////// Bank Name Field
                _buildTextField(
                  controller: _bankNameController,
                  label: (LocaleKeys.bank_name_label.tr()),
                  hint: (LocaleKeys.bank_name_hint.tr()),
                  validator: _validateBankName,// انا موقفها جمعه
                  prefixIcon: const Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),

/////////////////////////////////////////////////////////////////////////////////////// /// Bank Account Field
                _buildTextField(
                  controller: _bankAccountController,
                  label: (LocaleKeys.bank_account_label.tr()),
                  hint: (LocaleKeys.bank_account_hint.tr()),
                   validator: _validateBankAccount, // انا موقفها جمعه
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(20),
                  ],
                  prefixIcon: const Icon(
                    Icons.credit_card_outlined,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),
/////////////////////////////////////////////////////////////////////////////////////////////// // address
                _buildTextField(
                  controller: _addressController,
                  label: (LocaleKeys.address2.tr()),
                  hint: (LocaleKeys.address2.tr()),
                  validator: (String? val){
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.add_business_sharp,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                  enabled: !_isLoading,
                ),


                const SizedBox(height: 24),
/////////////////////////////////////////////////////////////////////////////////////////// // binanceId
                _buildTextField(
                  controller: _binanceIdController,
                  label: (LocaleKeys.binanceId.tr()),
                  hint: (LocaleKeys.binanceId.tr()),
                  validator: (String? val){
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.add_chart_sharp,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 40),
/////////////////////////////////////////////////////////////////////////////////////////// /// Send Button
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSendPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading
                          ? AppColors.lightGrey
                          : AppColors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ?  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          LocaleKeys.sendProcess.tr(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      (LocaleKeys.send_button.tr()),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

/////////////////////////////////////////////////////////////////////////////////////////// //// Additional info
                Container(
                  margin: EdgeInsets.only(top: 10.h,bottom: 50.h),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGrey2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightGrey.withOpacity(0.3)),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.yellow,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'معلومات مهمة',
                            style: TextStyle(
                              color: AppColors.yellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• سيتم معالجة طلب السحب خلال 3-5 أيام عمل\n'
                            '• تأكد من صحة بيانات الحساب البنكي\n'
                            '• سيتم إشعارك عند اكتمال العملية',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}