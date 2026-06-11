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
                                  child: CircularProgressIndicator(color: AppColors.yellow,),
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
                                    child: InfoItemWidget(type:type,
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
    required this.tradeOrOrder, required this.type,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [

          _buildInfoRow(
              label: LocaleKeys.id.tr(),
              value: tradeOrOrder.id!.toString(),
              context: context),



          _buildInfoRow(
              label: LocaleKeys.type.tr(),
              value: tradeOrOrder.type!,
              context: context),


          _buildInfoRow(
              label: LocaleKeys.productCategory.tr(),
              value: tradeOrOrder.product!.category!,
              context: context),
          _buildInfoRow(
              label: LocaleKeys.productName.tr(),
              value: tradeOrOrder.product!.name!,
              context: context),




          _buildInfoRow(
              label: LocaleKeys.metal.tr(),
              value: tradeOrOrder.metal!,
              context: context),

          _buildInfoRow(
              label: LocaleKeys.currency,
              value: tradeOrOrder.currency!,
              context: context),



          _buildInfoRow(
              label: LocaleKeys.OpenPrice.tr(),
              value: _formatAmount(

                  // type== LocaleKeys.orderReports.tr()?

                 // tradeOrOrder.openPriceOrder!.toString()

                 // :
                tradeOrOrder.openPrice!.toString()


              ),

              context: context),





          _buildInfoRow(
              label: LocaleKeys.productQuantity.tr(),
              value: tradeOrOrder.quantity!.toString(),
              context: context), // ممكن تبقي  qty




          _buildInfoRow(
              label: LocaleKeys.productQuantity.tr(),
              value: Methods.formatCreatedAt( tradeOrOrder.createdAt!.toString())
              ,
              context: context), //





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
  })
  {
    return Padding(
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
}

