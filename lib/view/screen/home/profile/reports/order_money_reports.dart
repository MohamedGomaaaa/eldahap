import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/model/report_2.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../components/app_bar_widget.dart';



class OrderMoneyReports extends StatelessWidget {
  final String type;

  const OrderMoneyReports({
    super.key,
    required this.type,
  });

  String _mapTypeToApiType() {
    if (type == LocaleKeys.depositReports) {
      return 'deposit';
    } else if (type == LocaleKeys.withdrawReports) {
      return 'withdraw';
    } else {
      return 'deposit';
    }
  }

  String _screenTitle() {
    if (type == LocaleKeys.withdrawReports) {
      return LocaleKeys.withdrawReports.tr();
    }
    return LocaleKeys.depositReports.tr();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: WalletCubit.get(context)..getReports(type: _mapTypeToApiType()),
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
//////////////////////////////////////////////////////////////////////////////////////////////  title
                          _screenTitle(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(),
                        ),
                        SizedBox(height: 6.h),
                        const Divider(
                          color: AppColors.textYellow,
                        ),
                        SizedBox(height: 6.h),
//////////////////////////////////////////////////////////////////////////////////////////////  list
                        Expanded(
                          child: BlocBuilder<WalletCubit, WalletState>(
                            buildWhen: (previous, current) {
                              return current is GetReportsLoadingState ||
                                  current is GetReportsSuccessState ||
                                  current is GetReportsErrorState;
                            },
                            builder: (context, state) {
                              final cubit = WalletCubit.get(context);

                              if (state is GetReportsLoadingState) {
                                return const Center(
                                  child: CircularProgressIndicator(color: AppColors.yellow,),
                                );
                              }

                              if (state is GetReportsErrorState) {
                                return Center(
                                  child: Text(
                                    state.msg.isNotEmpty
                                        ? state.msg
                                        : "Error loading reports",
                                  ),
                                );
                              }

                              if (cubit.reportsList.isEmpty) {
                                return Center(
                                  child: Text(
                                    type == LocaleKeys.withdrawReports
                                        ? "No withdraw reports found"
                                        : "No deposit reports found",
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                itemCount: cubit.reportsList.length,
                                itemBuilder: (context, index) {
                                  final report = cubit.reportsList[index];
                                  return CreatCard(report: report);
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

class CreatCard extends StatelessWidget {
  final ReportResult2 report;

  const CreatCard({
    super.key,
    required this.report,
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
          _buildInfoRow(
            label: LocaleKeys.id.tr(),
            value: report.id?.toString() ?? "",
            context: context,
          ),
          _buildInfoRow(
            label: LocaleKeys.details2.tr(),
            value: report.isApproval ?? "",
            context: context,
          ),




          _buildInfoRow(
            label: LocaleKeys.amount2.tr(),
            value: _formatAmount(report.amount),
            context: context,
          ),

          _buildInfoRow(
            label: LocaleKeys.currency,
            value: report.currency!,
            context: context,
          ),

          _buildInfoRow(
            label: LocaleKeys.paymentMethod.tr(),
            value: report.paymentMethod!,
            context: context,
          ),






          _buildInfoRow(
            label: LocaleKeys.approve_at.tr(),
            value:Methods.formatCreatedAt( report.approveAt!),
            context: context,
          ),
          _buildInfoRow(
            label: LocaleKeys.request_at.tr(),
            value: Methods.formatCreatedAt( report.requestAt!),
            context: context,
          ),
        ],
      ),
    );
  }

  String _formatAmount(String? amount) {
    if (amount == null || amount.isEmpty) return "";
    try {
      return Methods.removeTrailingZeros(num.parse(amount));
    } catch (_) {
      return amount;
    }
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required BuildContext context,
  }) {
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











