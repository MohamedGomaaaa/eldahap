

// order_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:official_gold/view_model/cubit/trades_cubit/trades_cubit.dart' as trades;


import '../../../../view_model/utils/colors.dart';
import 'order_cubit.dart';
import 'order_model.dart';
import 'order_state.dart';



class OrderDetailsScreen extends StatelessWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final sampleOrder = OrderModel(
      productName: 'Gold',
      productIcon: '🏅',
      currentPrice: 3857.36,
      amountToBuy: 0.5,
      orderType: 'Limit',
      createdAt: DateTime(2025, 9, 25, 11, 45),
      buyAtPrice: 3500.00,
      tradeSize: 1750.00,
      leverage: '100:1',
      margin: 17.50,
      overnightFunding: -0.27,
    );

    return BlocProvider(
      create: (context) => OrderCubit()..loadOrder(sampleOrder),
      child:  OrderDetailsView(orderId:orderId),
    );
  }
}

class OrderDetailsView extends StatelessWidget {
  final int orderId;
  const OrderDetailsView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            final cubit = context.read<OrderCubit>();
            final order = cubit.currentOrder;
            return Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    order?.productIcon ?? '🏅',
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  order?.productName ?? 'Gold',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderDeleted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order deleted successfully'),
                backgroundColor: AppColors.green,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceSection(),
              SizedBox(height: 24.h),
              _buildInfoSection(),
              SizedBox(height: 24.h),
              _buildOrderDetailsButton(context),
              SizedBox(height: 16.h),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////  delete

              BlocListener<trades.TradesCubit, trades.TradesState>(
                listener: (context, state) {
                  if (state is CloseOrderSuccessState) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order deleted successfully'),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  }
                },
                child:    _buildDeleteButton(context,orderId),
              ),








