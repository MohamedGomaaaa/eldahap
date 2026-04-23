import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:official_gold/view_model/utils/common_method.dart';
import '../../l10n/locale_keys.g.dart';

class Validator {
// ////////////////////////////////////////////////////////////////////////////////////////////////////// validate  phoneNumber As Phone
  static String? validatePhoneNumberAsPhone({required PhoneNumber? value}) {
    if (value == null) return "invalid_phone";

    final number = value.number.trim();

    if (number.isEmpty) {
      return LocaleKeys.phoneError.tr();
    }

    // ❌ منع الأرقام العربية/الهندية
    final arabicDigitsRegex = RegExp(r'[٠-٩]');
    if (arabicDigitsRegex.hasMatch(number)) {
      return LocaleKeys.arabicPhoneError.tr();
    }

    // ❌ يرفض أي مسافة أو أي رمز أو أي حرف
    // يعني لازم يكون أرقام إنجليزية فقط وبس
    final onlyEnglishDigits = RegExp(r'^[0-9]+$');
    if (!onlyEnglishDigits.hasMatch(number)) {
      return LocaleKeys.phoneError.tr();
    }

    // ❌ الطول (عدلها حسب بلدك لو تحب)
    if (number.length < 6 || number.length > 15) {
      return LocaleKeys.phoneError.tr();
    }

    return null;
  }

// ////////////////////////////////////////////////////////////////////////////////////////////////////// validate Confirm Password
  static String? validateConfirmPassword({
    required String? value,
    required String? originalPassword,
  }) {
    if (value != originalPassword) {
      return LocaleKeys.confirmPassword2.tr();
    }
    return null;
  }
// ////////////////////////////////////////////////////////////////////////////////////////////////////// validate Price With Range

  static String? validatePriceWithRange(
      {required String? enteredValue,
      required num livePrice,
      double percentage = 50}) {
    // null or empty
    if (enteredValue == null || enteredValue.trim().isEmpty) {
      return "please_fill_field";
    }

    // parse number
    final num? enteredPrice = num.tryParse(enteredValue);
    if (enteredPrice == null) {
      return "invalid_number";
    }

    // calculate limits
    final num minPrice = livePrice * (1 - percentage / 100); // 75
    final num maxPrice = livePrice * (1 + percentage / 100); // 125

    // validate range
    if (enteredPrice < minPrice || enteredPrice > maxPrice) {
      return "price_must_be_between" +
          " ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)}";
    }

    return null;
  }

// ////////////////////////////////////////////////////////////////////////////////////////////////////// validate Stop Loss

  static String? validateStopLoss(
      {required String? enteredValue,
      required num livePrice,
      bool requiredField = false,
      double percentage = 50})
  {
    // null or empty
    if (enteredValue == null || enteredValue.trim().isEmpty) {
      return requiredField ? "please_fill_field" : null;
    }

    // parse number
    final num? enteredPrice = num.tryParse(enteredValue);
    if (enteredPrice == null) {
      return "invalid_number";
    }

    // calculate limits
    final num minPrice = livePrice * (1 - percentage / 100); // 75
    final num maxPrice = livePrice * (1 + percentage / 100); // 125

    // validate range
    if (enteredPrice < minPrice || enteredPrice > maxPrice) {
      return "price_must_be_between" +
          " ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)}";
    }

    return null;

///////////////////////////////////////////////////////// old
    // // parse number
    // final num? entered = num.tryParse(enteredValue.trim());
    // if (entered == null) {
    //   return "invalid_number";
    // }
    //
    // // ✅ stop loss لازم يكون <= livePrice
    // if (entered > livePrice) {
    //   return "stop_loss_must_be_less_or_equal_live ${Methods.removeTrailingZeros(livePrice)}";
    // }
    //
    // return null;
  }

// ////////////////////////////////////////////////////////////////////////////////////////////////////// validate Take Profit
  static String? validateTakeProfit(
      {required String? enteredValue,
      required num livePrice,
      bool requiredField = false,
      double percentage = 50}) {
    // null or empty
    if (enteredValue == null || enteredValue.trim().isEmpty) {
      return requiredField ? "please_fill_field" : null;
    }

    // parse number
    final num? enteredPrice = num.tryParse(enteredValue);
    if (enteredPrice == null) {
      return "invalid_number";
    }

    // calculate limits
    final num minPrice = livePrice * (1 - percentage / 100); // 75
    final num maxPrice = livePrice * (1 + percentage / 100); // 125

    // validate range
    if (enteredPrice < minPrice || enteredPrice > maxPrice) {
      return "price_must_be_between" +
          " ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)}";
    }

    return null;

///////////////////////////////////////////////////////// old
    // // parse number
    // final num? entered = num.tryParse(enteredValue.trim());
    // if (entered == null) {
    //   return "invalid_number";
    // }
    //
    // // ✅ take profit لازم يكون >= livePrice
    // if (entered < livePrice) {
    //   return "take_profit_must_be_greater_or_equal_live ${Methods.removeTrailingZeros(livePrice)}";
    // }
    //
    // return null;
  }

// ////////////////////////////////////////////////////////////////////////////////////////////////////// validate Quantity

