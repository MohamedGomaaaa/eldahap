import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';

import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../components/app_bar_widget.dart';

class DepositReportsScreen extends StatelessWidget {
  const DepositReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: WalletCubit.get(context)..getDepositReports(),
      child: Scaffold(
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
                          LocaleKeys.depositReports.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(),
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
                          child: BlocBuilder<WalletCubit, WalletState>(
                            buildWhen: (previous, current) {
                              return current is GetDepositReportsLoadingState ||
                                  current is GetDepositReportsSuccessState ||
                                  current is GetDepositReportsErrorState;
                            },
                            builder: (context, state) {
                              WalletCubit cubit = WalletCubit.get(context);

                              if (state is GetDepositReportsLoadingState) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (state is GetDepositReportsErrorState) {
                                return Center(child: Text("Error loading reports"));
                              }

                              if (cubit.depositReports.isEmpty) {
                                return Center(child: Text("No deposit reports found"));
                              }

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                itemCount: cubit.depositReports.length,
                                itemBuilder: (context, index) {
                                  final report = cubit.depositReports[index];
                                  return DepositItemWidget(
                                    id: report.id.toString() ?? "",
                                    details: report.isApproval ?? "",
                                    amount: report.amount ?? "",
                                    dateAndTime: report.requestAt ?? "",
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
}
class DepositItemWidget extends StatelessWidget {
  final String id;
  final String details;
  final String amount;
  final String dateAndTime;

  const DepositItemWidget({
    super.key,
    required this.id,
    required this.details,
    required this.amount,
    required this.dateAndTime,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('d MMM yyyy, hh:mm a');
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
          _buildInfoRow("${LocaleKeys.no.tr()}:", id, context),
          _buildInfoRow("${LocaleKeys.detailsDeposit.tr()}:", details, context),
          _buildInfoRow("${LocaleKeys.amount.tr()}:", amount, context),
          _buildInfoRow("${LocaleKeys.dateAndTime.tr()}:", formatter.format(DateTime.parse(dateAndTime)), context),
        ],
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
