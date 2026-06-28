

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Methods {




  ////////////////////////////////////////////////////////////////////////
  // static Future<void> launchLocationLink(
  //     BuildContext context,
  //     String locationUrl,
  //
  //     ) async
  // {
  //   final uri = Uri.parse(locationUrl);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   }
  //   else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: mainColor2,
  //         content: Column(
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           children: [
  //             Text(
  //               'تعذر فتح رابط الموقع الجغرافي ( اللوكيشن )',
  //               textAlign: TextAlign.right,
  //               style: WhiteTitle.display5(context),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }
  ////////////////////////////////////////////////////////////////////////

  static String formatCreatedAt(String iso) {
    if (iso.trim().isEmpty) return "";

    try {
      // بيقرأ ISO مثل: 2026-01-08T10:15:30.000Z
      final dt = DateTime.parse(iso);

      // لو عايز تعرضه بتوقيت الجهاز
      final local = dt.toLocal();

      // ✅ فورس English locale
      return DateFormat(
        'dd-MM-yyyy  h:mm a',
        'en', // 👈 هنا المهم
      ).format(local);
    } catch (_) {
      return "";
    }
  }


  static String getCurrencyText({
    required num amount,
    required String? currency,
  }) {
    final value = removeTrailingZeros(amount);

    switch (currency) {
      case 'USD':
        return '$value \$';

      case 'EGP':
        return '$value LE';

      default:
        return value.toString();
    }
  }




  static String getCurrencyText2(String? currency) {
    switch (currency) {
      case 'USD':
        return r'$';

      case 'EGP':
        return 'LE';

      default:
        return "";
    }
  }


  static String removeTrailingZeros(num value, {int decimals = 2}) {
    // 1) قرّب لـ decimals
    final s = value.toStringAsFixed(decimals);

    // 2) شيل الأصفار اللي على اليمين + النقطة لو بقت فاضية
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }



}