  static String? validateQuantity({
    required String? value,
    required num finalPrice, // ✅ السعر النهائي (الإجمالي)
    required num walletBalance, // ✅ رصيد المحفظة
    bool requiredField = false,
  }) {
    ////////////////////////////////// finalPrice=  live *quantity*weight

    // null or empty
    if (value == null || value.trim().isEmpty) {
      return requiredField ? "please_fill_field" : null;
    }

    // parse number
    final num? entered = num.tryParse(value.trim());
    if (entered == null) {
      return "invalid_number";
    }

    // optional: quantity لازم تكون > 0
    if (entered <= 0) {
      return "quantity_must_be_greater_than_zero";
    }

    // ✅ لو السعر النهائي أكبر من المحفظة -> error
    // if (finalPrice > walletBalance) {
    //   return "insufficient_wallet_balance";
    // }

    return null;
  }

// ////////////////////////////////////////////////////////////////////////////////////////////////////// validate Email
  static String? validateEmail({required String? value}) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validateEmail2.tr(); // يرجى إدخال بريد إلكتروني
    }
    String trimmed = value.trim();
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(trimmed)) {
      return LocaleKeys.validateEmail2.tr(); // يرجى إدخال بريد إلكتروني صحيح
    }
    return null;
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////
  static String? validateAmount({
    required String? value,
    required num walletDollar,
    bool requiredField = true,
  }) {
    // فاضي
    if (value == null || value.trim().isEmpty) {
      return requiredField ? "please_fill_field" : null;
    }

    final input = value.trim();

    // ❌ يتحقق إنه رقم
    final isValidNumber = RegExp(r'^\d+(\.\d+)?$').hasMatch(input);
    if (!isValidNumber) {
      return "invalid_number";
    }

    final double amount = double.parse(input);

    // ❌ أقل من أو يساوي صفر
    if (amount <= 0) {
      return "amount_must_be_greater_than_zero";
    }

    // ❌ أكبر من الرصيد
    if (amount > walletDollar) {
      return "insufficient_balance";
    }

    return null;
  }
///////////////////////////////////////////////////////////////////////////////////////////////
// في class Validator - أضف هذه الدالة الجديدة
  static String? validateWithdrawalAmount({
    required String? value,
    required num walletBalance,  // رصيد المحفظة (دولار أو جنيه)
    required String currency,    // "Dollar" أو "LE"
    bool requiredField = true,
    double minAmount = 1.0,     // الحد الأدنى (قابل للتعديل)
  })
  {
    // 1. فاضي أو null
    if (value == null || value.trim().isEmpty) {
      return requiredField ? "${currency}_amount_required".tr() : null;
    }

    final input = value.trim();

    // 2. ❌ يتحقق إنه رقم صحيح (RegExp نفس اللي عندك)
    final isValidNumber = RegExp(r'^\d+\.?\d{0,2}$').hasMatch(input);
    if (!isValidNumber) {
      return "${currency}_invalid_number".tr();
    }

    // 3. parse الرقم
    final double amount = double.tryParse(input) ?? 0;

    // 4. ❌ أقل من الحد الأدنى
    if (amount < minAmount) {
      return "${currency}_min_amount_required".tr();
    }

    // 5. ❌ أكبر من رصيد المحفظة
    if (amount > walletBalance) {
      return "${currency}_insufficient_balance".tr();
    }

    return null;
  }
////////////////////////////////////////////////////////////////////////////////////////////////////
  static String? validateDepositAmount({
    required String? value,
    required num walletDollar,
    bool requiredField = true,
    double minAmount = 1.0,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredField ? "dollar_amount_required".tr() : null;
    }

    final input = value.trim();

    final isValidNumber = RegExp(r'^\d+\.?\d{0,2}$').hasMatch(input);
    if (!isValidNumber) {
      return "dollar_invalid_number".tr();
    }

    final double amount = double.tryParse(input) ?? 0;

    if (amount < minAmount) {
      return "dollar_min_amount_required".tr();
    }

    // if (amount > walletDollar) {
    //   return "dollar_insufficient_balance".tr();
    // }

    return null;
  }







}
