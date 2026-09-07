import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/screen/auth/login_screen.dart';


import 'package:page_transition/page_transition.dart';

import '../../../services/shared_preference/shared_helper.dart';
import '../../../services/shared_preference/shared_keys.dart';
import '../../../utils/app_assets.dart';
import '../../../utils/app_color.dart';
import '../create_nav_bar/layout_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: AppColors.background,
      splash: AppAssets.logoPng,
      splashIconSize: 150.sp,
      nextScreen: SharedHelper.get(SharedKeys.token) == null ? const LoginScreen() : const LayoutScreen(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
