import 'package:flutter/material.dart';

// class Navigation {
//   static void push(BuildContext context, Widget page) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => page),
//     );
//   }
//
//   static void pushAndRemoveUntil(BuildContext context, Widget page) {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => page),
//       (route) => false,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:official_gold/view_model/utils/colors.dart';

class Navigation {
  static void push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return ColoredBox(
            color: AppColors.background, // يمنع الفلاش الأبيض
            child: page,
          );
        },
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return ColoredBox(
            color: AppColors.background, // يمنع الفلاش الأبيض
            child: page,
          );
        },
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
          (route) => false,
    );
  }
}