              SizedBox(height: 24.h),
              _buildBuyWhenSection(),
              SizedBox(height: 24.h),
              _buildStopLossSection(),
              SizedBox(height: 16.h),
              _buildTakeProfitSection(),
              SizedBox(height: 32.h),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final order = context.read<OrderCubit>().currentOrder;
        return Center(
          child: Text(
            order?.currentPrice.toStringAsFixed(2) ?? '3,857.36',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final order = context.read<OrderCubit>().currentOrder;
        return Column(
          children: [
            _buildInfoRow(
              label: 'Amount to buy',
              value: '+${order?.amountToBuy ?? 0.5}',
                valueColor: AppColors.blueColor,
              isAmount: true

            ),
            SizedBox(height: 16.h),
            _buildInfoRow(label: 'Type',value:  order?.orderType ?? 'Limit'),
            SizedBox(height: 16.h),
            _buildInfoRow(
             label:  'Created',
            value:   '${order?.createdAt.day} Sep ${order?.createdAt.year} ${order?.createdAt.hour}:${order?.createdAt.minute.toString().padLeft(2, '0')}',
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({ required String label, required String value, Color? valueColor,bool? isAmount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 16.sp,
          ),
        ),


        isAmount==true?

        Material(
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
            child:  Text(
              value,
              style: TextStyle(
                color: AppColors.white,
              ),
            ),
          ),
        ):


        Text(
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

  Widget _buildOrderDetailsButton(BuildContext context) {
    return InkWell(
      onTap: () => _showOrderDetailsSheet(context),
      child: Row(
        children: [
          Text(
            'Order details',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.info_outline,
            color: AppColors.yellow,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context,orderId) {
    return InkWell(
      onTap: () => context.read<trades.TradesCubit>().closeOrder(orderId: orderId),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(12.r),
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
    );
  }

  Widget _buildBuyWhenSection() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final order = context.read<OrderCubit>().currentOrder;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buy when price is',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order?.buyAtPrice.toStringAsFixed(2) ?? '3,500.00',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(FontAwesomeIcons.minus, color: AppColors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(FontAwesomeIcons.plus, color: AppColors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Good till',
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 16.sp,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add_circle_outline, color: AppColors.yellow),
                  label: Text(
                    'Add date',
                    style: TextStyle(color: AppColors.yellow),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStopLossSection() {
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
                        color: AppColors.white,
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
                    inactiveThumbColor: AppColors.grey,
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
                        'Amount',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: cubit.stopLossController,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: AppColors.white,
                          fontSize: 18.sp,
                        ),
                        // prefix: Text(
                        //   '\$',
                        //   style: TextStyle(
                        //     color: AppColors.red,
                        //     fontSize: 18.sp,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 6.sp,
                        ),
                        isCollapsed: true,
                        alignLabelWithHint: true,
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton(
                              onPressed: () => cubit.subtractStopLossAmount(),
                              heroTag: 'stopLossMinus',
                              shape: const CircleBorder(),
                              mini: true,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: AppColors.transparent,
                              elevation: 0,
                              child: const Icon(
                                FontAwesomeIcons.minus,
                                color: AppColors.white,
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: () => cubit.addStopLossAmount(),
                              heroTag: 'stopLossPlus',
                              shape: const CircleBorder(),
                              mini: true,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: AppColors.transparent,
                              elevation: 0,
                              child: const Icon(
                                FontAwesomeIcons.plus,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.yellow),
                        ),
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

  Widget _buildTakeProfitSection() {
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
                        color: AppColors.white,
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
                    inactiveThumbColor: AppColors.grey,
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
                        'Amount',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: cubit.takeProfitController,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: AppColors.white,
                          fontSize: 18.sp,
                        ),
                        // prefix: Text(
                        //   '\$',
                        //   style: TextStyle(
                        //     color: AppColors.red,
                        //     fontSize: 18.sp,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 6.sp,
                        ),
                        isCollapsed: true,
                        alignLabelWithHint: true,
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton(
                              onPressed: () => cubit.subtractTakeProfitAmount(),
                              heroTag: 'takeProfitMinus',
                              shape: const CircleBorder(),
                              mini: true,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: AppColors.transparent,
                              elevation: 0,
                              child: const Icon(
                                FontAwesomeIcons.minus,
                                color: AppColors.white,
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: () => cubit.addTakeProfitAmount(),
                              heroTag: 'takeProfitPlus',
                              shape: const CircleBorder(),
                              mini: true,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: AppColors.transparent,
                              elevation: 0,
                              child: const Icon(
                                FontAwesomeIcons.plus,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.yellow),
                        ),
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

  Widget _buildSaveButton(BuildContext context) {
    return InkWell(
      onTap: () => context.read<OrderCubit>().saveOrder(),
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

  void _showOrderDetailsSheet(BuildContext context) {
    final cubit = context.read<OrderCubit>();
    final order = cubit.currentOrder;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order details',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            _buildSheetRow(
              'Trade size',
              '\$${order?.tradeSize.toStringAsFixed(2) ?? '1,750.00'}',
              hasInfo: true,
            ),
            Divider(color: AppColors.lightGrey, height: 32.h),
            _buildSheetRow(
              'Leverage',
              order?.leverage ?? ' 1:1 ',
            ),
            // Divider(color: AppColors.lightGrey, height: 32.h),
            // _buildSheetRow(
            //   'Margin',
            //   '\$${order?.margin.toStringAsFixed(2) ?? '17.50'}',
            //   hasInfo: true,
            // ),
            Divider(color: AppColors.lightGrey, height: 32.h),
            _buildSheetRow(
              'app commision',
              '-\$${order?.overnightFunding.abs().toStringAsFixed(2) ?? '0.27'}',
              hasInfo: true,
            ),
            SizedBox(height: 24.h),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetRow(String label, String value, {bool hasInfo = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 16.sp,
              ),
            ),
            // if (hasInfo) ...[
            //   SizedBox(width: 8.w),
            //   Icon(
            //     Icons.info_outline,
            //     color: AppColors.greyText,
            //     size: 18.sp,
            //   ),
            // ],
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
