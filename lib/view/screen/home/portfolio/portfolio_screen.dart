import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:official_gold/view/screen/home/portfolio/trades_section.dart';

import '../../../../l10n/locale_keys.g.dart';
import '../../../../view_model/utils/colors.dart';
import 'orders_section.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  //This is for background color
                  color: AppColors.transparent,
                  //This is for bottom border that is needed
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.grey,
                      width: 0.8.sp,
                    ),
                  ),
                ),
                child: TabBar(
                  labelStyle:  TextStyle(
                    fontFamily: GoogleFonts.cairo().fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle:  TextStyle(
                    fontFamily: GoogleFonts.cairo().fontFamily,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      text: LocaleKeys.trades.tr(),
                    ),
                    Tab(
                      text: LocaleKeys.orders.tr(),
                    ),
                  ],
                  onTap: (index) {
                    // productCubit.getProducts(index);
                  },
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    TradesSection(),
                    OrdersSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
