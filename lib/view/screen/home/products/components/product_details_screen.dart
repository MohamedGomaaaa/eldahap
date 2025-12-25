import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:official_gold/model/product.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view/components/app_bar_widget.dart';
import 'package:official_gold/view_model/cubit/product_cubit/product_cubit.dart';
import 'package:official_gold/view_model/cubit/wallet_cubit/wallet_cubit.dart';

import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../model/category.dart';
import '../../../../../view_model/utils/colors.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final Category category;

  const ProductDetailsScreen({
    required this.product,
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var cubit = ProductCubit.get(context);
    return BlocProvider.value(
      value: ProductCubit.get(context)..resetControllers(),
      child: Scaffold(
        body: GradientWidget(
          child: Form(
            key: cubit.formProductKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,

            child: Column(
              children: [
                const AppBarCustom(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16.sp),
                    children: [
                      Text(
                        category.name ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 30.sp,
                            ),
                      ),
                      Text(
                        product.currency ?? '',
                        // LocaleKeys.goldSpot.tr(),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(
                        color: AppColors.textYellow,
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(12.sp),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadiusDirectional.horizontal(
                                              start: Radius.circular(12.r)),
                                      color: AppColors.red,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "",
                                          // LocaleKeys.low.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                              ?.copyWith(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w400,
                                              ),
                                        ),
                                        Text(
                                          "",
                                          // '${product.lowPrice ?? ''}',
                                          // '1920.21',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                              ?.copyWith(
                                                color: AppColors.white,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(12.sp),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadiusDirectional.horizontal(
                                        end: Radius.circular(12.r),
                                      ),
                                      color: AppColors.blueColor,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "",
                                          // LocaleKeys.high.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                              ?.copyWith(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w400,
                                              ),
                                        ),
                                        Text(
                                          '${product.highPrice ?? ''}',
                                          // '1920.21',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                              ?.copyWith(
                                                color: AppColors.white,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.sp, vertical: 2.sp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: AppColors.black,
                            ),
                            child: Text(
                              ((product.lowestPrice ?? 0) - (product.highestPrice ?? 0))
                                  .abs()
                                  .toStringAsFixed(2),
                              // '0.3',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      Container(
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
                            Text(
                              LocaleKeys.quantityTroyOunce.tr(),
                              style:
                                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.white,
                                      ),
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
/////////////////////////////////////////////////////////////////////////////////////////////////
                            BlocBuilder<ProductCubit, ProductState>(
                              buildWhen: (previous, current) {
                                return current is AddQuantityState ||
                                    current is SubtractQuantityState ||
                                    current is ResetControllersState;
                              },
                              builder: (context, state) {
                                return TextFormField(
                                  controller: cubit.quantityController,
                                  textInputAction: TextInputAction.done,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppColors.white,
                                      ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\d{0,2}'),
                                      // RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  validator: (value) {
                                    if (
                                        (value == null || value.trim().isEmpty)) {
                                      return "Filed is required";
                                    }
                                    return null;
                                  },
                                  onTapOutside: (_) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  decoration: InputDecoration(
                                    hintText: '',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppColors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                        ),
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
                                          onPressed: () {
                                            cubit.subtractQuantity();
                                          },
                                          heroTag: null,
                                          shape: const CircleBorder(),
                                          mini: true,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          backgroundColor: AppColors.transparent,
                                          child: const Center(
                                            child: Icon(
                                              FontAwesomeIcons.minus,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                        FloatingActionButton(
                                          onPressed: () {
                                            cubit.addQuantity();
                                          },
                                          heroTag: null,
                                          shape: const CircleBorder(),
                                          mini: true,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          backgroundColor: AppColors.transparent,
                                          child: const Center(
                                            child: Icon(
                                              FontAwesomeIcons.plus,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    LocaleKeys.sellWhenPriceIs.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppColors.white,
                                        ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
///////////////////////////////////////////////////////////////////////////////////////////////// switch button
                                BlocBuilder<ProductCubit, ProductState>(
                                  buildWhen: (previous, current) {
                                    return current
                                            is ChangeSellWhenPriceIsState ||
                                        current is ResetControllersState;
                                  },
                                  builder: (context, state) {
                                    return Switch. adaptive(
                                      value: cubit.sellWhenPriceIs,
                                      onChanged: (value) {
                                        cubit.changeSellWhenPriceIs(value);
                                      },
                                      activeColor: AppColors.yellow2,
                                      inactiveThumbColor: AppColors.greyText,
                                      inactiveTrackColor:
                                          AppColors.grey.withOpacity(0.8),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
 ///////////////////////////////////////////////////////////////////////////////////////////////// amount due to switch
                            BlocBuilder<ProductCubit, ProductState>(
                              buildWhen: (previous, current) {
                                return current is ChangeSellWhenPriceIsState ||
                                    current is ResetControllersState;
                              },
                              builder: (context, state) {
                                return Visibility(
                                  visible: cubit.sellWhenPriceIs,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8.sp),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: AppColors.yellowBorder,
                                            width: 1.w,
                                          ),
                                        ),
                                        child: Text(
                                          LocaleKeys.amount.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                color: AppColors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12.h,
                                      ),
                                      BlocBuilder<ProductCubit, ProductState>(
                                        buildWhen: (previous, current) {
                                          return current is AddAmountState ||
                                              current is SubtractAmountState ||
                                              current is ResetControllersState;
                                        },
                                        builder: (context, state) {
                                          return TextFormField(
                                            controller: cubit.amountController,
                                            textInputAction: TextInputAction.done,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: AppColors.white,
                                                ),
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}'),
                                              ),
                                            ],
                                            onTapOutside: (_) {
                                              FocusScope.of(context).unfocus();
                                            },
                                            validator: (value) {
                                              if (
                                              (value == null || value.trim().isEmpty)) {
                                                return "Filed is required";
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: '',
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                    color: AppColors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                                  ),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 12.sp,
                                                vertical: 6.sp,
                                              ),
                                              isCollapsed: true,
                                              alignLabelWithHint: true,
                                              suffix: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      cubit.subtractAmount();
                                                    },
                                                    heroTag: null,
                                                    shape: const CircleBorder(),
                                                    mini: true,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    backgroundColor:
                                                        AppColors.transparent,
                                                    child: const Center(
                                                      child: Icon(
                                                        FontAwesomeIcons.minus,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      cubit.addAmount();
                                                    },
                                                    heroTag: null,
                                                    shape: const CircleBorder(),
                                                    mini: true,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    backgroundColor:
                                                        AppColors.transparent,
                                                    child: const Center(
                                                      child: Icon(
                                                        FontAwesomeIcons.plus,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: 12.h,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              color: AppColors.yellowBorder,
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                            Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   LocaleKeys.marginRequired.tr().toUpperCase(),
                                      //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      //         color: AppColors.greyText,
                                      //       ),
                                      // ),
                                      // Text(
                                      //   '\$500',
                                      //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(),
                                      // ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        LocaleKeys.available.tr().toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: AppColors.greyText,
                                            ),
                                      ),
                                      BlocBuilder<WalletCubit, WalletState>(
                                        buildWhen: (previous, current) {
                                          return current
                                                  is GetWalletSuccessState ||
                                              current is GetWalletLoadingState ||
                                              current is GetWalletErrorState ||
                                              current is ResetControllersState;
                                        },
                                        builder: (context, state) {
                                          return Text(
                                            '${WalletCubit.get(context).wallet}',
                                            // '1200',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.h,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Stop Loss
                      Container(
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
                                    LocaleKeys.stopLoss.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppColors.white,
                                        ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                BlocBuilder<ProductCubit, ProductState>(
                                  buildWhen: (previous, current) {
                                    return current is ChangeStopLossState ||
                                        current is ResetControllersState;
                                  },
                                  builder: (context, state) {
                                    return Switch.adaptive(
                                      value: cubit.stopLoss,
                                      onChanged: (value) {
                                        cubit.changeStopLoss(value);
                                      },
                                      activeColor: AppColors.yellow2,
                                      inactiveThumbColor: AppColors.greyText,
                                      inactiveTrackColor:
                                          AppColors.grey.withOpacity(0.8),
                                    );
                                  },
                                ),
                              ],
                            ),
                            BlocBuilder<ProductCubit, ProductState>(
                              buildWhen: (previous, current) {
                                return current is ChangeStopLossState ||
                                    current is ResetControllersState;
                              },
                              builder: (context, state) {
                                return Visibility(
                                  visible: cubit.stopLoss,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 12.h,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8.sp),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: AppColors.yellowBorder,
                                            width: 1.w,
                                          ),
                                        ),
                                        child: Text(
                                          LocaleKeys.amount.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                color: AppColors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12.h,
                                      ),
                                      BlocBuilder<ProductCubit, ProductState>(
                                        buildWhen: (previous, current) {
                                          return current
                                                  is AddAmountStopLossState ||
                                              current
                                                  is SubtractAmountStopLossState ||
                                              current is ResetControllersState;
                                        },
                                        builder: (context, state) {
                                          return TextFormField(
                                            controller: cubit.stopLossController,
                                            textInputAction: TextInputAction.done,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: AppColors.red,
                                                ),
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}'),
                                              ),
                                            ],
                                            onTapOutside: (_) {
                                              FocusScope.of(context).unfocus();
                                            },
                                            // validator: (value) {
                                            //   if (
                                            //   (value == null || value.trim().isEmpty)) {
                                            //     return "Filed is required";
                                            //   }
                                            //   return null;
                                            // },
                                            decoration: InputDecoration(
                                              hintText: '',
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                    color: AppColors.red,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                                  ),
                                              prefix: Text(
                                                '\$',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                      color: AppColors.red,
                                                    ),
                                              ),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 12.sp,
                                                vertical: 6.sp,
                                              ),
                                              isCollapsed: true,
                                              alignLabelWithHint: true,
                                              suffix: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      cubit
                                                          .subtractAmountStopLoss();
                                                    },
                                                    heroTag: null,
                                                    shape: const CircleBorder(),
                                                    mini: true,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    backgroundColor:
                                                        AppColors.transparent,
                                                    child: const Center(
                                                      child: Icon(
                                                        FontAwesomeIcons.minus,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      cubit.addAmountStopLoss();
                                                    },
                                                    heroTag: null,
                                                    shape: const CircleBorder(),
                                                    mini: true,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    backgroundColor:
                                                        AppColors.transparent,
                                                    child: const Center(
                                                      child: Icon(
                                                        FontAwesomeIcons.plus,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Take Profit
                      Container(
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
                                    LocaleKeys.takeProfit.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppColors.white,
                                        ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                BlocBuilder<ProductCubit, ProductState>(
                                  buildWhen: (previous, current) {
                                    return current is ChangeTakeProfitState ||
                                        current is ResetControllersState;
                                  },
                                  builder: (context, state) {
                                    return Switch.adaptive(
                                      value: cubit.takeProfit,
                                      onChanged: (value) {
                                        cubit.changeTakeProfit(value);
                                      },
                                      activeColor: AppColors.yellow2,
                                      inactiveThumbColor: AppColors.greyText,
                                      inactiveTrackColor:
                                          AppColors.grey.withOpacity(0.8),
                                    );
                                  },
                                ),
                              ],
                            ),
                            BlocBuilder<ProductCubit, ProductState>(
                              buildWhen: (previous, current) {
                                return current is ChangeTakeProfitState ||
                                    current is ResetControllersState;
                              },
                              builder: (context, state) {
                                return Visibility(
                                  visible: cubit.takeProfit,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 12.h,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8.sp),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: AppColors.yellowBorder,
                                            width: 1.w,
                                          ),
                                        ),
                                        child: Text(
                                          LocaleKeys.amount.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                color: AppColors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12.h,
                                      ),
                                      BlocBuilder<ProductCubit, ProductState>(
                                        buildWhen: (previous, current) {
                                          return current
                                                  is AddAmountTakeProfitState ||
                                              current
                                                  is SubtractAmountTakeProfitState ||
                                              current is ResetControllersState;
                                        },
                                        builder: (context, state) {
                                          return TextFormField(
                                            controller:
                                                cubit.takeProfitController,
                                            textInputAction: TextInputAction.done,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: AppColors.red,
                                                ),
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}'),
                                              ),
                                            ],
                                            onTapOutside: (_) {
                                              FocusScope.of(context).unfocus();
                                            },
                                            // validator: (value) {
                                            //   if (
                                            //   (value == null || value.trim().isEmpty)) {
                                            //     return "Filed is required";
                                            //   }
                                            //   return null;
                                            // },
                                            decoration: InputDecoration(
                                              hintText: '',
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                    color: AppColors.red,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                                  ),
                                              prefix: Text(
                                                '\$',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                      color: AppColors.red,
                                                    ),
                                              ),
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 12.sp,
                                                vertical: 6.sp,
                                              ),
                                              isCollapsed: true,
                                              alignLabelWithHint: true,
                                              suffix: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      cubit
                                                          .subtractAmountTakeProfit();
                                                    },
                                                    heroTag: null,
                                                    shape: const CircleBorder(),
                                                    mini: true,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    backgroundColor:
                                                        AppColors.transparent,
                                                    child: const Center(
                                                      child: Icon(
                                                        FontAwesomeIcons.minus,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      cubit.addAmountTakeProfit();
                                                    },
                                                    heroTag: null,
                                                    shape: const CircleBorder(),
                                                    mini: true,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    backgroundColor:
                                                        AppColors.transparent,
                                                    child: const Center(
                                                      child: Icon(
                                                        FontAwesomeIcons.plus,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      BlocBuilder<ProductCubit, ProductState>(
                        buildWhen: (previous, current) {
                          return current is MakeOrderLoadingState ||
                              current is MakeOrderSuccessState ||
                              current is MakeOrderErrorState;
                        },
                        builder: (context, state) {
                          return Visibility(
                            visible: state is MakeOrderLoadingState,
                            child: const LinearProgressIndicator(
                              backgroundColor: AppColors.backgroundGrey,
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      BlocBuilder<ProductCubit, ProductState>(
                        buildWhen: (previous, current) {
                          return current is MakeOrderLoadingState ||
                              current is MakeOrderSuccessState ||
                              current is MakeOrderErrorState;
                        },
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: () {

                              final isFormValid = cubit.formProductKey.currentState?.validate() == true;
                              final hasQuantity = cubit.quantityController.text.isNotEmpty;
                              final hasSellWhenPrice = cubit.amountController.text.isNotEmpty;
                              final hasStopLoss = cubit.stopLossController.text.isNotEmpty;
                              final hasTakeProfit = cubit.takeProfitController.text.isNotEmpty;

                              print('isFormValid: $isFormValid');
                              print('hasQuantity: $hasQuantity');
                              print('hasSellWhenPrice: $hasSellWhenPrice');
                              print('hasStopLoss: $hasStopLoss');
                              print('hasTakeProfit: $hasTakeProfit');

                              if(cubit.formProductKey.currentState?.validate() == true&&

                              cubit.quantityController.text.isNotEmpty
                              // &&
                              // cubit.amountController.text.isNotEmpty
                              //     &&
                              // cubit.stopLossController.text.isNotEmpty&&
                              // cubit.takeProfitController.text.isNotEmpty
                              ){
                                if (state is! MakeOrderLoadingState) {
                                  ProductCubit.get(context).makeOrder(product).then(
                                        (value) => Navigator.pop(context),
                                  );
                                }
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      LocaleKeys.pleaseFillAllFields.tr(),
                                    ),
                                  ),
                                );
                              }

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                              ),
                            ),
                            child: Text(
                              LocaleKeys.buy.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
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
