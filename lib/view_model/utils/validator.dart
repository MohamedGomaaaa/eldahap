import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:official_gold/view_model/utils/common_method.dart';
import '../../l10n/locale_keys.g.dart';




class Validator {
  // static String? validatePassword({required String? value}) {
  //   if (value == null || value.trim().isEmpty) {
  //     return "please_enter_password".tr;        // يرجى إدخال كلمة المرور
  //   }
  //   if (value.length < 6) {
  //     return "password_min_length".tr;          // كلمة المرور يجب أن تتكون من 6 أحرف على الأقل
  //   }
  //   return null;
  // }
////////////////////////////////////////////////////////////////////////////////////////////////////
//   static String? validatePhoneNumber({required String? value}) {
//     final arabicDigitsRegex = RegExp(r'[٠-٩]'); // أرقام عربية (Hindi digits)
//
//     if (value == null || value.trim().isEmpty) {
//       return "invalid_phone".tr;
//     }
//
//     // ❌ منع الأرقام العربية
//     if (arabicDigitsRegex.hasMatch(value)) {
//       return "arabic_digits_not_allowed".tr; // أضفها في الترجمة
//     }
//
//     // ❌ أقل من 7 أرقام
//     if (value.length < 6) {
//       return "invalid_phone".tr;
//     }
//
//     return null;
//   }

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


//
//
// //////////////////////////////////////////////////////////////////////////////////////////////////////
  static String? validateConfirmPassword({
    required String? value,
    required String? originalPassword,
  }) {

    if (value != originalPassword) {
      return LocaleKeys.confirmPassword2.tr();

    }
    return null;
  }
// //////////////////////////////////////////////////////////////////////////////////////////////////////

  static String? validatePriceWithRange({
  required String? value,
  required num originalPrice,
  double percentage = 50,
  })
  {
  // null or empty
  if (value == null || value.trim().isEmpty) {
  return "please_fill_field";
  }

  // parse number
  final num? enteredPrice = num.tryParse(value);
  if (enteredPrice == null) {
  return "invalid_number";
  }

  // calculate limits
  final num minPrice =
  originalPrice * (1 - percentage / 100); // 75
  final num maxPrice =
  originalPrice * (1 + percentage / 100); // 125

  // validate range
  if (enteredPrice < minPrice || enteredPrice > maxPrice) {
  return "price_must_be_between" +
  " ${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)}";
  }

  return null;
  }



  static String? validateStopLoss({
    required String? value,
    required num livePrice,
    bool requiredField = false,
  }) {
    // null or empty
    if (value == null || value.trim().isEmpty) {
      return requiredField ? "please_fill_field" : null;
    }

    // parse number
    final num? entered = num.tryParse(value.trim());
    if (entered == null) {
      return "invalid_number";
    }

    // ✅ stop loss لازم يكون <= livePrice
    if (entered > livePrice) {
      return "stop_loss_must_be_less_or_equal_live ${Methods.removeTrailingZeros(livePrice)}"
    ;
    }

    return null;
  }

  static String? validateTakeProfit({
    required String? value,
    required num livePrice,
    bool requiredField = false,
  })
  {
    // null or empty
    if (value == null || value.trim().isEmpty) {
      return requiredField ? "please_fill_field" : null;
    }

    // parse number
    final num? entered = num.tryParse(value.trim());
    if (entered == null) {
      return "invalid_number";
    }

    // ✅ take profit لازم يكون >= livePrice
    if (entered < livePrice) {
      return "take_profit_must_be_greater_or_equal_live ${Methods.removeTrailingZeros(livePrice)}";

    }

    return null;
  }



  static String? validateQuantity({
    required String? value,
    required num finalPrice,      // ✅ السعر النهائي (الإجمالي)
    required num walletBalance,   // ✅ رصيد المحفظة
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
    if (finalPrice > walletBalance) {
      return "insufficient_wallet_balance";
    }

    return null;
  }



// //////////////////////////////////////////////////////////////////////////////////////////////////////
  static String? validateEmail({required String? value}) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validateEmail2.tr();  // يرجى إدخال بريد إلكتروني
    }
    String trimmed = value.trim();
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(trimmed)) {
      return LocaleKeys.validateEmail2.tr();      // يرجى إدخال بريد إلكتروني صحيح
    }
    return null;

//   }
// //////////////////////////////////////////////////////////////////////////////////////////////////////
// //   static String? validateLocation({required String? value})
// //   {
// //     if (value == null || value.trim().isEmpty)
// //     {
// //       return null;
// //     }
// //     final googleMapsPattern = RegExp(r'^(https?:\/\/)?(www\.)?(google\.com\/maps|goo\.gl\/maps|maps\.app\.goo\.gl)\/[^\s]+$', caseSensitive: false);
// //     if (!googleMapsPattern.hasMatch(value.trim())) {
// //       return "invalid_location".tr;    // يرجى إدخال رابط موقع جوجل ماب صالح أو ترك الحقل فارغًا
// //     }
// //     return null;
// //   }
// }

}}