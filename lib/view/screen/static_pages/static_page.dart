import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/utils/text_style.dart';

import '../../../utils/app_assets.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_constant.dart';

class CommonArticleScreen extends StatelessWidget {
  final String title;

  final String articleText;

  const CommonArticleScreen({
    super.key,
    required this.title,

    required this.articleText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون الخلفية الداكن المطابق للصورة
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:  const Icon(Icons.arrow_back_ios, color: AppColors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: MainTitle.display5(context)
      )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // قسم الصور (يظهر فقط إذا كانت هناك صور)
            // ==========================================
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                viewportFraction: 0.9,
                enlargeCenterPage: true,
                clipBehavior: Clip.none,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: [
                Container(
                  width: double.infinity,
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.yellowBorder,
                      width: 0.5.sp,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.yellow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child:Image.asset(   AppAssets.static,fit: BoxFit.cover,)

                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ==========================================
            // قسم المقال النصي
            // ==========================================
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // لون خلفية الكونتينر
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.yellow, // الإطار الذهبي المائل للشفافية
                  width: 1,
                ),
              ),
              child: Text(
                articleText,
                style: MainTitle.display5(context).copyWith(
                  fontSize: 16,
                  height: 1.8, // تباعد الأسطر لسهولة القراءة
                  fontWeight: FontWeight.w500,
                ),

                textDirection:
                    TextDirection.rtl, // لضبط النص العربي من اليمين لليسار
              ),
            ),

            // مسافة سفلية
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
