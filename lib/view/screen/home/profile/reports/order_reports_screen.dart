import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../model/trade_order_model.dart';
import '../../../../../view_model/cubit/wallet_cubit/wallet_cubit.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../components/app_bar_widget.dart';

class OrderReportsScreen extends StatelessWidget {
  final String type;

  const OrderReportsScreen({
    super.key,
    required this.type,
  });

  String _mapTypeToApiType() {
    if (type == LocaleKeys.orderReports) {
      return 'pending';
    } else if (type == LocaleKeys.tradingReports) {
      return 'closed-trades';
    } else {
      return 'pending';
    }
  }

  String _screenTitle() {
    if (type == LocaleKeys.tradingReports) {
      return LocaleKeys.tradingReports.tr();
    }
    return LocaleKeys.orderReports.tr();
  }

  String _emptyText() {
    if (type == LocaleKeys.tradingReports) {
      return 'No closed trades found';
    }
    return 'No pending orders found';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: WalletCubit.get(context)
        ..getOrderReports(type: _mapTypeToApiType()),
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
                        Expanded(
                          child: BlocBuilder<WalletCubit, WalletState>(
                            buildWhen: (previous, current) {
                              return current is GetOrderReportsLoadingState ||
                                  current is GetOrderReportsSuccessState ||
                                  current is GetOrderReportsErrorState;
                            },
                            builder: (context, state) {
                              final cubit = WalletCubit.get(context);

                              if (state is GetOrderReportsLoadingState) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.yellow,
                                  ),
                                );
                              }

                              if (state is GetOrderReportsErrorState) {
                                return Center(
                                  child: Text(
                                    state.msg.isNotEmpty
                                        ? state.msg
                                        : 'Error loading reports',
                                  ),
                                );
                              }

                              if (cubit.orderReportsList.isEmpty) {
                                return Center(
                                  child: Text(_emptyText()),
                                );
                              }

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                itemCount: cubit.orderReportsList.length,
                                itemBuilder: (context, index) {
                                  final report = cubit.orderReportsList[index];
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    child: InfoItemWidget(
                                      type: type,
                                      tradeOrOrder: report,
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
}

class InfoItemWidget extends StatelessWidget {
  final TradeOrOrder tradeOrOrder;
  final String type;

  const InfoItemWidget({
    super.key,
    required this.tradeOrOrder,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final allData = <Widget>[
      _buildInfoRow(
        label: LocaleKeys.id.tr(),
        value: tradeOrOrder.id!.toString(),
        context: context,
      ),
      _buildInfoRow(
        label: LocaleKeys.type.tr(),
        value: tradeOrOrder.type!,
        context: context,
      ),
      _buildInfoRow(
        label: "Category",
        value: tradeOrOrder.product!.category!,
        context: context,
      ),
      _buildInfoRow(
        label: LocaleKeys.productName.tr(),
        value: tradeOrOrder.product!.name!,
        context: context,
      ),
      _buildInfoRow(
        label: LocaleKeys.metal.tr(),
        value: tradeOrOrder.metal!,
        context: context,
      ),
      _buildInfoRow(
        label: "Currency",
        value: tradeOrOrder.currency!,
        context: context,
      ),
      _buildInfoRow(
        label: "weight",
        value:
            "${Methods.removeTrailingZeros(tradeOrOrder.unitGramWeight!)} gm",
        context: context,
      ),
      _buildInfoRow(
        label: LocaleKeys.productQuantity.tr(),
        value: tradeOrOrder.quantity!.toString(),
        context: context,
      ),
      _buildInfoRow(
        label: "Open price",
        value: _formatAmount(
        tradeOrOrder.openPrice!.toString(),
          tradeOrOrder.currency!,
        ),
        context: context,
      ),
      // _buildInfoRow(
      //   label: "Enter price",
      //   value: _formatAmount(
      //     "${tradeOrOrder.entryPrice!}",
      //     tradeOrOrder.currency!,
      //   ),
      //   context: context,
      // ),
      _buildInfoRow(
        label: "Stop Lose",
        value: _formatAmount(
          tradeOrOrder.stopLoss!.toString(),
          tradeOrOrder.currency!,
        ),
        context: context,
      ),
      _buildInfoRow(
        label: "Take Profit",
        value: _formatAmount(
          tradeOrOrder.takeProfit!.toString(),
          tradeOrOrder.currency!,
        ),
        context: context,
      ),
      _buildInfoRow(
        label: "Sell When",
        value: _formatAmount(
          tradeOrOrder.sellWhenPrice!.toString(),
          tradeOrOrder.currency!,
        ),
        context: context,
      ),
      _buildInfoRow(
        label: "pnl",
        value: _formatAmount(
          tradeOrOrder.currency == "EGP"
              ? tradeOrOrder.pnlEgp!.toString()
              : tradeOrOrder.pnlUsd!.toString(),
          tradeOrOrder.currency!,
        ),
        context: context,
      ),
      _buildInfoRow(
        label: "close price",
        value: _formatAmount ((tradeOrOrder.closePrice!*tradeOrOrder.unitGramWeight!).toString(),

          tradeOrOrder.currency!,
        ),
        context: context,
      ),
      _buildInfoRow(
        label: "close kind",
        value: tradeOrOrder.closeKind!,
        context: context,
      ),
      _buildInfoRow(
        label: "Open Time",
        value: Methods.formatCreatedAt(
          tradeOrOrder.openTime!.toString(),
        ),
        context: context,
      ),
      _buildInfoRow(
        label: "close At",
        value: Methods.formatCreatedAt(
          tradeOrOrder.closedAt!.toString(),
        ),
        context: context,
      ),
      _buildInfoRow(
        label: LocaleKeys.creatAt.tr(),
        value: Methods.formatCreatedAt(
          tradeOrOrder.createdAt!.toString(),
        ),
        context: context,
      ),
    ];

    final previewItems = allData.take(3).toList();
    final remainingItems = allData.skip(3).toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ...previewItems,
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _showDetailsBottomSheet(context, remainingItems);
              },
              child: const Text("Details"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return (value.toString().trim().isEmpty)
        ? const SizedBox()
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.sp,
                        ),
                  ),
                ),
              ],
            ),
          );
  }

  String _formatAmount(String? amount, String currency) {
    if (amount == null || amount.isEmpty || amount == "0") {
      return "";
    }

    try {
      final value = Methods.removeTrailingZeros(num.parse(amount));

      return currency == "USD"
          ? "$value dollars"
          : currency == "EGP"
              ? "$value pounds"
              : value.toString();
    } catch (_) {
      return currency == "USD"
          ? "$amount dollars"
          : currency == "EGP"
              ? "$amount pounds"
              : amount ?? "";
    }
  }

  void _showDetailsBottomSheet(
    BuildContext context,
    List<Widget> items,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.grey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: EdgeInsets.all(16.w),
              children: items,
            );
          },
        );
      },
    );
  }
}
