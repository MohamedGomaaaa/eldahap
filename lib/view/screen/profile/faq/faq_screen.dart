import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/model/faq.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view_model/cubit/home_cubit/home_cubit.dart';

import '../../../../services/translation/locale_keys.g.dart';
import '../../../../utils/app_color.dart';
import '../../../components/app_bar_widget.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: HomeCubit.get(context)..getFaqs(),
      child: Scaffold(
        body: GradientWidget(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(12.sp),
              children: [
                const AppBarCustom(),
                SizedBox(
                  height: 12.h,
                ),
                Text(
                  LocaleKeys.faq.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(
                  height: 6.h,
                ),
                const Divider(
                  color: AppColors.yellow, // ✅ لون أصفر صريح
                  thickness: 1,
                ),
                SizedBox(
                  height: 12.h,
                ),
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    HomeCubit cubit = HomeCubit.get(context);

                    // Loading
                    if (state is GetFAQLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.yellow,
                        ),
                      );
                    }

                    // لا يوجد بيانات
                    if (cubit.faqs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No FAQs Found",
                          style: TextStyle(
                            color: AppColors.white,
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.yellowBorder,
                          width: 0.5.w,
                        ),
                        color: AppColors.backgroundGrey,
                      ),
                      // ✅ إجبار الثيم على استخدام الأصفر الصريح للفواصل
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: AppColors.yellow, // ✅ تم التعديل لأصفر صريح
                        ),
                        child: Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: ExpansionPanelList(
                            // ✅ لو إصدار فلاتر بتاعك حديث، الخاصية دي هتلوّن الديفايدر مباشرة
                            dividerColor: AppColors.yellow,
                            elevation: 1,
                            expandIconColor: AppColors.textYellow,
                            expandedHeaderPadding: EdgeInsets.zero,
                            animationDuration: const Duration(
                              milliseconds: 500,
                            ),
                            expansionCallback: (int index, bool isExpanded) {
                              cubit.changeFAQ(
                                index,
                                isExpanded,
                              );
                            },
                            children: cubit.faqs.map<ExpansionPanel>((FAQ item) {
                              return ExpansionPanel(
                                backgroundColor: AppColors.transparent,
                                canTapOnHeader: true,
                                headerBuilder: (
                                    BuildContext context,
                                    bool isExpanded,
                                    ) {
                                  return Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 12.h, // ✅ زودنا البادينج هنا كمان براح أكتر
                                    ),
                                    child: Text(
                                      item.question ?? '',
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        color: AppColors.textYellow,
                                        height: 2.0, // ✅ تم زيادة المسافة بين السطور (العربي والإنجليزي) لـ 2.0 علشان تبان بوضوح
                                      ),
                                    ),
                                  );
                                },
                                body: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12.sp),
                                  child: Text(
                                    item.answer ?? '',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      color: AppColors.white,
                                      height: 2.0, // ✅ زيادة المسافة في الإجابة أيضاً
                                    ),
                                  ),
                                ),
                                isExpanded: item.isExpanded ?? false,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(List<FAQ> numberOfItems) {
  return List<Item>.generate(numberOfItems.length, (int index) {
    return Item(
      headerValue: numberOfItems[index].question ?? '',
      expandedValue: numberOfItems[index].answer ?? '',
      isExpanded: numberOfItems[index].isExpanded ?? false,
    );
  });
}