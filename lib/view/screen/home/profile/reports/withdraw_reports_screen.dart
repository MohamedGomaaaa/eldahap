import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';

import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../app_bar/app_bar_widget.dart';

class WithDrawReportsScreen extends StatelessWidget {
  const WithDrawReportsScreen({super.key});

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTime); // assuming ISO string
      return DateFormat('d MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: WalletCubit.get(context)..getWithdrawReports(),
      child: Scaffold(
        body: GradientWidget(
          child: SafeArea(
            child: Column(
              children: [
                const AppBarCustom(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.sp),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),
                        Text(
                          LocaleKeys.withdrawReports.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 6.h),
                        const Divider(color: AppColors.textYellow),
                        SizedBox(height: 6.h),
                        Expanded(
                          child: BlocBuilder<WalletCubit, WalletState>(
                            builder: (context, state) {
                              final cubit = WalletCubit.get(context);

                              if (cubit.withdrawReports.isEmpty) {
                                return Center(
                                  child: Text(
                                    "LocaleKeys.noData.tr()",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }

                              return ListView.separated(
                                itemCount: cubit.withdrawReports.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 12.h),
                                itemBuilder: (context, index) {
                                  final report = cubit.withdrawReports[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(
                                          LocaleKeys.no.tr(),
                                          '${report.id ?? ''}',      context
                                        ),
                                        _buildInfoRow(
                                          LocaleKeys.detailsWithdraw.tr(),
                                          report.isApproval ?? '',      context
                                        ),
                                        _buildInfoRow(
                                          LocaleKeys.amount.tr(),
                                          report.amount ?? '',
                                          context
                                        ),
                                        _buildInfoRow(
                                          LocaleKeys.dateAndTime.tr(),
                                          formatDateTime(report.requestAt),      context
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
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
