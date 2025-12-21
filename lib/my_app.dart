import 'package:official_gold/view_model/cubit/auth_cubit/auth_cubit.dart';
import 'package:official_gold/view_model/cubit/home_cubit/home_cubit.dart';
import 'package:official_gold/view_model/cubit/layout_cubit/layout_cubit.dart';
import 'package:official_gold/view_model/cubit/product_cubit/product_cubit.dart';
import 'package:official_gold/view_model/cubit/ticket_cubit/ticket_cubit.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart';
import 'package:official_gold/view_model/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'view_model/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view/screen/splash/splash_screen.dart';
import 'view_model/cubit/wallet_cubit/wallet_cubit.dart';



final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.setLocale(const Locale('en',));
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(),),
        BlocProvider(create: (context) => LayoutCubit(),),
        BlocProvider(create: (context) => HomeCubit()..getProfile(),),
        BlocProvider(create: (context) => ProductCubit(),),
        BlocProvider(create: (context) => WalletCubit(),),
        BlocProvider(create: (context) => TicketCubit(),),
        BlocProvider(create: (context) => TradesCubit(),),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (_ , child) {
          ScreenUtil.init(context);
          return MaterialApp(
            title: 'Gold Trade',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            theme: lightTheme.copyWith(
              // Ensure the font family is explicitly set at the app level
              textTheme: GoogleFonts.cairoTextTheme(lightTheme.textTheme),
              primaryTextTheme: GoogleFonts.cairoTextTheme(lightTheme.primaryTextTheme),
            ),
            darkTheme: darkTheme,
            themeMode: ThemeMode.light,
            home: child,
            navigatorKey: navKey,
            // Add this builder to ensure all text uses Cairo font
            builder: (context, child) {
              return DefaultTextStyle(
                style: GoogleFonts.cairo(
                  color: Colors.black, // You can adjust this based on your theme
                  fontSize: 14, // Default font size
                ),
                child: child ?? Container(),
              );
            },
          );
        },
        child: const SplashScreen(),
      ),
    );
  }
}


// Create a helper method to ensure Cairo font is applied consistently
TextTheme _buildCairoTextTheme(ColorScheme colorScheme) {
  return TextTheme(
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
    headlineLarge: GoogleFonts.cairo(
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
    labelLarge: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 10.sp,
      fontWeight: FontWeight.bold,
    ),
    labelSmall: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 8.sp,
      fontWeight: FontWeight.bold,
    ),
  );
}

ThemeData lightTheme = ThemeData(
  // Set Cairo as the default font family for the entire app
  fontFamily: GoogleFonts.cairo().fontFamily,
  primaryColor: AppColors.yellow,
  scaffoldBackgroundColor: AppColors.background,

  // Use the helper method to create consistent text theme
  textTheme: _buildCairoTextTheme(const ColorScheme.light()),
  primaryTextTheme: _buildCairoTextTheme(const ColorScheme.light()),

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
    toolbarTextStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 16.sp,
      fontWeight: FontWeight.normal,
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
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(AppColors.textYellow),
      textStyle: MaterialStateProperty.all(
        GoogleFonts.cairo(
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

  // tabBarTheme: TabBarTheme(
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
  // Add dialog theme to ensure dialogs use Cairo font


  dialogTheme: DialogThemeData(
    titleTextStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
      fontWeight: FontWeight.normal,
    ),
  ),




  // dialogTheme: DialogTheme(
  //   titleTextStyle: GoogleFonts.cairo(
  //     color: AppColors.textYellow,
  //     fontSize: 18.sp,
  //     fontWeight: FontWeight.bold,
  //   ),
  //   contentTextStyle: GoogleFonts.cairo(
  //     color: AppColors.textYellow,
  //     fontSize: 12.sp,
  //     fontWeight: FontWeight.normal,
  //   ),
  // ),
  // Add chip theme
  chipTheme: ChipThemeData(
    labelStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
    ),
  ),
  // Add list tile theme
  listTileTheme: ListTileThemeData(
    titleTextStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
    ),
    subtitleTextStyle: GoogleFonts.cairo(
      color: AppColors.textYellow,
      fontSize: 12.sp,
      fontWeight: FontWeight.normal,
    ),
  ),
);