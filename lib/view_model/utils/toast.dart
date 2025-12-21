import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart' as toast;
import 'package:official_gold/view_model/utils/colors.dart';

class Toast {

  static void showMsg({required String msg, Color? color = AppColors.yellow2, Color? textColor = AppColors.black}) {
    toast.Fluttertoast.showToast(
        msg: msg,
        toastLength: toast.Toast.LENGTH_LONG,
        gravity: toast.ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: color,
        textColor: textColor,
        fontSize: 16.sp
    );
  }

  static void showError({required String msg, Color? color = AppColors.red, Color? textColor = AppColors.white}) {
    toast.Fluttertoast.showToast(
        msg: msg,
        toastLength: toast.Toast.LENGTH_SHORT,
        gravity: toast.ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: color,
        textColor: textColor,
        fontSize: 16.sp
    );
  }
}