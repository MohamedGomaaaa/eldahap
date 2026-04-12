// // ===============================================
// // PAGE 1: WITHDRAWAL AMOUNT PAGE
// // ===============================================
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../../../../../../l10n/locale_keys.g.dart';
// import '../../../../../../view_model/cubit/wallet_cubit/wallet_cubit.dart';
// import '../../../../../../view_model/utils/colors.dart';
//
// class WithdrawalAmountPage extends StatefulWidget {
//   const WithdrawalAmountPage({Key? key}) : super(key: key);
//
//   @override
//   State<WithdrawalAmountPage> createState() => _WithdrawalAmountPageState();
// }
//
// class _WithdrawalAmountPageState extends State<WithdrawalAmountPage> {
//   final TextEditingController _amountController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   double walletBalance = 150.0; // This should come from your state management
//   String? errorMessage;
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     walletBalance = WalletCubit.get(context).wallet.toDouble();
//     print("Wallet Balance: $walletBalance");
//     super.initState();
//   }
//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   String? _validateAmount(String? value) {
//     if (value == null || value.isEmpty) {
//       return LocaleKeys.amount_required.tr(); // "يجب كتابة المبلغ"
//     }
//
//     final amount = double.tryParse(value);
//     if (amount == null || amount <= 0) {
//       return LocaleKeys.amount_greater_than_zero.tr(); // "المبلغ يجب أن يكون أكبر من صفر"
//     }
//
//     if (amount > walletBalance) {
//       return LocaleKeys.insufficient_balance.tr(); // "الرصيد غير كافي"
//     }
//
//     return null;
//   }
//
//   void _onContinuePressed() {
//     if (_formKey.currentState?.validate() ?? false) {
//       final amount = double.parse(_amountController.text);
//       // Navigate to payment method page
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentMethodPage(amount: amount),
//         ),
//       );
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
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: AppColors.yellow,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.arrow_back,
//               color: AppColors.black,
//               size: 20,
//             ),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           LocaleKeys.withdrawal_title.tr(), // "سحب"
//           style: const TextStyle(
//             color: AppColors.yellow,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Row(
//               children: [
//                 Text(
//                   '${LocaleKeys.wallet_balance.tr()}: ${walletBalance.toStringAsFixed(1)}', // "رصيد المحفظة"
//                   style: const TextStyle(
//                     color: AppColors.greyText,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 const Icon(
//                   Icons.account_balance_wallet,
//                   color: AppColors.yellow,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 40),
//
//               // Title
//               Text(
//                 LocaleKeys.enter_amount_hint.tr(), // "ادخل المبلغ الذي تريد سحبه"
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: AppColors.yellow,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // Amount Input
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppColors.yellow),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextFormField(
//                   controller: _amountController,
//                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//                   ],
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 16,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: LocaleKeys.pound_currency.tr(), // "جنيه"
//                     hintStyle: const TextStyle(
//                       color: AppColors.greyText,
//                       fontSize: 16,
//                     ),
//                     contentPadding: const EdgeInsets.all(16),
//                     border: InputBorder.none,
//                     suffixText: '0.0',
//                     suffixStyle: const TextStyle(
//                       color: AppColors.greyText,
//                       fontSize: 16,
//                     ),
//                   ),
//                   validator: _validateAmount,
//                   onChanged: (value) {
//                     setState(() {
//                       errorMessage = null;
//                     });
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Pay with wallet text
//               Text(
//                 LocaleKeys.pay_with_wallet.tr(), // "الدفع بواسطة جنيه"
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: AppColors.greyText,
//                   fontSize: 14,
//                 ),
//               ),
//
//               const Spacer(),
//
//               // Video play button (placeholder)
//               Center(
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: const BoxDecoration(
//                     color: AppColors.grey,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.play_arrow,
//                     color: AppColors.white,
//                     size: 40,
//                   ),
//                 ),
//               ),
//
//               const Spacer(),
//
//               // Continue Button
//               Container(
//                 width: double.infinity,
//                 height: 50,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 child: ElevatedButton(
//                   onPressed: _onContinuePressed,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.yellow,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     LocaleKeys.continueKey.tr(), // "استمرار"
//                     style: const TextStyle(
//                       color: AppColors.black,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
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
//
// // ===============================================
// // PAGE 2: PAYMENT METHOD PAGE
// // ===============================================
//
// class PaymentMethodPage extends StatefulWidget {
//   final double amount;
//
//   const PaymentMethodPage({
//     Key? key,
//     required this.amount,
//   }) : super(key: key);
//
//   @override
//   State<PaymentMethodPage> createState() => _PaymentMethodPageState();
// }
//
// class _PaymentMethodPageState extends State<PaymentMethodPage> {
//   String? selectedMethod;
//
//   void _onContinuePressed() {
//     if (selectedMethod != null) {
//       // Navigate to bank details page
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BankDetailsPage(
//             amount: widget.amount,
//             paymentMethod: selectedMethod!,
//           ),
//         ),
//       );
//     } else {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(LocaleKeys.choose_payment_method.tr()),
//           backgroundColor: AppColors.red,
//         ),
//       );
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
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: AppColors.yellow,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.arrow_back,
//               color: AppColors.black,
//               size: 20,
//             ),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           LocaleKeys.payment_methods.tr(), // "طرق الدفع"
//           style: const TextStyle(
//             color: AppColors.yellow,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 40),
//
//             // Title
//             Text(
//               LocaleKeys.choose_payment_method.tr(), // "اختار طريقة الدفع"
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: AppColors.yellow,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//
//             const SizedBox(height: 40),
//
//             // Payment Method Option
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedMethod = 'bank_account';
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: selectedMethod == 'bank_account'
//                         ? AppColors.yellow
//                         : AppColors.lightGrey,
//                     width: selectedMethod == 'bank_account' ? 2 : 1,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   color: selectedMethod == 'bank_account'
//                       ? AppColors.yellow.withOpacity(0.1)
//                       : AppColors.transparent,
//                 ),
//                 child: Row(
//                   children: [
//                     // Radio Button
//                     Container(
//                       width: 24,
//                       height: 24,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: selectedMethod == 'bank_account'
//                               ? AppColors.yellow
//                               : AppColors.greyText,
//                           width: 2,
//                         ),
//                       ),
//                       child: selectedMethod == 'bank_account'
//                           ? const Center(
//                         child: CircleAvatar(
//                           radius: 6,
//                           backgroundColor: AppColors.yellow,
//                         ),
//                       )
//                           : null,
//                     ),
//
//                     const SizedBox(width: 16),
//
//                     // Content
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             LocaleKeys.bank_account.tr(), // "Bank Account"
//                             style: const TextStyle(
//                               color: AppColors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             LocaleKeys.bank_account_description.tr(), // "سيتم عملية الاستراد على حساب البنكي في خلال 5 أيام عمل"
//                             style: const TextStyle(
//                               color: AppColors.greyText,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const Spacer(),
//
//             // Video play button (placeholder)
//             Center(
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: const BoxDecoration(
//                   color: AppColors.grey,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.play_arrow,
//                   color: AppColors.white,
//                   size: 40,
//                 ),
//               ),
//             ),
//
//             const Spacer(),
//
//             // Continue Button
//             Container(
//               width: double.infinity,
//               height: 50,
//               margin: const EdgeInsets.only(bottom: 20),
//               child: ElevatedButton(
//                 onPressed: _onContinuePressed,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.yellow,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Text(
//                   LocaleKeys.continueKey.tr(), // "استمرار"
//                   style: const TextStyle(
//                     color: AppColors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ===============================================
// // PAGE 3: BANK DETAILS PAGE
// // ===============================================
//
// class BankDetailsPage extends StatefulWidget {
//   final double amount;
//   final String paymentMethod;
//
//   const BankDetailsPage({
//     Key? key,
//     required this.amount,
//     required this.paymentMethod,
//   }) : super(key: key);
//
//   @override
//   State<BankDetailsPage> createState() => _BankDetailsPageState();
// }
//
// class _BankDetailsPageState extends State<BankDetailsPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _bankNameController = TextEditingController();
//   final TextEditingController _bankAccountController = TextEditingController();
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _bankNameController.dispose();
//     _bankAccountController.dispose();
//     super.dispose();
//   }
//
//   String? _validateName(String? value) {
//     if (value == null || value.isEmpty) {
//       return LocaleKeys.name_required.tr(); // "الاسم مطلوب"
//     }
//     if (value.length <= 4) {
//       return LocaleKeys.name_min_length.tr(); // "الاسم يجب أن يكون أكبر من 4 حروف"
//     }
//     return null;
//   }
//
//   String? _validatePhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return LocaleKeys.phone_required.tr(); // "رقم الهاتف مطلوب"
//     }
//
//     // Egyptian phone number validation
//     // Should start with 01 and be 11 digits total
//     final RegExp egyptianPhoneRegex = RegExp(r'^01[0125][0-9]{8}$');
//     if (!egyptianPhoneRegex.hasMatch(value)) {
//       return LocaleKeys.phone_invalid.tr(); // "رقم الهاتف غير صحيح"
//     }
//
//     return null;
//   }
//
//   String? _validateBankName(String? value) {
//     if (value == null || value.isEmpty) {
//       return LocaleKeys.bank_name_required.tr(); // "اسم البنك مطلوب"
//     }
//     return null;
//   }
//
//   String? _validateBankAccount(String? value) {
//     if (value == null || value.isEmpty) {
//       return LocaleKeys.bank_account_required.tr(); // "رقم الحساب مطلوب"
//     }
//     return null;
//   }
//
//   void _onSendPressed() {
//     if (_formKey.currentState?.validate() ?? false) {
//       // Process the withdrawal request
//       _showSuccessDialog();
//     }
//   }
//
//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.background,
//         title: const Text(
//           'تم الإرسال بنجاح',
//           style: TextStyle(color: AppColors.yellow),
//           textAlign: TextAlign.center,
//         ),
//         content: Text(
//           'تم إرسال طلب السحب بمبلغ ${widget.amount} جنيه بنجاح',
//           style: const TextStyle(color: AppColors.white),
//           textAlign: TextAlign.center,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).popUntil((route) => route.isFirst);
//             },
//             child: const Text(
//               'موافق',
//               style: TextStyle(color: AppColors.yellow),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required String? Function(String?) validator,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: AppColors.yellow,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.yellow),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: TextFormField(
//             controller: controller,
//             keyboardType: keyboardType,
//             inputFormatters: inputFormatters,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: const TextStyle(
//                 color: AppColors.greyText,
//                 fontSize: 16,
//               ),
//               contentPadding: const EdgeInsets.all(16),
//               border: InputBorder.none,
//             ),
//             validator: validator,
//           ),
//         ),
//       ],
//     );
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
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: AppColors.yellow,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.arrow_back,
//               color: AppColors.black,
//               size: 20,
//             ),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           LocaleKeys.withdraw_via_bank.tr(), // "السحب من خلال Bank Account"
//           style: const TextStyle(
//             color: AppColors.yellow,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//
//               // Name Field
//               _buildTextField(
//                 controller: _nameController,
//                 label: LocaleKeys.name_label.tr(), // "الاسم"
//                 hint: LocaleKeys.name_hint.tr(), // "Name"
//                 validator: _validateName,
//               ),
//
//               const SizedBox(height: 24),
//
//               // Phone Field
//               _buildTextField(
//                 controller: _phoneController,
//                 label: LocaleKeys.phone_label.tr(), // "رقم الهاتف"
//                 hint: LocaleKeys.phone_hint.tr(), // "Phone"
//                 validator: _validatePhone,
//                 keyboardType: TextInputType.phone,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   LengthLimitingTextInputFormatter(11),
//                 ],
//               ),
//
//               const SizedBox(height: 24),
//
//               // Bank Name Field
//               _buildTextField(
//                 controller: _bankNameController,
//                 label: LocaleKeys.bank_name_label.tr(), // "اسم البنك"
//                 hint: LocaleKeys.bank_name_hint.tr(), // "Bank Name"
//                 validator: _validateBankName,
//               ),
//
//               const SizedBox(height: 24),
//
//               // Bank Account Field
//               _buildTextField(
//                 controller: _bankAccountController,
//                 label: LocaleKeys.bank_account_label.tr(), // "رقم الحساب"
//                 hint: LocaleKeys.bank_account_hint.tr(), // "Bank Account"
//                 validator: _validateBankAccount,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//               ),
//
//               const SizedBox(height: 60),
//
//               // Send Button
//               Container(
//                 width: double.infinity,
//                 height: 50,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 child: ElevatedButton(
//                   onPressed: _onSendPressed,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.yellow,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     LocaleKeys.send_button.tr(), // "إرسال"
//                     style: const TextStyle(
//                       color: AppColors.black,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
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