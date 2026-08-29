import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/locale_keys.g.dart';
import '../../../../model/metal_price_model.dart';
import '../../../../model/trade_order_model.dart';
import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/cubit/live_price_cubit/live_states.dart';

import '../../../../view_model/cubit/order_cubit/order_cubit.dart';
import '../../../../view_model/cubit/order_cubit/order_state.dart';
import '../../../../view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../view_model/utils/colors.dart';

import '../../../../view_model/utils/navigation.dart';
import '../../../../view_model/utils/toast.dart';
import '../../../../view_model/utils/validator.dart';
import '../../../components/app_loader.dart';
import '../../../components/creat_order_trade_details.dart';

import '../../../components/shimmer_widget.dart';
import '../../create_nav_bar/layout_screen.dart';
import '../../static_pages/static_page_screen.dart';

// class OrderDetailsScreen extends StatelessWidget {
//   final TradeOrOrder order;
//   final String productTitle;
//
//   const OrderDetailsScreen({
//     super.key,
//     required this.order,
//     required this.productTitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return OrderDetailsView(order: order, productTitle: productTitle);
//   }
// }

class OrderDetailsScreen extends StatefulWidget {
  final TradeOrOrder order;
  final String productTitle;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.productTitle,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final ApiService _appService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // @override
  // void initState() {
  //   super.initState();
  //
  //   context.read<TradesCubit>().getCommissionRate();
  // }
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final productTitle = widget.productTitle;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<LivePriceCubit, LivePriceState>(
        builder: (context, liveState) {
          // ✅ العملة حسب category index (0 => USD, 1 => EGP)
          final String currencyKey = order.currency ?? "USD";
          // ✅ تحديد نوع المعدن
          final String metalKey = (order.metal ?? 'XAU').toUpperCase();
          MetalPrices? mp;
          if (liveState is LivePriceLive) {
            mp = liveState.metals[metalKey]?[currencyKey];
          }
          final double livePrice =
              (mp?.buy ?? 0).toDouble() * (order.unitGramWeight ?? 1);
          final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;
          return BlocProvider(
            create: (BuildContext context) {
              return OrderCubit();
            },
            child: BlocConsumer<OrderCubit, OrderState>(
              listener: (context, state) {
                if (state is DeleteOrderSuccess) {
                  Toast.showMsg(msg: "order is successfully Deleted");
                  Navigation.pushAndRemoveUntil(
                    context,
                    const LayoutScreen(),
                  );
                }
              },
              builder: (BuildContext context, state) {
                OrderCubit orderCubit = OrderCubit.get(context);
                return (state is DeleteOrderLoading)
                    ? ShimmerWidget(
                        child: Container(
                          padding: EdgeInsets.all(12.sp),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.yellow2,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          SingleChildScrollView(
                            padding: EdgeInsets.all(16.sp),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

///////////////////////////////////////////////////////////////////////////////////////////// Creat Trade Order Details
                                  CreatTradeOrderDetails(
                                    productTitle: productTitle,
                                    tradeOrOrder: order,
                                    isOrder: true,
                                  ),
                                  SizedBox(height: 16.h),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////  delete
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    onTap: () {
                                      confirmBottomSheet(
                                        context: context,
                                        title: 'Delete order',
                                        onPressed: () {
                                          if (widget.order.status ==
                                                  "pending" &&
                                              widget.order.type == "order") {
                                            context
                                                .read<OrderCubit>()
                                                .deleteOrder(
                                                    orderId: widget.order.id);
                                          } else {
                                            Toast.showMsg(
                                                msg:
                                                    "this order is not pending");
                                          }
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.h),
                                      decoration: BoxDecoration(
                                        color: state is DeleteOrderLoading
                                            ? AppColors.grey.withOpacity(0.5)
                                            : AppColors.grey,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Delete order',
                                          style: TextStyle(
                                            color: AppColors.yellow,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////  stop lose section
                                  _buildStopLossSection(livePrice),
                                  SizedBox(height: 16.h),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////  take profit  section
                                  _buildTakeProfitSection(livePrice),
                                  SizedBox(height: 32.h),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////  save button
                                  _buildSaveButton(
                                      context, order.id!, orderCubit),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          ),
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ Overlay باهت لما مفيش Live
                          if (!hasLive)
                            Positioned.fill(
                              child: IgnorePointer(
                                ignoring: true, // مجرد لون فقط
                                child: Container(
                                  color: Colors.grey
                                      .withOpacity(0.35), // غير النسبة براحتك
                                ),
                              ),
                            ),
                        ],
                      );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
    bool? isAmount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.yellow,
            fontSize: 16.sp,
          ),
        ),
        isAmount == true
            ? Material(
                color: AppColors.transparent,
                borderRadius: BorderRadius.circular(8.sp),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.sp,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(
                      color: AppColors.blueColor,
                      width: 1.sp,
                    ),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppColors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    );
  }

  Widget _buildStopLossSection(double livePrice) {
    return BlocBuilder<OrderCubit, OrderState>(
      buildWhen: (previous, current) =>
          current is StopLossToggled ||
          current is StopLossAmountChanged ||
          current is OrderLoaded,
      builder: (context, state) {
        final cubit = context.read<OrderCubit>();
        return Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.yellowBorder,
              width: 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Stop loss',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Switch.adaptive(
                    value: cubit.stopLossEnabled,
                    onChanged: (value) => cubit.toggleStopLoss(value),
                    activeColor: AppColors.yellow,
                    inactiveThumbColor: AppColors.yellow,
                    inactiveTrackColor: AppColors.grey.withOpacity(0.8),
                  ),
                ],
              ),
              Visibility(
                visible: cubit.stopLossEnabled,
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.yellowBorder,
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        'Price',
                        style: TextStyle(
                          color: AppColors.yellow,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      validator: (value) => Validator.validateStopLoss(
                        openPrice: widget.order.openPrice!,
                        enteredValue: value,
                      ),
                      controller: cubit.stopLossController,
                      textInputAction: TextInputAction.done,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppColors.red),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 12.sp,
                        ),
                        isCollapsed: true,
                        alignLabelWithHint: true,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTakeProfitSection(double livePrice) {
    return BlocBuilder<OrderCubit, OrderState>(
      buildWhen: (previous, current) =>
          current is TakeProfitToggled ||
          current is TakeProfitAmountChanged ||
          current is OrderLoaded,
      builder: (context, state) {
        final cubit = context.read<OrderCubit>();
        return Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.yellowBorder,
              width: 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Take profit',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Switch.adaptive(
                    value: cubit.takeProfitEnabled,
                    onChanged: (value) => cubit.toggleTakeProfit(value),
                    activeColor: AppColors.yellow,
                    inactiveThumbColor: AppColors.yellow,
                    inactiveTrackColor: AppColors.grey.withOpacity(0.8),
                  ),
                ],
              ),
              Visibility(
                visible: cubit.takeProfitEnabled,
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.yellowBorder,
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        'Price',
                        style: TextStyle(
                          color: AppColors.yellow,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      validator: (value) => Validator.validateTakeProfit(
                        openPrice: widget.order.openPrice!,
                        enteredValue: value,
                        requiredField: cubit.takeProfitEnabled,
                      ),
                      controller: cubit.takeProfitController,
                      textInputAction: TextInputAction.done,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppColors.green),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onTapOutside: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 12.sp,
                        ),
                        isCollapsed: true,
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////// save order
  Widget _buildSaveButton(BuildContext context, int orderId, OrderCubit cubit) {
    return InkWell(
      onTap: () {
        confirmBottomSheet(
          context: context,
          title: "update trade",
          onPressed: () async {
            // ✅ لازم نعمل validate عشان الفاليديتر يظهر
            // if (cubit.stopLoss == true ||
            //     cubit.takeProfit == true) {
            //   final ok =
            //       cubit.formProductKey.currentState?.validate() ??
            //           false;
            //   if (!ok) return;
            // }

            if ((cubit.stopLossEnabled == false &&
                    cubit.takeProfitEnabled == false) ||
                (cubit.takeProfitController.text.trim().isEmpty &&
                    cubit.takeProfitEnabled == true) ||
                (cubit.stopLossController.text.trim().isEmpty &&
                    cubit.stopLossEnabled == true)) {
              Toast.showMsg(msg: LocaleKeys.canNotDoOpreation.tr());
              return;
            }

            AppLoader.showLoader(context, ValueKey("updateOrder"));

            if (cubit.takeProfitEnabled == false) {
              cubit.takeProfitController.text = "0";
            }
            if (cubit.stopLossEnabled == false) {
              cubit.stopLossController.text = "0";
            }

            try {
              await _appService.updateOrder(
                orderId: orderId ?? 0,
                stopLoss: double.parse(
                  cubit.stopLossController.text.isEmpty
                      ? "0"
                      : cubit.stopLossController.text,
                ),
                takeProfit: double.parse(
                  cubit.takeProfitController.text.isEmpty
                      ? "0"
                      : cubit.takeProfitController.text,
                ),
                ctx: context,
              );

              AppLoader.closeLoader(context, const ValueKey("updateOrder"));

              Navigation.push(context, LayoutScreen());
            } catch (e) {
              AppLoader.closeLoader(context, ValueKey("updateOrder"));
            }
          },
        );
      },

      // onTap: ()async{
      //   // FocusManager.instance.primaryFocus?.unfocus();
      //   // final ok = _formKey.currentState?.validate() ?? false;
      //   // if (!ok) return;
      //
      //   if(cubit.stopLossController.text.trim().isEmpty&&
      //
      //       ||
      //       cubit.takeProfitController.text.trim().isEmpty){
      //
      //
      //     Toast.showMsg(msg: "no changes to be saved");
      //   print(">>>>>>>>>>>>>>>>>>>>>>>>>>> ${cubit.stopLossController.text}");
      //
      //   print(">>>>>>>>>>>>>>>>>>>>>>>>>>> ${cubit.takeProfitController.text}");}
      //   else{
      //
      //
      //     confirmBottomSheet(
      //         context: context,
      //         title: "save changes",
      //         onPressed: () async {
      //           AppLoader.showLoader(
      //               context, const ValueKey("sell_price"));
      //           await _appService.updateOrder(
      //               orderId:orderId ?? 0, ctx: context, stopLoss: double.parse(cubit.stopLossController.text), takeProfit: double.parse(cubit.takeProfitController.text));
      //           Navigation.push(context, LayoutScreen()
      //       );
      //     });
      //
      //
      //
      //   }
      //
      //
      //
      // },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'Save Changes',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

void confirmBottomSheet({
  required BuildContext context,
  required String title,
  required void Function()? onPressed,
})
{
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ✅ اقفل الشيت الأول
                  Navigator.pop(sheetContext);

                  // ✅ وبعدها نفّذ الأكشن
                  onPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow2,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext, false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow2,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}
