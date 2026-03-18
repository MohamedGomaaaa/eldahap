import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/locale_keys.g.dart';
import '../../../../model/metal_price_model.dart';
import '../../../../model/trade_model.dart';
import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/cubit/live_price_cubit/live_states.dart';

import '../../../../view_model/utils/colors.dart';
import '../../../../view_model/utils/common_method.dart';
import '../../../../view_model/utils/navigation.dart';
import '../../../../view_model/utils/toast.dart';
import '../../../../view_model/utils/validator.dart';
import '../../../components/app_loader.dart';
import '../../../components/live_status_text.dart';
import '../../../components/live_text.dart';
import '../../../components/shimmer_widget.dart';
import '../../static_pages/static_page_screen.dart';
import '../layout_screen.dart';
import 'order_cubit.dart';
import 'order_state.dart';

class OrderDetailsScreen extends StatelessWidget {
  final TradeOrOrder order;
  final String productTitle;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.productTitle,
  });

  @override
  Widget build(BuildContext context) {
    return
      OrderDetailsView(order: order, productTitle: productTitle);
  }
}

class OrderDetailsView extends StatefulWidget {
  final TradeOrOrder order;
  final String productTitle;

  const OrderDetailsView({
    super.key,
    required this.order,
    required this.productTitle,
  });

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  final ApiService _appService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        title: Row(
          children: [
            SizedBox(width: 12.w),
            Text(
              "$productTitle ${order.unitGramWeight!} gm",
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<LivePriceCubit, LivePriceState>(
        builder: (context, liveState) {
          // ✅ العملة حسب category index (0 => USD, 1 => EGP)
          final String currencyKey = order.currency ?? "USD";
          MetalPrices? mp;
          if (liveState is LivePriceLive) {
            mp = liveState.metals[currencyKey];
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
                if (state is CloseOrderSuccessState) {
                  Toast.showMsg(msg: "order is successfully Deleted");
                  Navigation.pushAndRemoveUntil(
                    context,
                    const LayoutScreen(),
                  );
                }
              },
              builder: (BuildContext context, state) {
                OrderCubit orderCubit = OrderCubit.get(context);
                return (state is CloseOrderLoadingState)
                    ?ShimmerWidget(
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
//////////////////////////////////////////////////////////////////////////////////////////////////////// live socket status
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: const LiveStatusText(),
                                    ),
                                  ),
/////////////////////////////////////////////////////////////////////////////////////////// live price
                                  LivePriceText(
                                    padding: const EdgeInsets.all(10),
                                    price: livePrice,
                                    decimals: 2,
                                    fakeMinDelta: 0.01,
                                    fakeMaxDelta: 0.05,
                                    fakeTickEvery:
                                        const Duration(milliseconds: 900),
                                  ),
                                  SizedBox(height: 24.h),
                                  Column(
                                    children: [
//////////////////////////////////////////////////////////////////////////////////////////////////////// 'Amount to buy',
                                      _buildInfoRow(
                                        label: 'Amount to buy',
                                        value: '+${order.quantity ?? 0.5}',
                                        valueColor: AppColors.blueColor,
                                        isAmount: true,
                                      ),
                                      SizedBox(height: 16.h),
//////////////////////////////////////////////////////////////////////////////////////////////////////// type,
                                      _buildInfoRow(
                                        label: 'Type',
                                        value:
                                        order.sellWhenPrice! < livePrice
                                            ? 'Buy Limit'
                                            : "Buy Stop",
                                      ),
                                      SizedBox(height: 10.h),
  //////////////////////////////////////////////////////////////////////////////////////////////////////// date,
                                      _buildInfoRow(
                                        label: 'Created',
                                        value: Methods.formatCreatedAt(
                                                order.createdAt!.toString())
                                            .toString(),
                                      ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// open price
                                      SizedBox(height: 10.h),
                                      _buildInfoRow(
                                        label: "open price",
                                        value: Methods.removeTrailingZeros(
                                          (order.openPrice ?? 0) * livePrice,
                                        ),
                                      ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// trade size
                                      SizedBox(height: 10.h),
                                      _buildInfoRow(
                                        label: "trade size",
                                        value: Methods.removeTrailingZeros(
                                          (order.quantity ?? 0) * livePrice,
                                        ),
                                      ),

                                      order.takeProfit == null ||
                                          order.takeProfit == 0? const SizedBox():
                                      SizedBox(height: 10.h),
///////////////////////////////////////////////////////////////////////////////////////////////////////// take profit
                                      order.takeProfit == null ||
                                              order.takeProfit == 0
                                          ? const SizedBox()
                                          : _buildInfoRow(
                                              label: "take profit",
                                              value:
                                                  Methods.removeTrailingZeros(
                                                      order.takeProfit!),
                                            ),
 ///////////////////////////////////////////////////////////////////////////////////////////////////////// stop lose
                                      order.stopLoss == null ||
                                          order.stopLoss == 0?const SizedBox():

                                      SizedBox(height: 10.h),
                                      order.stopLoss == null ||
                                              order.stopLoss == 0
                                          ? const SizedBox()
                                          : _buildInfoRow(
                                              label: "stop lose",
                                              value:
                                                  Methods.removeTrailingZeros(
                                                      order.stopLoss!),
                                            ),
////////////////////////////////////////////////////////////////////////////////////////////////////////  buy when == open price
                                      order.sellWhenPrice == null ||
                                          order.sellWhenPrice == 0?const SizedBox():
                                      SizedBox(height: 10.h),
                                      order.sellWhenPrice == null ||
                                              order.sellWhenPrice == 0
                                          ? const SizedBox()
                                          : _buildInfoRow(
                                              label: "buy when price is ",
                                              value:
                                                  Methods.removeTrailingZeros(
                                                      order.sellWhenPrice!),
                                            ),
                                    ],
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
                                          // Navigator.pop(context); // اقفل البوتوم شيت
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
                                        color: state is CloseOrderLoadingState
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
                                  _buildSaveButton(context,order.id!,orderCubit),
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
                        enteredValue: value,
                        livePrice: livePrice,
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
                        enteredValue: value,
                        livePrice: livePrice,
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
  Widget _buildSaveButton(BuildContext context,int orderId,OrderCubit cubit) {
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
              Toast.showMsg(
                  msg: LocaleKeys.canNotDoOpreation.tr());
              return;
            }

            AppLoader.showLoader(
                context, ValueKey("updateOrder"));

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

              AppLoader.closeLoader(
                  context, const ValueKey("updateOrder"));

              Navigation.push(context, LayoutScreen());
            } catch (e) {
              AppLoader.closeLoader(
                  context, ValueKey("updateOrder"));
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
}) {
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

// class OrderDetailsScreen extends StatelessWidget {
//   final TradeOrOrder order;
//   final String productTitle;
//
//   const OrderDetailsScreen(
//       {super.key, required this.order, required this.productTitle});
//
//   @override
//   Widget build(BuildContext context) {
//     return OrderDetailsView(order: order, productTitle: productTitle);
//   }
// }
//
// class OrderDetailsView extends StatelessWidget {
//   final TradeOrOrder order;
//   final String productTitle;
//   OrderDetailsView(
//       {super.key, required this.order, required this.productTitle});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             SizedBox(width: 12.w),
//             Text(
//               "$productTitle ${order.unitGramWeight!} gm",
//               style: TextStyle(
//                 color: AppColors.yellow,
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: BlocBuilder<LivePriceCubit, LivePriceState>(
//         builder: (context, liveState) {
//           // ✅ العملة حسب category index (0 => USD, 1 => EGP)
//           final String currencyKey = order.currency ?? "USD";
//           MetalPrices? mp;
//           if (liveState is LivePriceLive) {
//             mp = liveState.metals[currencyKey];
//           }
//           final double livePrice =
//               (mp?.buy ?? 0).toDouble() * (order.unitGramWeight ?? 1);
//           final double openPrice = (order.openPrice ?? 0).toDouble();
//           // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
//           final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;
//
//           return Stack(
//             children: [
//               SingleChildScrollView(
//                 padding: EdgeInsets.all(16.sp),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// live socket status
//                     Center(
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 10),
//                         child: const LiveStatusText(),
//                       ),
//                     ),
// /////////////////////////////////////////////////////////////////////////////////////////// live price
//                     LivePriceText(
//                       padding: const EdgeInsets.all(10),
//                       price: livePrice,
//                       decimals: 2,
//                       fakeMinDelta: 0.01,
//                       fakeMaxDelta: 0.05,
//                       fakeTickEvery: const Duration(milliseconds: 900),
//                     ),
//                     SizedBox(height: 24.h),
//                     Column(
//                       children: [
// //////////////////////////////////////////////////////////////////////////////////////////////////////// 'Amount to buy',
//                         _buildInfoRow(
//                             label: 'Amount to buy',
//                             value: '+${order.quantity ?? 0.5}',
//                             valueColor: AppColors.blueColor,
//                             isAmount: true),
//                         SizedBox(height: 16.h),
// //////////////////////////////////////////////////////////////////////////////////////////////////////// type,
//                         _buildInfoRow(
//                             label: 'Type',
//                             value: order.openPrice! < livePrice
//                                 ? ' Buy Limit'
//                                 : "Buy Stop"),
//                         SizedBox(height: 10.h),
// //////////////////////////////////////////////////////////////////////////////////////////////////////// date,
//                         _buildInfoRow(
//                           label: 'Created',
//                           value: Methods.formatCreatedAt(
//                                   order.createdAt!.toString())
//                               .toString(),
//                         ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// take size
//                         SizedBox(height: 10.h),
//                         _buildInfoRow(
//                           label: "take size",
//                           value: Methods.removeTrailingZeros(
//                             (order.quantity ?? 0) * livePrice,
//                           ),
//                         ),
//                         SizedBox(height: 10.h),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// take profit
//                         order.takeProfit == null || order.takeProfit == 0
//                             ? const SizedBox()
//                             : _buildInfoRow(
//                                 label: "take profit",
//                                 value: Methods.removeTrailingZeros(
//                                     order.takeProfit!),
//                               ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// stop lose
//                         order.stopLoss == null || order.stopLoss == 0
//                             ? const SizedBox()
//                             : _buildInfoRow(
//                                 label: "stop lose",
//                                 value: Methods.removeTrailingZeros(
//                                     order.stopLoss!),
//                               ),
// /////////////////////////////////////////////////////////////////////////////////////////////////////////  buy when == open price
//                         SizedBox(height: 10.h),
//                         order.sellWhenPrice == null || order.sellWhenPrice == 0
//                             ? const SizedBox()
//                             : _buildInfoRow(
//                                 label: "buy when price is ",
//                                 value: Methods.removeTrailingZeros(
//                                     order.sellWhenPrice!),
//                               ),
//                       ],
//                     ),
//                     SizedBox(height: 16.h),
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////  delete
//                     BlocListener<trades.TradesCubit, trades.TradesState>(
//                       listener: (context, state) {
//                         if (state is CloseOrderSuccessState) {
//                           Navigator.pop(context);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Order deleted successfully'),
//                               backgroundColor: AppColors.green,
//                             ),
//                           );
//                         }
//                       },
//                       child: _buildDeleteButton(context, order.id),
//                     ),
//
//                     SizedBox(height: 24.h),
//                      _buildStopLossSection(),
//                     SizedBox(height: 16.h),
//                     _buildTakeProfitSection(),
//                     SizedBox(height: 32.h),
//                     _buildSaveButton(context),
//                   ],
//                 ),
//               ),
//               // ✅ Overlay باهت لما مفيش Live
//               if (!hasLive)
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     ignoring: true, // مجرد لون فقط
//                     child: Container(
//                       color: Colors.grey.withOpacity(0.35), // غير النسبة براحتك
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//
//
//   Widget _buildInfoRow(
//       {required String label,
//       required String value,
//       Color? valueColor,
//       bool? isAmount})
//   {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: AppColors.yellow,
//             fontSize: 16.sp,
//           ),
//         ),
//         isAmount == true
//             ? Material(
//                 color: AppColors.transparent,
//                 borderRadius: BorderRadius.circular(8.sp),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 14.sp,
//                     vertical: 5.h,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.sp),
//                     border: Border.all(
//                       color: AppColors.blueColor,
//                       width: 1.sp,
//                     ),
//                   ),
//                   child: Text(
//                     value,
//                     style: const TextStyle(
//                       color: AppColors.white,
//                     ),
//                   ),
//                 ),
//               )
//             : Text(
//                 value,
//                 style: TextStyle(
//                   color: valueColor ?? AppColors.white,
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ],
//     );
//   }
//
//   Widget _buildDeleteButton(BuildContext context, orderId) {
//     return InkWell(
//       onTap: () {
//         confirmBottomSheet(
//             context: context,
//             title: 'Delete order',
//             onPressed: () {
//               if (order.status == "pending" && order.type == "order") {
//                 context
//                     .read<trades.TradesCubit>()
//                     .closeOrder(orderId: order.id);
//                 Navigation.push(context, LayoutScreen());
//               } else {
//                 Toast.showMsg(msg: "this order is not pending");
//               }
//             });
//       },
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 16.h),
//         decoration: BoxDecoration(
//           color: AppColors.grey,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Center(
//           child: Text(
//             'Delete order',
//             style: TextStyle(
//               color: AppColors.yellow,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildStopLossSection() {
//     return BlocBuilder<OrderCubit, OrderState>(
//       buildWhen: (previous, current) =>
//           current is StopLossToggled ||
//           current is StopLossAmountChanged ||
//           current is OrderLoaded,
//       builder: (context, state) {
//         final cubit = context.read<OrderCubit>();
//         return Container(
//           padding: EdgeInsets.all(12.sp),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.yellowBorder,
//               width: 1.w,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Stop loss',
//                       style: TextStyle(
//                         color: AppColors.yellow,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Switch.adaptive(
//                     value: cubit.stopLossEnabled,
//                     onChanged: (value) => cubit.toggleStopLoss(value),
//                     activeColor: AppColors.yellow,
//                     inactiveThumbColor: AppColors.yellow,
//                     inactiveTrackColor: AppColors.grey.withOpacity(0.8),
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: cubit.stopLossEnabled,
//                 child: Column(
//                   children: [
//                     SizedBox(height: 12.h),
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(8.sp),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppColors.yellowBorder,
//                           width: 1.w,
//                         ),
//                       ),
//                       child: Text(
//                         'Price',
//                         style: TextStyle(
//                           color: AppColors.yellow,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12.h),
//                     TextFormField(
//                       validator: (value) => Validator.validateStopLoss(
//                         value: value,
//                         livePrice: 1233,
//                       ),
//                       controller: cubit.stopLossController,
//                       textInputAction: TextInputAction.done,
//                       style: TextStyle(
//                         color: AppColors.red,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       keyboardType:
//                           const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(
//                             RegExp(r'^\d+\.?\d{0,2}')),
//                       ],
//                       onTapOutside: (_) => FocusScope.of(context).unfocus(),
//                       decoration: InputDecoration(
//                         hintText: '0',
//                         hintStyle: TextStyle(
//                           color: AppColors.red,
//                           fontSize: 18.sp,
//                         ),
//
//                         isDense: true,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12.sp,
//                           vertical: 12.sp,
//                         ),
//                         isCollapsed: true,
//                         alignLabelWithHint: true,
//
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTakeProfitSection() {
//     return BlocBuilder<OrderCubit, OrderState>(
//       buildWhen: (previous, current) =>
//           current is TakeProfitToggled ||
//           current is TakeProfitAmountChanged ||
//           current is OrderLoaded,
//       builder: (context, state) {
//         final cubit = context.read<OrderCubit>();
//         return Container(
//           padding: EdgeInsets.all(12.sp),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.yellowBorder,
//               width: 1.w,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Take profit',
//                       style: TextStyle(
//                         color: AppColors.yellow,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Switch.adaptive(
//                     value: cubit.takeProfitEnabled,
//                     onChanged: (value) => cubit.toggleTakeProfit(value),
//                     activeColor: AppColors.yellow,
//                     inactiveThumbColor: AppColors.yellow,
//                     inactiveTrackColor: AppColors.grey.withOpacity(0.8),
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: cubit.takeProfitEnabled,
//                 child: Column(
//                   children: [
//                     SizedBox(height: 12.h),
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(8.sp),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppColors.yellowBorder,
//                           width: 1.w,
//                         ),
//                       ),
//                       child: Text(
//                         'Price',
//                         style: TextStyle(
//                           color: AppColors.yellow,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12.h),
//                     TextFormField(
//                       validator: (value) => Validator.validateTakeProfit(
//                         value: value,
//                         livePrice: 123,
//                         // liveOpenPrice,
//                         // requiredField:
//                         // cubit.takeProfitController,
//                       ),
//                       controller: cubit.takeProfitController,
//                       textInputAction: TextInputAction.done,
//                       style: TextStyle(
//                         color: AppColors.green,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       keyboardType:
//                           const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(
//                             RegExp(r'^\d+\.?\d{0,2}')),
//                       ],
//                       onTapOutside: (_) => FocusScope.of(context).unfocus(),
//                       decoration: InputDecoration(
//                         hintText: '0',
//                         hintStyle: TextStyle(
//                           color: AppColors.green,
//                           fontSize: 18.sp,
//                         ),
//                         // prefix: Text(
//                         //   '\$',
//                         //   style: TextStyle(
//                         //     color: AppColors.red,
//                         //     fontSize: 18.sp,
//                         //     fontWeight: FontWeight.bold,
//                         //   ),
//                         // ),
//                         isDense: true,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12.sp,
//                           vertical: 12.sp,
//                         ),
//                         isCollapsed: true,
//                         alignLabelWithHint: true,
//                         // suffix: Row(
//                         //   mainAxisSize: MainAxisSize.min,
//                         //   children: [
//                         //     FloatingActionButton(
//                         //       onPressed: () => cubit.subtractTakeProfitAmount(),
//                         //       heroTag: 'takeProfitMinus',
//                         //       shape: const CircleBorder(),
//                         //       mini: true,
//                         //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         //       backgroundColor: AppColors.transparent,
//                         //       elevation: 0,
//                         //       child: const Icon(
//                         //         FontAwesomeIcons.minus,
//                         //         color: AppColors.white,
//                         //       ),
//                         //     ),
//                         //     FloatingActionButton(
//                         //       onPressed: () => cubit.addTakeProfitAmount(),
//                         //       heroTag: 'takeProfitPlus',
//                         //       shape: const CircleBorder(),
//                         //       mini: true,
//                         //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         //       backgroundColor: AppColors.transparent,
//                         //       elevation: 0,
//                         //       child: const Icon(
//                         //         FontAwesomeIcons.plus,
//                         //         color: AppColors.white,
//                         //       ),
//                         //     ),
//                         //   ],
//                         // ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////// save order
//   Widget _buildSaveButton(BuildContext context) {
//     return InkWell(
//       onTap: () => context.read<OrderCubit>().saveOrder(),
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 16.h),
//         decoration: BoxDecoration(
//           color: AppColors.yellow,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Center(
//           child: Text(
//             'Save Changes',
//             style: TextStyle(
//               color: AppColors.black,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// void confirmBottomSheet(
//     {required BuildContext context,
//     required String title,
//     required void Function()? onPressed})
// {
//   showModalBottomSheet(
//     context: context,
//     isDismissible: false,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: onPressed,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.yellow2,
//                   foregroundColor: AppColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   title,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, false);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.yellow2,
//                   foregroundColor: AppColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       );
//     },
//   );
// }

//////////////////////////////////////////////////////////////////////////////////////////////// before live

// class OrderDetailsScreen extends StatelessWidget {
//   final TradeOrOrder order;
//   final String productTitle;
//
//   const OrderDetailsScreen(
//       {super.key, required this.order, required this.productTitle});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => OrderCubit()..loadOrder(order),
//       child: OrderDetailsView(order: order, productTitle: productTitle),
//     );
//   }
// }
//
// final num live = 44554;
//
// class OrderDetailsView extends StatelessWidget {
//   final TradeOrOrder order;
//   final String productTitle;
//   OrderDetailsView(
//       {super.key, required this.order, required this.productTitle});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: BlocBuilder<OrderCubit, OrderState>(
//           builder: (context, state) {
//             final cubit = context.read<OrderCubit>();
//             final order = cubit.currentOrder;
//             return Row(
//               children: [
//                 // Container(
//                 //   padding: EdgeInsets.all(8.sp),
//                 //   decoration: BoxDecoration(
//                 //     color: AppColors.grey,
//                 //     borderRadius: BorderRadius.circular(8.r),
//                 //   ),
//                 //   child: Text(
//                 //     order?.productIcon ?? '🏅',
//                 //     style: TextStyle(fontSize: 20.sp),
//                 //   ),
//                 // ),
//                 SizedBox(width: 12.w),
//                 Text(
//                   "$productTitle ${order!.unitGramWeight!} gm",
//                   style: TextStyle(
//                     color: AppColors.yellow,
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//       body: BlocListener<OrderCubit, OrderState>(
//         listener: (context, state) {
//           if (state is OrderDeleted) {
//             Navigator.pop(context);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Order deleted successfully'),
//                 backgroundColor: AppColors.green,
//               ),
//             );
//           }
//         },
//         child: BlocBuilder<LivePriceCubit, LivePriceState>(
//           builder: (context, liveState) {
//             // ✅ العملة حسب category index (0 => USD, 1 => EGP)
//             final String currencyKey = order.currency ?? "USD";
//             MetalPrices? mp;
//             if (liveState is LivePriceLive) {
//               mp = liveState.metals[currencyKey];
//             }
//
//             final double livePrice =
//                 (mp?.buy ?? 0).toDouble() * (order.unitGramWeight ?? 1);
//
//             final double openPrice = (order.openPrice ?? 0).toDouble();
//
//             // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
//             final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;
//
//             final double pnl =
//                 (livePrice - openPrice) * (order.quantity ?? 0).toDouble();
//
//             final bool isProfit = pnl >= 0;
//
//             return Stack(
//               children: [
//                 SingleChildScrollView(
//                   padding: EdgeInsets.all(16.sp),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildPriceSection(),
//                       SizedBox(height: 24.h),
//                       _buildInfoSection(),
//                       SizedBox(height: 24.h),
//                       // _buildOrderDetailsButton(context),
//                       SizedBox(height: 16.h),
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////  delete
//
//                       BlocListener<trades.TradesCubit, trades.TradesState>(
//                         listener: (context, state) {
//                           if (state is CloseOrderSuccessState) {
//                             Navigator.pop(context);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Order deleted successfully'),
//                                 backgroundColor: AppColors.green,
//                               ),
//                             );
//                           }
//                         },
//                         child: _buildDeleteButton(context, order.id),
//                       ),
//
//                       SizedBox(height: 24.h),
//                       _buildBuyWhenSection(),
//                       SizedBox(height: 24.h),
//                       _buildStopLossSection(),
//                       SizedBox(height: 16.h),
//                       _buildTakeProfitSection(),
//                       SizedBox(height: 32.h),
//                       _buildSaveButton(context),
//                     ],
//                   ),
//                 ),
//                 // ✅ Overlay باهت لما مفيش Live
//                 if (!hasLive)
//                   Positioned.fill(
//                     child: IgnorePointer(
//                       ignoring: true, // مجرد لون فقط
//                       child: Container(
//                         color:
//                         Colors.grey.withOpacity(0.35), // غير النسبة براحتك
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPriceSection() {
//     return BlocBuilder<OrderCubit, OrderState>(
//       builder: (context, state) {
//         final order = context.read<OrderCubit>().currentOrder;
//         return Center(
//           child: Text(
//             " live*gm",
//             // order?.currentPrice.toStringAsFixed(2) ?? '3,857.36',
//             style: TextStyle(
//               color: AppColors.yellow,
//               fontSize: 36.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildInfoSection() {
//     return BlocBuilder<OrderCubit, OrderState>(
//       builder: (context, state) {
//         final order = context.read<OrderCubit>().currentOrder;
//         return Column(
//           children: [
//             _buildInfoRow(
//                 label: 'Amount to buy',
//                 value: '+${order?.quantity ?? 0.5}',
//                 valueColor: AppColors.blueColor,
//                 isAmount: true),
//             SizedBox(height: 16.h),
//             _buildInfoRow(
//                 label: 'Type',
//                 value: order!.openPrice! < live ? ' Buy Limit' : "Buy Stop"),
//             SizedBox(height: 16.h),
//             _buildInfoRow(
//               label: 'Created',
//               value: Methods.formatCreatedAt(order.createdAt!.toString())
//                   .toString(),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildInfoRow(
//       {required String label,
//         required String value,
//         Color? valueColor,
//         bool? isAmount}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: AppColors.yellow,
//             fontSize: 16.sp,
//           ),
//         ),
//         isAmount == true
//             ? Material(
//           color: AppColors.transparent,
//           borderRadius: BorderRadius.circular(8.sp),
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: 14.sp,
//               vertical: 5.h,
//             ),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.sp),
//               border: Border.all(
//                 color: AppColors.blueColor,
//                 width: 1.sp,
//               ),
//             ),
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: AppColors.white,
//               ),
//             ),
//           ),
//         )
//             : Text(
//           value,
//           style: TextStyle(
//             color: valueColor ?? AppColors.white,
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Widget _buildOrderDetailsButton(BuildContext context) {
//   //   return InkWell(
//   //     onTap: () => _showOrderDetailsSheet(context),
//   //     child: Row(
//   //       children: [
//   //         Text(
//   //           'Order details',
//   //           style: TextStyle(
//   //             color: AppColors.white,
//   //             fontSize: 16.sp,
//   //           ),
//   //         ),
//   //         SizedBox(width: 8.w),
//   //         Icon(
//   //           Icons.info_outline,
//   //           color: AppColors.yellow,
//   //           size: 20.sp,
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   Widget _buildDeleteButton(BuildContext context, orderId) {
//     return InkWell(
//       onTap: () {
//         if (order.status == "pending" && order.type == "order") {
//           context.read<trades.TradesCubit>().closeOrder(orderId: order.id);
//           Navigator.pop(context, true);
//         } else {
//           Toast.showMsg(msg: "this order is not pending");
//         }
//       },
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 16.h),
//         decoration: BoxDecoration(
//           color: AppColors.grey,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Center(
//           child: Text(
//             'Delete order',
//             style: TextStyle(
//               color: AppColors.yellow,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBuyWhenSection() {
//     return BlocBuilder<OrderCubit, OrderState>(
//       builder: (context, state) {
//         final order = context.read<OrderCubit>().currentOrder;
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Buy when price is',
//               style: TextStyle(
//                 color: AppColors.yellow,
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.grey),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     order?.openPrice?.toStringAsFixed(2) ?? '000',
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontSize: 24.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () {},
//                         icon: Icon(FontAwesomeIcons.minus,
//                             color: AppColors.white),
//                       ),
//                       IconButton(
//                         onPressed: () {},
//                         icon:
//                         Icon(FontAwesomeIcons.plus, color: AppColors.white),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // SizedBox(height: 16.h),
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //   children: [
//             //     Text(
//             //       'Good till',
//             //       style: TextStyle(
//             //         color: AppColors.greyText,
//             //         fontSize: 16.sp,
//             //       ),
//             //     ),
//             //     TextButton.icon(
//             //       onPressed: () {},
//             //       icon: Icon(Icons.add_circle_outline, color: AppColors.yellow),
//             //       label: Text(
//             //         'Add date',
//             //         style: TextStyle(color: AppColors.yellow),
//             //       ),
//             //     ),
//             //   ],
//             // ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildStopLossSection() {
//     return BlocBuilder<OrderCubit, OrderState>(
//       buildWhen: (previous, current) =>
//       current is StopLossToggled ||
//           current is StopLossAmountChanged ||
//           current is OrderLoaded,
//       builder: (context, state) {
//         final cubit = context.read<OrderCubit>();
//         return Container(
//           padding: EdgeInsets.all(12.sp),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.yellowBorder,
//               width: 1.w,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Stop loss',
//                       style: TextStyle(
//                         color: AppColors.yellow,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Switch.adaptive(
//                     value: cubit.stopLossEnabled,
//                     onChanged: (value) => cubit.toggleStopLoss(value),
//                     activeColor: AppColors.yellow,
//                     inactiveThumbColor: AppColors.yellow,
//                     inactiveTrackColor: AppColors.grey.withOpacity(0.8),
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: cubit.stopLossEnabled,
//                 child: Column(
//                   children: [
//                     SizedBox(height: 12.h),
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(8.sp),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppColors.yellowBorder,
//                           width: 1.w,
//                         ),
//                       ),
//                       child: Text(
//                         'Price',
//                         style: TextStyle(
//                           color: AppColors.yellow,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12.h),
//                     TextFormField(
//                       validator: (value) => Validator.validateStopLoss(
//                         value: value,
//                         livePrice: 1233,
//                       ),
//                       controller: cubit.stopLossController,
//                       textInputAction: TextInputAction.done,
//                       style: TextStyle(
//                         color: AppColors.red,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(
//                             RegExp(r'^\d+\.?\d{0,2}')),
//                       ],
//                       onTapOutside: (_) => FocusScope.of(context).unfocus(),
//                       decoration: InputDecoration(
//                         hintText: '0',
//                         hintStyle: TextStyle(
//                           color: AppColors.red,
//                           fontSize: 18.sp,
//                         ),
//                         // prefix: Text(
//                         //   '\$',
//                         //   style: TextStyle(
//                         //     color: AppColors.red,
//                         //     fontSize: 18.sp,
//                         //     fontWeight: FontWeight.bold,
//                         //   ),
//                         // ),
//                         isDense: true,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12.sp,
//                           vertical: 12.sp,
//                         ),
//                         isCollapsed: true,
//                         alignLabelWithHint: true,
//                         // suffix: Row(
//                         //   mainAxisSize: MainAxisSize.min,
//                         //   children: [
//                         //     FloatingActionButton(
//                         //       onPressed: () => cubit.subtractStopLossAmount(),
//                         //       heroTag: 'stopLossMinus',
//                         //       shape: const CircleBorder(),
//                         //       mini: true,
//                         //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         //       backgroundColor: AppColors.transparent,
//                         //       elevation: 0,
//                         //       child: const Icon(
//                         //         FontAwesomeIcons.minus,
//                         //         color: AppColors.white,
//                         //       ),
//                         //     ),
//                         //     FloatingActionButton(
//                         //       onPressed: () => cubit.addStopLossAmount(),
//                         //       heroTag: 'stopLossPlus',
//                         //       shape: const CircleBorder(),
//                         //       mini: true,
//                         //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         //       backgroundColor: AppColors.transparent,
//                         //       elevation: 0,
//                         //       child: const Icon(
//                         //         FontAwesomeIcons.plus,
//                         //         color: AppColors.white,
//                         //       ),
//                         //     ),
//                         //   ],
//                         // ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTakeProfitSection() {
//     return BlocBuilder<OrderCubit, OrderState>(
//       buildWhen: (previous, current) =>
//       current is TakeProfitToggled ||
//           current is TakeProfitAmountChanged ||
//           current is OrderLoaded,
//       builder: (context, state) {
//         final cubit = context.read<OrderCubit>();
//         return Container(
//           padding: EdgeInsets.all(12.sp),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: AppColors.yellowBorder,
//               width: 1.w,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Take profit',
//                       style: TextStyle(
//                         color: AppColors.yellow,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Switch.adaptive(
//                     value: cubit.takeProfitEnabled,
//                     onChanged: (value) => cubit.toggleTakeProfit(value),
//                     activeColor: AppColors.yellow,
//                     inactiveThumbColor: AppColors.yellow,
//                     inactiveTrackColor: AppColors.grey.withOpacity(0.8),
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: cubit.takeProfitEnabled,
//                 child: Column(
//                   children: [
//                     SizedBox(height: 12.h),
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(8.sp),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppColors.yellowBorder,
//                           width: 1.w,
//                         ),
//                       ),
//                       child: Text(
//                         'Price',
//                         style: TextStyle(
//                           color: AppColors.yellow,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12.h),
//                     TextFormField(
//                       validator: (value) => Validator.validateTakeProfit(
//                         value: value,
//                         livePrice: 123,
//                         // liveOpenPrice,
//                         // requiredField:
//                         // cubit.takeProfitController,
//                       ),
//                       controller: cubit.takeProfitController,
//                       textInputAction: TextInputAction.done,
//                       style: TextStyle(
//                         color: AppColors.green,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(
//                             RegExp(r'^\d+\.?\d{0,2}')),
//                       ],
//                       onTapOutside: (_) => FocusScope.of(context).unfocus(),
//                       decoration: InputDecoration(
//                         hintText: '0',
//                         hintStyle: TextStyle(
//                           color: AppColors.green,
//                           fontSize: 18.sp,
//                         ),
//                         // prefix: Text(
//                         //   '\$',
//                         //   style: TextStyle(
//                         //     color: AppColors.red,
//                         //     fontSize: 18.sp,
//                         //     fontWeight: FontWeight.bold,
//                         //   ),
//                         // ),
//                         isDense: true,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12.sp,
//                           vertical: 12.sp,
//                         ),
//                         isCollapsed: true,
//                         alignLabelWithHint: true,
//                         // suffix: Row(
//                         //   mainAxisSize: MainAxisSize.min,
//                         //   children: [
//                         //     FloatingActionButton(
//                         //       onPressed: () => cubit.subtractTakeProfitAmount(),
//                         //       heroTag: 'takeProfitMinus',
//                         //       shape: const CircleBorder(),
//                         //       mini: true,
//                         //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         //       backgroundColor: AppColors.transparent,
//                         //       elevation: 0,
//                         //       child: const Icon(
//                         //         FontAwesomeIcons.minus,
//                         //         color: AppColors.white,
//                         //       ),
//                         //     ),
//                         //     FloatingActionButton(
//                         //       onPressed: () => cubit.addTakeProfitAmount(),
//                         //       heroTag: 'takeProfitPlus',
//                         //       shape: const CircleBorder(),
//                         //       mini: true,
//                         //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         //       backgroundColor: AppColors.transparent,
//                         //       elevation: 0,
//                         //       child: const Icon(
//                         //         FontAwesomeIcons.plus,
//                         //         color: AppColors.white,
//                         //       ),
//                         //     ),
//                         //   ],
//                         // ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                           borderSide: const BorderSide(color: AppColors.yellow),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// save order
//   Widget _buildSaveButton(BuildContext context) {
//     return InkWell(
//       onTap: () => context.read<OrderCubit>().saveOrder(),
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 16.h),
//         decoration: BoxDecoration(
//           color: AppColors.yellow,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Center(
//           child: Text(
//             'Save Changes',
//             style: TextStyle(
//               color: AppColors.black,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
// // void _showOrderDetailsSheet(BuildContext context) {
// //   final cubit = context.read<OrderCubit>();
// //   final order = cubit.currentOrder;
// //
// //   showModalBottomSheet(
// //     context: context,
// //     backgroundColor: AppColors.grey,
// //     shape: RoundedRectangleBorder(
// //       borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// //     ),
// //     builder: (context) => Container(
// //       padding: EdgeInsets.all(24.sp),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Text(
// //             'Order details',
// //             style: TextStyle(
// //               color: AppColors.white,
// //               fontSize: 20.sp,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           SizedBox(height: 24.h),
// //           _buildSheetRow(
// //             'Trade size',
// //             '\$${order?.tradeSize.toStringAsFixed(2) ?? '1,750.00'}',
// //             hasInfo: true,
// //           ),
// //           Divider(color: AppColors.lightGrey, height: 32.h),
// //           _buildSheetRow(
// //             'Leverage',
// //             order?.leverage ?? ' 1:1 ',
// //           ),
// //           // Divider(color: AppColors.lightGrey, height: 32.h),
// //           // _buildSheetRow(
// //           //   'Margin',
// //           //   '\$${order?.margin.toStringAsFixed(2) ?? '17.50'}',
// //           //   hasInfo: true,
// //           // ),
// //           Divider(color: AppColors.lightGrey, height: 32.h),
// //           _buildSheetRow(
// //             'app commision',
// //             '-\$${order?.overnightFunding.abs().toStringAsFixed(2) ?? '0.27'}',
// //             hasInfo: true,
// //           ),
// //           SizedBox(height: 24.h),
// //           InkWell(
// //             onTap: () => Navigator.pop(context),
// //             child: Container(
// //               width: double.infinity,
// //               padding: EdgeInsets.symmetric(vertical: 16.h),
// //               decoration: BoxDecoration(
// //                 color: AppColors.yellow,
// //                 borderRadius: BorderRadius.circular(12.r),
// //               ),
// //               child: Center(
// //                 child: Text(
// //                   'Close',
// //                   style: TextStyle(
// //                     color: AppColors.black,
// //                     fontSize: 16.sp,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }
//
// // Widget _buildSheetRow(String label, String value, {bool hasInfo = false}) {
// //   return Row(
// //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //     children: [
// //       Row(
// //         children: [
// //           Text(
// //             label,
// //             style: TextStyle(
// //               color: AppColors.greyText,
// //               fontSize: 16.sp,
// //             ),
// //           ),
// //           // if (hasInfo) ...[
// //           //   SizedBox(width: 8.w),
// //           //   Icon(
// //           //     Icons.info_outline,
// //           //     color: AppColors.greyText,
// //           //     size: 18.sp,
// //           //   ),
// //           // ],
// //         ],
// //       ),
// //       Text(
// //         value,
// //         style: TextStyle(
// //           color: AppColors.white,
// //           fontSize: 16.sp,
// //           fontWeight: FontWeight.w600,
// //         ),
// //       ),
// //     ],
// //   );
// // }
// }
