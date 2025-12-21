import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:official_gold/view_model/utils/colors.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: GoogleFonts.cairo().fontFamily, // Explicitly set Cairo as the default font family
  primaryColor: AppColors.yellow,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    iconTheme: const IconThemeData(
      color: AppColors.white,
    ),
    titleTextStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    showUnselectedLabels: true,
    elevation: 0,
    selectedItemColor: AppColors.yellow2,
    unselectedItemColor: AppColors.grey,
    unselectedIconTheme: const IconThemeData(
      color: AppColors.grey,
    ),
    selectedLabelStyle: GoogleFonts.cairo(
      color: AppColors.yellow2,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
    unselectedLabelStyle: GoogleFonts.cairo(
      color: AppColors.yellow2,
      fontSize: 10.sp,
      fontWeight: FontWeight.bold,
    ),
  ),
  primaryColorLight: AppColors.yellow,
  primaryColorDark: AppColors.yellow,
  hintColor: AppColors.textYellow,
  primarySwatch: Colors.yellow,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppColors.yellowBorder,
    selectionColor: AppColors.yellowBorder,
    selectionHandleColor: AppColors.yellowBorder,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(AppColors.textYellow),
      overlayColor:
      MaterialStateProperty.all(AppColors.yellowBorder.withOpacity(0.3)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      textStyle: MaterialStateProperty.all(
        GoogleFonts.cairo(
          color: AppColors.red,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(AppColors.yellow),
      overlayColor:
      MaterialStateProperty.all(AppColors.yellowBorder.withOpacity(0.3)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      textStyle: MaterialStateProperty.all(
        GoogleFonts.cairo(
          color: AppColors.textYellow,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: AppColors.yellowBorder,
        width: 1.w,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: AppColors.yellowBorder,
        width: 1.w,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: AppColors.yellowBorder,
        width: 2.w,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: AppColors.red,
        width: 1.w,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: AppColors.red,
        width: 2.w,
      ),
    ),
    labelStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
    hintStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
    errorStyle: GoogleFonts.cairo(
      color: AppColors.red,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: AppColors.grey,
        width: 1.w,
      ),
    ),
    floatingLabelStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
    helperStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
    iconColor: AppColors.yellow2,
    activeIndicatorBorder: BorderSide(
      color: AppColors.yellowBorder,
      width: 1.w,
    ),
    counterStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: AppColors.textYellow,
    unselectedLabelColor: AppColors.greyText,
    labelStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
    ),
    unselectedLabelStyle: GoogleFonts.cairo(
      color: AppColors.greyText,
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
    ),
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: AppColors.yellowBorder,
        width: 2.w,
      ),
    ),
  ),

  // tabBarTheme:
  //
  //
  //
  //
  // TabBarTheme(
  //   labelColor: AppColors.textYellow,
  //   unselectedLabelColor: AppColors.greyText,
  //   labelStyle: GoogleFonts.cairo(
  //     color: AppColors.textYellow,
  //     fontSize: 18.sp,
  //     fontWeight: FontWeight.bold,
  //   ),
  //   unselectedLabelStyle: GoogleFonts.cairo(
  //     color: AppColors.greyText,
  //     fontSize: 16.sp,
  //     fontWeight: FontWeight.bold,
  //   ),
  //   indicator: UnderlineTabIndicator(
  //     borderSide: BorderSide(
  //       color: AppColors.yellowBorder,
  //       width: 2.w,
  //     ),
  //   ),
  // ),
  textTheme: GoogleFonts.cairoTextTheme(
    TextTheme(
      displayLarge: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 10.sp,
        fontWeight: FontWeight.bold,
      ),
      bodySmall: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 8.sp,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: GoogleFonts.cairo(
        color: AppColors.textYellow,
        fontSize: 8.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);