import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/model/faq.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view_model/cubit/home_cubit/home_cubit.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../components/app_bar_widget.dart';

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
                  color: AppColors.textYellow,
                ),
                SizedBox(
                  height: 6.h,
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
                      child: Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: ExpansionPanelList(
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

                              // الضغط على السؤال نفسه
                              // يفتح ويقفل
                              canTapOnHeader: true,

                              headerBuilder: (
                                BuildContext context,
                                bool isExpanded,
                              ) {
                                return Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: Text(
                                    item.question ?? '',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textYellow,
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
                                      ),
                                ),
                              ),

                              isExpanded: item.isExpanded ?? false,
                            );
                          }).toList(),
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
// class FAQScreen extends StatelessWidget {
//   const FAQScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: HomeCubit.get(context)..getFaqs(),
//       child: Scaffold(
//         body: GradientWidget(
//           child: SafeArea(
//             child: ListView(
//               padding: EdgeInsets.all(12.sp),
//               children: [
//                 const AppBarCustom(),
//                 SizedBox(
//                   height: 12.h,
//                 ),
//                 Text(
//                   LocaleKeys.faq.tr(),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       // color: AppColors.textYellow,
//                       ),
//                 ),
//                 SizedBox(
//                   height: 6.h,
//                 ),
//                 const Divider(
//                   color: AppColors.textYellow,
//                 ),
//                 SizedBox(
//                   height: 6.h,
//                 ),
//                 BlocBuilder<HomeCubit, HomeState>(
//                   builder: (context, state) {
//                     HomeCubit cubit = HomeCubit.get(context);
//
//                     if (cubit.faqs.isEmpty) {
//                       return const SizedBox();
//                     }
//
//                     return ExpansionPanelList(
//                       elevation: 1,
//                       expandIconColor: AppColors.textYellow,
//                       expandedHeaderPadding: EdgeInsets.zero,
//                       animationDuration: const Duration(milliseconds: 500),
//
//                       expansionCallback: (int index, bool isExpanded) {
//                         cubit.changeFAQ(index, isExpanded);
//                       },
//
//                       children: cubit.faqs.map<ExpansionPanel>((FAQ item) {
//                         return ExpansionPanel(
//                           backgroundColor: AppColors.transparent,
//
//                           headerBuilder: (BuildContext context, bool isExpanded) {
//                             return ListTile(
//                               title: Text(
//                                 item.question ?? '',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyMedium
//                                     ?.copyWith(
//                                   color: AppColors.textYellow,
//                                 ),
//                               ),
//                             );
//                           },
//
//                           body: ListTile(
//                             title: Text(
//                               item.answer ?? '',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodyMedium
//                                   ?.copyWith(
//                                 color: AppColors.white,
//                               ),
//                             ),
//                           ),
//
//                           isExpanded: item.isExpanded ?? false,
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//                 // BlocBuilder<HomeCubit, HomeState>(
//                 //   builder: (context, state) {
//                 //     HomeCubit cubit = HomeCubit.get(context);
//                 //     return ListView(
//                 //       physics: const NeverScrollableScrollPhysics(),
//                 //       shrinkWrap: true,
//                 //       children: generateItems(cubit.faqs).map<Widget>((Item item) {
//                 //         return Container(
//                 //           margin: EdgeInsets.only(bottom: 8.h),
//                 //           decoration: BoxDecoration(
//                 //             borderRadius: BorderRadius.circular(12.r),
//                 //             border: Border.all(
//                 //               color: AppColors.yellowBorder,
//                 //               width: 0.5.w,
//                 //             ),
//                 //             color: AppColors.backgroundGrey,
//                 //           ),
//                 //           clipBehavior: Clip.antiAliasWithSaveLayer,
//                 //           child: ExpansionPanelList(
//                 //             elevation: 1,
//                 //             expandIconColor: AppColors.textYellow,
//                 //             expandedHeaderPadding: const EdgeInsets.all(0),
//                 //             animationDuration:
//                 //                 const Duration(milliseconds: 500),
//                 //             expansionCallback: (int index, bool isExpanded) {
//                 //               cubit.changeFAQ(index, isExpanded);
//                 //             },
//                 //             children: [
//                 //               ExpansionPanel(
//                 //                 backgroundColor: AppColors.transparent,
//                 //                 // canTapOnHeader: true,
//                 //                 headerBuilder:
//                 //                     (BuildContext context, bool isExpanded) {
//                 //                   return ListTile(
//                 //                     title: Text(
//                 //                       item.headerValue,
//                 //                       style: Theme.of(context)
//                 //                           .textTheme
//                 //                           .bodyMedium
//                 //                           ?.copyWith(
//                 //                             color: AppColors.textYellow,
//                 //                           ),
//                 //                     ),
//                 //                   );
//                 //                 },
//                 //                 body: ListTile(
//                 //                   title: Text(
//                 //                     item.expandedValue,
//                 //                     style: Theme.of(context)
//                 //                         .textTheme
//                 //                         .bodyMedium
//                 //                         ?.copyWith(
//                 //                           color: AppColors.white,
//                 //                         ),
//                 //                   ),
//                 //                 ),
//                 //                 isExpanded: item.isExpanded,
//                 //               ),
//                 //             ],
//                 //           ),
//                 //         );
//                 //       }).toList(),
//                 //     );
//                 //   },
//                 // ),
//                 // ExpansionPanelList(
//                 //   expansionCallback: (int index, bool isExpanded) {},
//                 //   children: [
//                 //     ExpansionPanel(
//                 //       headerBuilder: (BuildContext context, bool isExpanded) {
//                 //         return ListTile(
//                 //           title: Text('Item 1'),
//                 //         );
//                 //       },
//                 //       body: ListTile(
//                 //         title: Text('Item 1 child'),
//                 //         subtitle: Text('Details goes here'),
//                 //       ),
//                 //       isExpanded: true,
//                 //     ),
//                 //     ExpansionPanel(
//                 //       headerBuilder: (BuildContext context, bool isExpanded) {
//                 //         return ListTile(
//                 //           title: Text('Item 2'),
//                 //         );
//                 //       },
//                 //       body: ListTile(
//                 //         title: Text('Item 2 child'),
//                 //         subtitle: Text('Details goes here'),
//                 //       ),
//                 //       isExpanded: false,
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
