import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view_model/utils/colors.dart';



class BlackTitle {
  static TextStyle display5(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontSize: 14.sp,
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: Color(0xff3D3D3D),
    );
  }
}

class BlackLabel {
  static TextStyle display5(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontSize: 12.sp,
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: Color(0xff3D3D3D),
    );
  }
}

class MainTitle {
  static TextStyle display5(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontSize: 14.sp,
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
   color: AppColors.yellow,
    );
  }
}

class WhiteTitle {
  static TextStyle display5(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontSize: 14.sp,
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }
}

class WhiteLabel {
  static TextStyle display5(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontSize: 12.sp,
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }
}

class MainLabel {
  static TextStyle display5(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontSize: 12.sp,
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: AppColors.yellow,
    );
  }
}
