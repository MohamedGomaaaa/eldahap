import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/gradient_widget.dart';

import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../components/app_bar_widget.dart';
import 'order_report_model.dart';

class OrderReportsScreen extends StatelessWidget {
   OrderReportsScreen({super.key});



  Widget _buildHeaderCell(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.sp),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


  final List<InfoItem> items = [
    InfoItem(
      name: "Mohamed",
      phone: "01012345678",
      bankName: "CIB",
      accountNumber: "123456789",
    ),
    InfoItem(
      name: "Ali",
      phone: "01098765432",
      bankName: "QNB",
      accountNumber: "987654321",
    ),
    InfoItem(
      name: "Sara",
      phone: "01011122233",
      bankName: "HSBC",
      accountNumber: "555666777",
    ),
  ];

  Widget _buildCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.sp),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

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
                        LocaleKeys.orderReports.tr(),
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
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: InfoItemWidget(
                                name: item.name,
                                phone: item.phone,
                                bankName: item.bankName,
                                accountNumber: item.accountNumber,
                              ),
                            );
                          },
                        ),
                      )



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
                      //             3: FlexColumnWidth(),
                      //           },
                      //           children: [
                      //             // Header
                      //             TableRow(
                      //               children: [
                      //                 _buildHeaderCell(LocaleKeys.name.tr(), context),
                      //                 _buildHeaderCell(LocaleKeys.phone.tr(), context),
                      //                 _buildHeaderCell(LocaleKeys.bank_account.tr(), context),
                      //                 _buildHeaderCell(LocaleKeys.account_number.tr(), context),
                      //               ],
                      //             ),
                      //             // Rows من ليست
                      //             ...List.generate(
                      //               items.length,
                      //                   (index) {
                      //                 final item = items[index];
                      //                 return TableRow(
                      //                   children: [
                      //                     _buildCell(item.name),
                      //                     _buildCell(item.phone),
                      //                     _buildCell(item.bankName),
                      //                     _buildCell(item.accountNumber),
                      //                   ],
                      //                 );
                      //               },
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // )

                      //================================ start of code to be added later ==============================
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
                      //             3: FlexColumnWidth(),
                      //             4: FlexColumnWidth(),
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
                      //                     LocaleKeys.name.tr(),
                      //                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: Text(
                      //                     LocaleKeys.amount.tr(),
                      //                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: Text(
                      //                     LocaleKeys.price.tr(),
                      //                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                   child: Text(
                      //                     LocaleKeys.total.tr(),
                      //                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //             ...List.generate(
                      //               5,
                      //               (index) => TableRow(
                      //                 children: [
                      //                   Padding(
                      //                     padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                     child: Text(
                      //                       '${index + 1}',
                      //                       textAlign: TextAlign.center,
                      //                     ),
                      //                   ),
                      //                   Padding(
                      //                     padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                     child: const Text(
                      //                       'Arshik',
                      //                       textAlign: TextAlign.center,
                      //                     ),
                      //                   ),
                      //                   Padding(
                      //                     padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                     child: const Text(
                      //                       '10',
                      //                       textAlign: TextAlign.center,
                      //                     ),
                      //                   ),
                      //                   Padding(
                      //                     padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                     child: const Text(
                      //                       '123',
                      //                       textAlign: TextAlign.center,
                      //                     ),
                      //                   ),
                      //                   Padding(
                      //                     padding: EdgeInsets.symmetric(vertical: 12.sp),
                      //                     child: const Text(
                      //                       '1200',
                      //                       textAlign: TextAlign.center,
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // ============================== end of code =============================
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


class InfoItemWidget extends StatelessWidget {
  final String name;
  final String phone;
  final String bankName;
  final String accountNumber;

  const InfoItemWidget({
    super.key,
    required this.name,
    required this.phone,
    required this.bankName,
    required this.accountNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('${LocaleKeys.name.tr()}:', name, context),
          _buildInfoRow('${LocaleKeys.phone.tr()}:', phone, context),
          _buildInfoRow('${LocaleKeys.bank_account.tr()}:', bankName, context),
          _buildInfoRow('${LocaleKeys.account_number.tr()}:', accountNumber, context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp, // أكبر من العادي
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 16.sp, // نفس الحجم لكن مش Bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}


