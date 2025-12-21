import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/phone_number.dart';
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
//   static String? validateEmpty({required String? value}) {
//     if (value == null || value.trim().isEmpty) {
//       return "please_fill_field".tr;       // يرجى ملء الحقل
//     }
//     return null;
//   }
//
//   static String? validateEmpty2({required String? value}) {
//     if (value == null || value.trim().isEmpty) {
//       return "please_fill".tr;       // يرجى ملء الحقل
//     }
//     return null;
//   }
//
//
//
//
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