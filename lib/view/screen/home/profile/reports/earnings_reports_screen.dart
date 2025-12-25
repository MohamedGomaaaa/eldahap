import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/gradient_widget.dart';

import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../components/app_bar_widget.dart';

class EarningsReportsScreen extends StatelessWidget {
  const EarningsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientWidget(
        child: SafeArea(
          child: Column(
            children: [
              const AppBarCustom(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    12.sp,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 12.h,
                      ),
                      Text(
                        LocaleKeys.earningsReports.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(),
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


                      Expanded(
                        child: ListView(
                          children: [
                            ...List.generate(5, (index) {
                              return EarningInfoItemWidget(
                                no: "${index + 1}",
                                details: "Lars Bak",
                                profit: "200",
                                dateAndTime: "2023-23-23",
                              );
                            }),
                          ],
                        ),
                      ),

                      // Expanded(
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       border: Border.symmetric(
                      //         horizontal: BorderSide(
                      //           color: AppColors.textYellow,
                      //           width: 0.2.w,
                      //         ),
                      //       ),
                      //     ),
                      //     child: ListView(
                      //       children: [
                      //         Table(
                      //           border: TableBorder.symmetric(
                      //             inside: BorderSide(
                      //               color: AppColors.textYellow,
                      //               width: 0.2.w,
                      //             ),
                      //           ),
                      //           defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      //           columnWidths: const <int, TableColumnWidth>{
                      //             0: FlexColumnWidth(),
                      //             1: FlexColumnWidth(2),
                      //             2: FlexColumnWidth(),
                      //             3: FlexColumnWidth(2),
                      //           },
                      //           children: [
                      //             TableRow(
                      //               children: [
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: Text(
                      //                     LocaleKeys.no.tr(),
                      //                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: Text(
                      //                     LocaleKeys.details.tr(),
                      //                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: Text(
                      //                     LocaleKeys.profit.tr(),
                      //                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: Text(
                      //                     LocaleKeys.dateAndTime.tr(),
                      //                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //             ...List.generate(5, (index) => TableRow(
                      //               children: [
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: Text(
                      //                     '${index + 1}',
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: const Text(
                      //                     'Lars Bak',
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: const Text(
                      //                     '200',
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: const Text(
                      //                     '2023-23-23',
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // Expanded(
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       border: Border.symmetric(
                      //         horizontal: BorderSide(
                      //           color: AppColors.textYellow,
                      //           width: 0.2.w,
                      //         ),
                      //       ),
                      //     ),
                      //     child: ListView(
                      //       children: [
                      //         DataTable(
                      //           border: TableBorder.symmetric(
                      //             inside: BorderSide(
                      //               color: AppColors.textYellow,
                      //               width: 0.2.w,
                      //             ),
                      //           ),
                      //           columns: [
                      //             DataColumn(
                      //               label: Text(
                      //                 LocaleKeys.no.tr(),
                      //                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //               ),
                      //             ),
                      //             DataColumn(
                      //               label: Text(
                      //                 LocaleKeys.details.tr(),
                      //                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //               ),
                      //             ),
                      //             DataColumn(
                      //               label: Text(
                      //                 LocaleKeys.profit.tr(),
                      //                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //               ),
                      //             ),
                      //             DataColumn(
                      //               label: Expanded(
                      //                 child: Text(
                      //                   LocaleKeys.dateAndTime.tr(),
                      //                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //           rows: [
                      //             DataRow(
                      //               cells: [
                      //                 DataCell(Text('1')),
                      //                 DataCell(Text('Arshik')),
                      //                 DataCell(Text('5644645')),
                      //                 DataCell(Text('3')),
                      //               ],
                      //             ),
                      //             DataRow(
                      //               cells: [
                      //                 DataCell(Text('1')),
                      //                 DataCell(Text('Arshik')),
                      //                 DataCell(Text('5644645')),
                      //                 DataCell(Text('3')),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class EarningInfoItemWidget extends StatelessWidget {
  final String no;
  final String details;
  final String profit;
  final String dateAndTime;

  const EarningInfoItemWidget({
    super.key,
    required this.no,
    required this.details,
    required this.profit,
    required this.dateAndTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("${LocaleKeys.no.tr()}:", no, context),
          _buildInfoRow("${LocaleKeys.details.tr()}:", details, context),
          _buildInfoRow("${LocaleKeys.profit.tr()}:", profit, context),
          _buildInfoRow("${LocaleKeys.dateAndTime.tr()}:", dateAndTime, context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
