import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:intl_phone_field/countries.dart';

import '../../../view_model/utils/colors.dart';
import '../../../view_model/utils/text_style.dart';
import '../../../view_model/utils/validator.dart';

class CreatCountryCodeField extends StatelessWidget {
  final FutureOr<String?> Function(PhoneNumber?)? validator;
  final void Function(PhoneNumber)? onChanged;
  final TextEditingController phoneController;
  final void Function(Country) onCountryChanged;
  final String? title, label, countryName;

  CreatCountryCodeField({
    super.key,
    this.onChanged,
    required this.phoneController,
    required this.onCountryChanged,
    this.validator,
    required this.title,
    required this.label,
    this.countryName,
  });

  double width = 1.0;
  double borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Theme(
        // ✅ Theme للـ dialog (القائمة) علشان الخلفية تبقى سوداء
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.black,
        ),
        child: IntlPhoneField(
          // ✅ استخدم validator اللي بييجي من برا لو موجود، وإلا استخدم الافتراضي
          validator: validator ??
                  (PhoneNumber? value) =>
                  Validator.validatePhoneNumberAsPhone(value: value),

          cursorColor: AppColors.yellow,
          controller: phoneController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          disableLengthCheck: true,

          dropdownIcon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.yellow,
            size: 20,
          ),

          // ✅ ستايل شاشة اختيار الدولة
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: Colors.black, // ✅ الخلفية سوداء

            // ✅ ستايل مربع البحث
            searchFieldInputDecoration: InputDecoration(
              hintText: 'Search',
              hintStyle: MainTitle.display5(context).copyWith(
                fontSize: 13.sp,
                color: AppColors.yellow,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.yellow),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.yellow),
              ),
            ),

            countryNameStyle: MainTitle.display5(context).copyWith(
              fontSize: 13.sp,
              color: AppColors.yellow,
            ),
            countryCodeStyle: MainTitle.display5(context).copyWith(
              fontSize: 13.sp,
              color: AppColors.yellow,
            ),
          ),

          dropdownTextStyle: MainTitle.display5(context).copyWith(
            fontSize: 13.sp,
            color: AppColors.yellow,
          ),

          textAlign: TextAlign.left,

          // ✅ لون الكتابة داخل الحقل أخضر
          style: MainTitle.display5(context).copyWith(
            fontSize: 13.sp,
            color: AppColors.yellow,
          ),

          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            hintText: label,

            // ✅ لون الـ hint أخضر (اختياري)
            hintStyle: MainTitle.display5(context).copyWith(
              fontSize: 13.sp,
              color: AppColors.yellow,
            ),

            filled: true,
            fillColor: Colors.transparent,
            helperStyle: MainLabel.display5(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 7,
            ),

            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow, width: width),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow, width: width),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow, width: width),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.yellow, width: width),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
          ),

          // ✅ مصر افتراضي
          initialCountryCode: countryName ?? "EG",
          languageCode: "en",
          onChanged: onChanged,
          onCountryChanged: onCountryChanged,
        ),
      ),
    );
  }
}
