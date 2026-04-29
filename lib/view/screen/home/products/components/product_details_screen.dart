
import 'package:official_gold/view_model/cubit/product_cubit/product_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view/components/app_bar_widget.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../model/category.dart';
import '../../../../../model/metal_price_model.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/validator.dart';
import '../../../../components/live_status_text.dart';
import '../../../../components/live_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:official_gold/model/product.dart';

import '../../../../components/shimmer_widget.dart';




class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final Category category;
  final int tabIndex;

  const ProductDetailsScreen({
    required this.product,
    required this.category,
    super.key,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = ProductCubit.get(context);

    return BlocProvider.value(
      value: ProductCubit.get(context)..resetControllers(),
      child: BlocListener<ProductCubit, ProductState>(
        listenWhen: (previous, current) {
          return current is MakeOrderSuccessState ||
              current is MakeOrderErrorState;
        },
        listener: (context, state) {
          // ✅ النجاح: اقفل الصفحة هنا بدل ما تقفلها جوه الـ builder
          if (state is MakeOrderSuccessState) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<ProductCubit, ProductState>(
          buildWhen: (previous, current) {
            return current is MakeOrderLoadingState ||
                current is MakeOrderSuccessState ||
                current is MakeOrderErrorState ||
                current is ResetControllersState;
          },
          builder: (context, state) {
            final bool isLoading = state is MakeOrderLoadingState;

            return Stack(
              children: [
                Scaffold(
                  body: GradientWidget(
                    child: Form(
                      key: cubit.formProductKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: BlocBuilder<LivePriceCubit, LivePriceState>(
                        builder: (context, liveState) {
                          // ✅ العملة حسب category index (0 => USD, 1 => EGP)
                          final String currencyKey = product.currency ?? "USD";

                          // (tabIndex == 0) ? 'USD' : 'EGP';

                          MetalPrices? mp;
                          if (liveState is LivePriceLive) {
                            // ✅ هات سعر العملة من السوكت
                            mp = liveState.metals[currencyKey];
                          }

                          // ✅ سعر الجرام لايف
                          final double gramSell = mp?.sell ?? 0.0; // ✅ SELL
                          final double gramBuy = mp?.buy ?? 0.0; // ✅ BUY

                          // ✅ اضرب في وزن المنتج بالجرام
                          final double weight =
                          (product.gramWeight ?? 0).toDouble();

                          // ✅ الإجمالي على وزن المنتج
                          final double liveSellTotal = gramSell * weight;
                          final double liveBuyTotal = gramBuy * weight;

                          // ✅ NEW: السعر اللي هنستخدمه في الفاليديشن والاوردر
                          final double liveOpenPrice =
                              liveBuyTotal; // لو انت بتفتح الصفقة على buy

                          // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
                          final bool hasLive = (liveState is LivePriceLive) &&
                              gramBuy > 0 &&
                              gramSell > 0;

                          return Column(
                            children: [
                              const AppBarCustom(),
/////////////////////////////////////////////////////////////////////////////////////////////////////// category name
                              Expanded(
                                child: AbsorbPointer(
                                  absorbing: !hasLive ||
                                      isLoading, // ✅ يقفل كل التاتش لو السوكت وقف أو في تحميل
                                  child: Opacity(
                                    opacity:
                                    hasLive ? 1.0 : 0.35, // ✅ يخلي الصفحة باهتة
                                    child: ListView(
                                      padding: EdgeInsets.only(
                                        left: 16.sp,
                                        right: 16.sp,
                                        top: 16.sp,
                                      ),
                                      children: [
                                        Center(
                                          child: Text(
                                            category.name ?? '',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge
                                                ?.copyWith(
                                              fontSize: 30.sp,
                                            ),
                                          ),
                                        ),
/////////////////////////////////////////////////////////////////////////////////////////////////////// currency
                                        Container(
                                          margin: EdgeInsets.only(top: 5.sp),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6.sp,
                                                ),
                                                child: Text(
                                                  product.currency ?? '',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
/////////////////////////////////////////////////////////////////////////////////////////////////////// product name
                                              Text(
                                                product.name!,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.copyWith(
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          color: AppColors.textYellow,
                                        ),
/////////////////////////////////////////////////////////////////////////////////////////////////////// live price state connect / disconnect
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: 10.h,
                                            bottom: 12.h,
                                          ),
                                          child: const Center(
                                            child: LiveStatusText(),
                                          ),
                                        ),
/////////////////////////////////////////////////////////////////////////////////////////////////////// green and red live price container
                                        Stack(
                                          alignment: AlignmentDirectional.center,
                                          children: [
                                            SizedBox(
                                              height: 64.h, // غير الرقم زي ما تحب
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 12.sp,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadiusDirectional
                                                            .horizontal(
                                                          start: Radius.circular(
                                                            12.r,
                                                          ),
                                                        ),
                                                        color: AppColors.red,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          Text(
                                                            "Low", // لو عايز تكتب Sell
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .displayMedium
                                                                ?.copyWith(
                                                              color:
                                                              AppColors
                                                                  .white,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Container(
                                                            color:
                                                            AppColors.red,
                                                            child: LivePriceText(
                                                              price:
                                                              liveSellTotal, // ✅ هنا بقى مضروب في الجرامات
                                                              decimals: 2,
                                                              fakeMinDelta: 0.01,
                                                              fakeMaxDelta: 0.05,
                                                              fakeTickEvery:
                                                              const Duration(
                                                                milliseconds:
                                                                900,
                                                              ),
                                                              // ✅ نخلي خلفية LivePriceText شفافة عشان لون الكونتينر هو اللي يظهر
                                                              neutralColor: Colors
                                                                  .transparent,
                                                              upColor: Colors
                                                                  .transparent,
                                                              downColor: Colors
                                                                  .transparent,
                                                              padding:
                                                              EdgeInsets.zero,
                                                              style: Theme.of(
                                                                  context)
                                                                  .textTheme
                                                                  .displayMedium
                                                                  ?.copyWith(
                                                                color: AppColors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 12.sp,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadiusDirectional
                                                            .horizontal(
                                                          end: Radius.circular(
                                                            12.r,
                                                          ),
                                                        ),
                                                        color: AppColors.green,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          Text(
                                                            "High", // لو عايز تكتب Buy
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .displayMedium
                                                                ?.copyWith(
                                                              color:
                                                              AppColors
                                                                  .white,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          LivePriceText(
                                                            price:
                                                            liveBuyTotal, // ✅ هنا بقى مضروب في الجرامات
                                                            decimals: 2,
                                                            fakeMinDelta: 0.01,
                                                            fakeMaxDelta: 0.05,
                                                            fakeTickEvery:
                                                            const Duration(
                                                              milliseconds: 900,
                                                            ),
                                                            neutralColor: Colors
                                                                .transparent,
                                                            upColor: Colors
                                                                .transparent,
                                                            downColor: Colors
                                                                .transparent,
                                                            padding:
                                                            EdgeInsets.zero,
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .displayMedium
                                                                ?.copyWith(
                                                              color:
                                                              AppColors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Container(
                                          padding: EdgeInsets.all(12.sp),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(12.r),
                                            border: Border.all(
                                              color: AppColors.yellowBorder,
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                LocaleKeys.quantityTroyOunce
                                                    .tr(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                  color: AppColors.yellow,
                                                ),
                                              ),
                                              SizedBox(height: 12.h),
///////////////////////////////////////////////////////////////////////////////////////////////// quantityController
                                              BlocBuilder<ProductCubit,
                                                  ProductState>(
                                                buildWhen: (previous, current) {
                                                  return current
                                                  is AddQuantityState ||
                                                      current
                                                      is SubtractQuantityState ||
                                                      current
                                                      is ResetControllersState;
                                                },
                                                builder: (context, state) {
                                                  return TextFormField(
                                                    controller: cubit
                                                        .quantityController,
                                                    textInputAction:
                                                    TextInputAction.done,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(
                                                      color:
                                                      AppColors.yellow,
                                                    ),
                                                    keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                        RegExp(
                                                            r'^\d+\.?\d{0,2}'),
                                                      ),
                                                    ],
                                                    validator: (value) {
                                                      if ((value == null ||
                                                          value
                                                              .trim()
                                                              .isEmpty)) {
                                                        return "Filed is required";
                                                      }
                                                      return null;
                                                    },
                                                    onTapOutside: (_) {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText: '',
                                                      hintStyle:
                                                      Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium
                                                          ?.copyWith(
                                                        color: AppColors
                                                            .yellow,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                        FontWeight
                                                            .w400,
                                                      ),
                                                      isDense: true,
                                                      contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: 12.sp,
                                                        vertical: 6.sp,
                                                      ),
                                                      isCollapsed: true,
                                                      alignLabelWithHint: true,
                                                      suffix:
                                                      makeAddAndMinusButton(
                                                        onAdd: () {
                                                          cubit.addQuantity();
                                                        },
                                                        onMinus: () {
                                                          cubit
                                                              .subtractQuantity();
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(height: 12.h),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      LocaleKeys
                                                          .sellWhenPriceIs,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                        color:
                                                        AppColors.yellow,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12.w),
///////////////////////////////////////////////////////////////////////////////////////////////// buy when switch button
                                                  BlocBuilder<ProductCubit,
                                                      ProductState>(
                                                    buildWhen:
                                                        (previous, current) {
                                                      return current
                                                      is ChangeSellWhenPriceIsState ||
                                                          current
                                                          is ResetControllersState;
                                                    },
                                                    builder:
                                                        (context, state) {
                                                      return Switch.adaptive(
                                                        value: cubit
                                                            .sellWhenPriceIs,
                                                        onChanged: (value) {
                                                          cubit
                                                              .changeSellWhenPriceIs(
                                                              value);
                                                        },
                                                        activeColor:
                                                        AppColors.yellow2,
                                                        inactiveThumbColor:
                                                        AppColors.greyText,
                                                        inactiveTrackColor:
                                                        AppColors.grey
                                                            .withOpacity(
                                                          0.8,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12.h),
///////////////////////////////////////////////////////////////////////////////////////////////// amount  that will change order to open trade
                                              BlocBuilder<ProductCubit,
                                                  ProductState>(
                                                buildWhen: (previous, current) {
                                                  return current
                                                  is ChangeSellWhenPriceIsState ||
                                                      current
                                                      is ResetControllersState;
                                                },
                                                builder: (context, state) {
                                                  return Visibility(
                                                    visible: cubit
                                                        .sellWhenPriceIs,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width:
                                                          double.infinity,
                                                          padding:
                                                          EdgeInsets.all(
                                                              8.sp),
                                                          decoration:
                                                          BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                              12.r,
                                                            ),
                                                            border: Border.all(
                                                              color: AppColors
                                                                  .yellowBorder,
                                                              width: 1.w,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            LocaleKeys.amount
                                                                .tr(),
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .headlineMedium
                                                                ?.copyWith(
                                                              color: AppColors
                                                                  .yellow,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 12.h),
///////////////////////////////////////////////////////////////////////////////////////////////// amount  that will change order to open trade
                                                        BlocBuilder<
                                                            ProductCubit,
                                                            ProductState>(
                                                          buildWhen: (previous,
                                                              current) {
                                                            return current
                                                            is AddAmountState ||
                                                                current
                                                                is SubtractAmountState ||
                                                                current
                                                                is ResetControllersState;
                                                          },
                                                          builder:
                                                              (context, state) {
                                                            return TextFormField(
                                                              controller: cubit
                                                                  .sellWhenController,
                                                              textInputAction:
                                                              TextInputAction
                                                                  .done,
                                                              style: Theme.of(
                                                                  context)
                                                                  .textTheme
                                                                  .headlineMedium
                                                                  ?.copyWith(
                                                                color: AppColors
                                                                    .yellow,
                                                              ),
                                                              keyboardType:
                                                              const TextInputType
                                                                  .numberWithOptions(
                                                                decimal: true,
                                                              ),
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .allow(
                                                                  RegExp(
                                                                      r'^\d+\.?\d{0,2}'),
                                                                ),
                                                              ],
                                                              onTapOutside:
                                                                  (_) {
                                                                FocusScope.of(
                                                                    context)
                                                                    .unfocus();
                                                              },

                                                              // ✅ هنا بقى live
                                                              validator:
                                                                  (value) =>
                                                                  Validator
                                                                      .validatePriceWithRange(
                                                                    enteredValue: value,
                                                                    livePrice:
                                                                    liveOpenPrice,
                                                                  ),

                                                              decoration:
                                                              InputDecoration(
                                                                hintText: '',
                                                                hintStyle: Theme.of(
                                                                    context)
                                                                    .textTheme
                                                                    .headlineMedium
                                                                    ?.copyWith(
                                                                  color: AppColors
                                                                      .yellow,
                                                                  fontSize:
                                                                  12.sp,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                                ),
                                                                isDense: true,
                                                                contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                  horizontal:
                                                                  12.sp,
                                                                  vertical:
                                                                  6.sp,
                                                                ),
                                                                isCollapsed:
                                                                true,
                                                                alignLabelWithHint:
                                                                true,
                                                                suffix:
                                                                makeAddAndMinusButton(
                                                                  onAdd: () {
                                                                    cubit
                                                                        .addAmount();
                                                                  },
                                                                  onMinus: () {
                                                                    cubit
                                                                        .subtractAmount();
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(height: 12.h),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Divider(
                                                color:
                                                AppColors.yellowBorder,
                                              ),
                                              SizedBox(height: 12.h),
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Stop Loss
                                              Container(
                                                padding: EdgeInsets.all(12.sp),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    12.r,
                                                  ),
                                                  border: Border.all(
                                                    color: AppColors
                                                        .yellowBorder,
                                                    width: 1.w,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            LocaleKeys.stopLoss
                                                                .tr(),
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color: AppColors
                                                                  .yellow,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 12.w),
                                                        BlocBuilder<
                                                            ProductCubit,
                                                            ProductState>(
                                                          buildWhen: (previous,
                                                              current) {
                                                            return current
                                                            is ChangeStopLossState ||
                                                                current
                                                                is ResetControllersState;
                                                          },
                                                          builder: (context,
                                                              state) {
                                                            return Switch
                                                                .adaptive(
                                                              value:
                                                              cubit.stopLoss,
                                                              onChanged:
                                                                  (value) {
                                                                cubit
                                                                    .changeStopLoss(
                                                                    value);
                                                              },
                                                              activeColor:
                                                              AppColors
                                                                  .yellow2,
                                                              inactiveThumbColor:
                                                              AppColors
                                                                  .greyText,
                                                              inactiveTrackColor:
                                                              AppColors.grey
                                                                  .withOpacity(
                                                                0.8,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    BlocBuilder<ProductCubit,
                                                        ProductState>(
                                                      buildWhen: (previous,
                                                          current) {
                                                        return current
                                                        is ChangeStopLossState ||
                                                            current
                                                            is ResetControllersState;
                                                      },
                                                      builder:
                                                          (context, state) {
                                                        return Visibility(
                                                          visible:
                                                          cubit.stopLoss,
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                  height:
                                                                  12.h),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                padding:
                                                                EdgeInsets
                                                                    .all(
                                                                  8.sp,
                                                                ),
                                                                decoration:
                                                                BoxDecoration(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                    12.r,
                                                                  ),
                                                                  border:
                                                                  Border.all(
                                                                    color: AppColors
                                                                        .yellowBorder,
                                                                    width: 1.w,
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  LocaleKeys
                                                                      .amount
                                                                      .tr(),
                                                                  style: Theme.of(
                                                                      context)
                                                                      .textTheme
                                                                      .headlineMedium
                                                                      ?.copyWith(
                                                                    color: AppColors
                                                                        .yellow,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                  12.h),
                                                              BlocBuilder<
                                                                  ProductCubit,
                                                                  ProductState>(
                                                                buildWhen: (previous,
                                                                    current) {
                                                                  return current
                                                                  is AddAmountStopLossState ||
                                                                      current
                                                                      is SubtractAmountStopLossState ||
                                                                      current
                                                                      is ResetControllersState;
                                                                },
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  lose amount
                                                                builder: (context,
                                                                    state) {
                                                                  return TextFormField(
                                                                    controller:
                                                                    cubit.stopLossController,
                                                                    textInputAction:
                                                                    TextInputAction
                                                                        .done,
                                                                    validator:
                                                                        (value) =>
                                                                        Validator.validateStopLoss(
                                                                          enteredValue:
                                                                          value,
                                                                          livePrice:
                                                                          liveOpenPrice,
                                                                        ),
                                                                    style: Theme.of(
                                                                        context)
                                                                        .textTheme
                                                                        .headlineMedium
                                                                        ?.copyWith(
                                                                      color:
                                                                      AppColors.red,
                                                                    ),
                                                                    keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                      decimal:
                                                                      true,
                                                                    ),
                                                                    inputFormatters: [
                                                                      FilteringTextInputFormatter
                                                                          .allow(
                                                                        RegExp(
                                                                            r'^\d+\.?\d{0,2}'),
                                                                      ),
                                                                    ],
                                                                    onTapOutside:
                                                                        (_) {
                                                                      FocusScope.of(
                                                                          context)
                                                                          .unfocus();
                                                                    },
                                                                    decoration:
                                                                    InputDecoration(
                                                                      hintText:
                                                                      '',
                                                                      hintStyle: Theme.of(
                                                                          context)
                                                                          .textTheme
                                                                          .headlineMedium
                                                                          ?.copyWith(
                                                                        color:
                                                                        AppColors.red,
                                                                        fontSize:
                                                                        12.sp,
                                                                        fontWeight:
                                                                        FontWeight.w400,
                                                                      ),
                                                                      isDense:
                                                                      true,
                                                                      contentPadding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                        12.sp,
                                                                        vertical:
                                                                        6.sp,
                                                                      ),
                                                                      isCollapsed:
                                                                      true,
                                                                      alignLabelWithHint:
                                                                      true,
                                                                      suffix:
                                                                      makeAddAndMinusButton(
                                                                        onAdd:
                                                                            () {
                                                                          cubit
                                                                              .addAmountStopLoss();
                                                                        },
                                                                        onMinus:
                                                                            () {
                                                                          cubit
                                                                              .subtractAmountStopLoss();
                                                                        },
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
                                              SizedBox(height: 12.h),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Take Profit
                                              Container(
                                                padding: EdgeInsets.all(12.sp),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    12.r,
                                                  ),
                                                  border: Border.all(
                                                    color: AppColors
                                                        .yellowBorder,
                                                    width: 1.w,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            LocaleKeys
                                                                .takeProfit
                                                                .tr(),
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                              color: AppColors
                                                                  .yellow,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 12.w),
                                                        BlocBuilder<
                                                            ProductCubit,
                                                            ProductState>(
                                                          buildWhen: (previous,
                                                              current) {
                                                            return current
                                                            is ChangeTakeProfitState ||
                                                                current
                                                                is ResetControllersState;
                                                          },
                                                          builder: (context,
                                                              state) {
                                                            return Switch
                                                                .adaptive(
                                                              value: cubit
                                                                  .takeProfit,
                                                              onChanged:
                                                                  (value) {
                                                                cubit
                                                                    .changeTakeProfit(
                                                                    value);
                                                              },
                                                              activeColor:
                                                              AppColors
                                                                  .yellow2,
                                                              inactiveThumbColor:
                                                              AppColors
                                                                  .greyText,
                                                              inactiveTrackColor:
                                                              AppColors.grey
                                                                  .withOpacity(
                                                                0.8,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    BlocBuilder<ProductCubit,
                                                        ProductState>(
                                                      buildWhen: (previous,
                                                          current) {
                                                        return current
                                                        is ChangeTakeProfitState ||
                                                            current
                                                            is ResetControllersState;
                                                      },
                                                      builder:
                                                          (context, state) {
                                                        return Visibility(
                                                          visible:
                                                          cubit.takeProfit,
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                  height:
                                                                  12.h),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                padding:
                                                                EdgeInsets
                                                                    .all(
                                                                  8.sp,
                                                                ),
                                                                decoration:
                                                                BoxDecoration(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                    12.r,
                                                                  ),
                                                                  border:
                                                                  Border.all(
                                                                    color: AppColors
                                                                        .yellowBorder,
                                                                    width: 1.w,
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  LocaleKeys
                                                                      .amount
                                                                      .tr(),
                                                                  style: Theme.of(
                                                                      context)
                                                                      .textTheme
                                                                      .headlineMedium
                                                                      ?.copyWith(
                                                                    color: AppColors
                                                                        .yellow,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                  12.h),
                                                              BlocBuilder<
                                                                  ProductCubit,
                                                                  ProductState>(
                                                                buildWhen: (previous,
                                                                    current) {
                                                                  return current
                                                                  is AddAmountTakeProfitState ||
                                                                      current
                                                                      is SubtractAmountTakeProfitState ||
                                                                      current
                                                                      is ResetControllersState;
                                                                },
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////  Profit value
                                                                builder: (context,
                                                                    state) {
                                                                  return TextFormField(
                                                                    controller:
                                                                    cubit.takeProfitController,
                                                                    validator:
                                                                        (value) =>
                                                                        Validator.validateTakeProfit(
                                                                          enteredValue:
                                                                          value,
                                                                          livePrice:
                                                                          liveOpenPrice,
                                                                          requiredField:
                                                                          cubit.takeProfit,
                                                                        ),
                                                                    textInputAction:
                                                                    TextInputAction
                                                                        .done,
                                                                    style: Theme.of(
                                                                        context)
                                                                        .textTheme
                                                                        .headlineMedium
                                                                        ?.copyWith(
                                                                      color:
                                                                      AppColors.green,
                                                                    ),
                                                                    keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                      decimal:
                                                                      true,
                                                                    ),
                                                                    inputFormatters: [
                                                                      FilteringTextInputFormatter
                                                                          .allow(
                                                                        RegExp(
                                                                            r'^\d+\.?\d{0,2}'),
                                                                      ),
                                                                    ],
                                                                    onTapOutside:
                                                                        (_) {
                                                                      FocusScope.of(
                                                                          context)
                                                                          .unfocus();
                                                                    },
                                                                    decoration:
                                                                    InputDecoration(
                                                                      hintText:
                                                                      '',
                                                                      hintStyle: Theme.of(
                                                                          context)
                                                                          .textTheme
                                                                          .headlineMedium
                                                                          ?.copyWith(
                                                                        color:
                                                                        AppColors.red,
                                                                        fontSize:
                                                                        12.sp,
                                                                        fontWeight:
                                                                        FontWeight.w400,
                                                                      ),
                                                                      isDense:
                                                                      true,
                                                                      contentPadding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                        12.sp,
                                                                        vertical:
                                                                        6.sp,
                                                                      ),
                                                                      isCollapsed:
                                                                      true,
                                                                      alignLabelWithHint:
                                                                      true,
                                                                      suffix:
                                                                      makeAddAndMinusButton(
                                                                        onAdd:
                                                                            () {
                                                                          cubit
                                                                              .addAmountTakeProfit();
                                                                        },
                                                                        onMinus:
                                                                            () {
                                                                          cubit
                                                                              .subtractAmountTakeProfit();
                                                                        },
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
                                              SizedBox(height: 12.h),
                                              BlocBuilder<ProductCubit,
                                                  ProductState>(
                                                buildWhen: (previous, current) {
                                                  return current
                                                  is MakeOrderLoadingState ||
                                                      current
                                                      is MakeOrderSuccessState ||
                                                      current
                                                      is MakeOrderErrorState;
                                                },
                                                builder: (context, state) {
                                                  return Visibility(
                                                    visible: state
                                                    is MakeOrderLoadingState,
                                                    child:
                                                    const LinearProgressIndicator(
                                                      stopIndicatorColor:
                                                      AppColors.yellow,
                                                      color: AppColors.yellow,
                                                      backgroundColor:
                                                      AppColors.yellow,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
/////////////////////////////////////////////////////////////////////////////////////////// make order button
                                        SizedBox(height: 12.h),
                                        BlocBuilder<ProductCubit, ProductState>(
                                          buildWhen: (previous, current) {
                                            return current
                                            is MakeOrderLoadingState ||
                                                current
                                                is MakeOrderSuccessState ||
                                                current
                                                is MakeOrderErrorState;
                                          },
                                          builder: (context, state) {
                                            return ElevatedButton(
                                              onPressed: hasLive
                                                  ? () {
                                                if (cubit.formProductKey
                                                    .currentState
                                                    ?.validate() ==
                                                    true &&
                                                    cubit
                                                        .quantityController
                                                        .text
                                                        .isNotEmpty) {
                                                  if (state
                                                  is! MakeOrderLoadingState) {
                                                    ProductCubit.get(
                                                        context)
                                                        .makeOrder(
                                                      product: product,
                                                      livePrice: liveOpenPrice/weight, // ✅ هنا بقى live

                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(
                                                      context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        LocaleKeys
                                                            .pleaseFillAllFields
                                                            .tr(),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                                  : null,
                                              style:
                                              ElevatedButton.styleFrom(
                                                backgroundColor:
                                                AppColors.yellow,
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    12.r,
                                                  ),
                                                ),
                                                padding:
                                                EdgeInsets.symmetric(
                                                  vertical: 12.h,
                                                ),
                                              ),
                                              child:
                                              state is MakeOrderLoadingState
                                                  ? SizedBox(
                                                height: 22.h,
                                                width: 22.h,
                                                child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: AppColors
                                                      .white,
                                                ),
                                              )
                                                  : Text(
                                                LocaleKeys.buy.tr(),
                                                style: Theme.of(
                                                    context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                  color: AppColors
                                                      .white,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 30.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                if (isLoading)
                  Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: ShimmerWidget(
                        child: Container(
                          padding: EdgeInsets.all(12.sp),
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.yellow2,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget makeAddAndMinusButton({
    required void Function()? onAdd,
    required void Function()? onMinus,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر الطرح -
        ExcludeSemantics(
          child: GestureDetector(
            onTap: onMinus,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: const Icon(
                FontAwesomeIcons.minus,
                size: 12,
                color: AppColors.yellow,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // زر الجمع +
        ExcludeSemantics(
          child: GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: const Icon(
                FontAwesomeIcons.plus,
                size: 12,
                color: AppColors.yellow,
              ),
            ),
          ),
        ),
      ],
    );
  }
}



// class ProductDetailsScreen extends StatelessWidget {
//   final Product product;
//   final Category category;
//   final int tabIndex;
//   const ProductDetailsScreen({
//     required this.product,
//     required this.category,
//     super.key,
//     required this.tabIndex,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final cubit = ProductCubit.get(context);
//
//     return BlocProvider.value(
//       value: ProductCubit.get(context)..resetControllers(),
//       child: BlocBuilder<ProductCubit, ProductState>(
//         buildWhen: (previous, current) {
//           return current is MakeOrderLoadingState ||
//               current is MakeOrderSuccessState ||
//               current is MakeOrderErrorState ||
//               current is ResetControllersState;
//         },
//         builder: (context, state) {
//
//           // ✅ شيمر يظهر بس وقت إضافة الأوردر
//           if (state is MakeOrderSuccessState) {
//             Navigator.pop(context);
//           }
//        else   if (state is MakeOrderLoadingState) {
//             return ShimmerWidget(
//               child: Container(
//                 padding: EdgeInsets.all(12.sp),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: AppColors.yellow2,
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//             );
//           }
//           return Scaffold(
//             body: GradientWidget(
//               child: Form(
//                 key: cubit.formProductKey,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 child: BlocBuilder<LivePriceCubit, LivePriceState>(
//                   builder: (context, liveState) {
//                     // ✅ العملة حسب category index (0 => USD, 1 => EGP)
//                     final String currencyKey = product.currency ?? "USD";
//
//                     // (tabIndex == 0) ? 'USD' : 'EGP';
//
//                     MetalPrices? mp;
//                     if (liveState is LivePriceLive) {
//                       // ✅ هات سعر العملة من السوكت
//                       mp = liveState.metals[currencyKey];
//                     }
//
//                     // ✅ سعر الجرام لايف
//                     final double gramSell = mp?.sell ?? 0.0; // ✅ SELL
//                     final double gramBuy = mp?.buy ?? 0.0; // ✅ BUY
//
//                     // ✅ اضرب في وزن المنتج بالجرام
//                     final double weight = (product.gramWeight ?? 0).toDouble();
//
//                     // ✅ الإجمالي على وزن المنتج
//                     final double liveSellTotal = gramSell * weight;
//                     final double liveBuyTotal = gramBuy * weight;
//
//                     // ✅ NEW: السعر اللي هنستخدمه في الفاليديشن والاوردر
//                     final double liveOpenPrice =
//                         liveBuyTotal; // لو انت بتفتح الصفقة على buy
//
//                     // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
//                     final bool hasLive = (liveState is LivePriceLive) &&
//                         gramBuy > 0 &&
//                         gramSell > 0;
//
//                     return Column(
//                       children: [
//                         const AppBarCustom(),
// /////////////////////////////////////////////////////////////////////////////////////////////////////// category name
//                         Expanded(
//                           child: AbsorbPointer(
//                             absorbing:
//                             !hasLive, // ✅ يقفل كل التاتش لو السوكت وقف
//                             child: Opacity(
//                               opacity:
//                               hasLive ? 1.0 : 0.35, // ✅ يخلي الصفحة باهتة
//
//                               child: ListView(
//                                 padding: EdgeInsets.only(
//                                     left: 16.sp, right: 16.sp, top: 16.sp),
//                                 children: [
//                                   Center(
//                                     child: Text(
//                                       category.name ?? '',
//                                       textAlign: TextAlign.center,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .displayLarge
//                                           ?.copyWith(
//                                         fontSize: 30.sp,
//                                       ),
//                                     ),
//                                   ),
// /////////////////////////////////////////////////////////////////////////////////////////////////////// currency
//                                   Container(
//                                     margin: EdgeInsets.only(top: 5.sp),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.center,
//                                       children: [
//                                         Container(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 6.sp),
//                                           child: Text(
//                                             product.currency ?? '',
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
// /////////////////////////////////////////////////////////////////////////////////////////////////////// product name
//                                         Text(
//                                           product.name!,
//                                           textAlign: TextAlign.center,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .displayLarge
//                                               ?.copyWith(
//                                             fontSize: 13.sp,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const Divider(
//                                     color: AppColors.textYellow,
//                                   ),
// /////////////////////////////////////////////////////////////////////////////////////////////////////// live price state connect / disconnect
//                                   Container(
//                                       margin: EdgeInsets.only(
//                                           top: 10.h, bottom: 12.h),
//                                       child: const Center(
//                                           child: LiveStatusText())),
// /////////////////////////////////////////////////////////////////////////////////////////////////////// green and red live price container
//                                   Stack(
//                                     alignment: AlignmentDirectional.center,
//                                     children: [
//                                       SizedBox(
//                                         height: 64.h, // غير الرقم زي ما تحب
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     horizontal: 12.sp),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                   BorderRadiusDirectional
//                                                       .horizontal(
//                                                     start:
//                                                     Radius.circular(12.r),
//                                                   ),
//                                                   color: AppColors.red,
//                                                 ),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                                   mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                                   children: [
//                                                     Text(
//                                                       "Low", // لو عايز تكتب Sell
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .displayMedium
//                                                           ?.copyWith(
//                                                         color:
//                                                         AppColors.white,
//                                                         fontWeight:
//                                                         FontWeight.w400,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Container(
//                                                       color: AppColors.red,
//                                                       child: LivePriceText(
//                                                         price:
//                                                         liveSellTotal, // ✅ هنا بقى مضروب في الجرامات
//                                                         decimals: 2,
//                                                         fakeMinDelta: 0.01,
//                                                         fakeMaxDelta: 0.05,
//                                                         fakeTickEvery:
//                                                         const Duration(
//                                                             milliseconds:
//                                                             900),
//                                                         // ✅ نخلي خلفية LivePriceText شفافة عشان لون الكونتينر هو اللي يظهر
//                                                         neutralColor:
//                                                         Colors.transparent,
//                                                         upColor:
//                                                         Colors.transparent,
//                                                         downColor:
//                                                         Colors.transparent,
//                                                         padding:
//                                                         EdgeInsets.zero,
//
//                                                         style: Theme.of(context)
//                                                             .textTheme
//                                                             .displayMedium
//                                                             ?.copyWith(
//                                                           color: AppColors
//                                                               .white,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Container(
//                                                 padding: EdgeInsets.symmetric(
//                                                     horizontal: 12.sp),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                   BorderRadiusDirectional
//                                                       .horizontal(
//                                                     end: Radius.circular(12.r),
//                                                   ),
//                                                   color: AppColors.green,
//                                                 ),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                                   mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                                   children: [
//                                                     Text(
//                                                       "High", // لو عايز تكتب Buy
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .displayMedium
//                                                           ?.copyWith(
//                                                         color:
//                                                         AppColors.white,
//                                                         fontWeight:
//                                                         FontWeight.w400,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     LivePriceText(
//                                                       price:
//                                                       liveBuyTotal, // ✅ هنا بقى مضروب في الجرامات
//                                                       decimals: 2,
//                                                       fakeMinDelta: 0.01,
//                                                       fakeMaxDelta: 0.05,
//                                                       fakeTickEvery:
//                                                       const Duration(
//                                                           milliseconds:
//                                                           900),
//
//                                                       neutralColor:
//                                                       Colors.transparent,
//                                                       upColor:
//                                                       Colors.transparent,
//                                                       downColor:
//                                                       Colors.transparent,
//                                                       padding: EdgeInsets.zero,
//
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .displayMedium
//                                                           ?.copyWith(
//                                                         color:
//                                                         AppColors.white,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 12.h),
//                                   Container(
//                                     padding: EdgeInsets.all(12.sp),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                       border: Border.all(
//                                         color: AppColors.yellowBorder,
//                                         width: 1.w,
//                                       ),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           LocaleKeys.quantityTroyOunce.tr(),
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyLarge
//                                               ?.copyWith(
//                                             color: AppColors.yellow,
//                                           ),
//                                         ),
//                                         SizedBox(height: 12.h),
// ///////////////////////////////////////////////////////////////////////////////////////////////// quantityController
//                                         BlocBuilder<ProductCubit, ProductState>(
//                                           buildWhen: (previous, current) {
//                                             return current
//                                             is AddQuantityState ||
//                                                 current
//                                                 is SubtractQuantityState ||
//                                                 current
//                                                 is ResetControllersState;
//                                           },
//                                           builder: (context, state) {
//                                             return TextFormField(
//                                               controller:
//                                               cubit.quantityController,
//                                               textInputAction:
//                                               TextInputAction.done,
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .headlineMedium
//                                                   ?.copyWith(
//                                                 color: AppColors.yellow,
//                                               ),
//                                               keyboardType: const TextInputType
//                                                   .numberWithOptions(
//                                                 decimal: true,
//                                               ),
//                                               inputFormatters: [
//                                                 FilteringTextInputFormatter
//                                                     .allow(
//                                                   RegExp(r'^\d+\d{0,2}'),
//                                                 ),
//                                               ],
//                                               validator: (value) {
//                                                 if ((value == null ||
//                                                     value.trim().isEmpty)) {
//                                                   return "Filed is required";
//                                                 }
//                                                 return null;
//                                               },
//                                               onTapOutside: (_) {
//                                                 FocusScope.of(context)
//                                                     .unfocus();
//                                               },
//                                               decoration: InputDecoration(
//                                                 hintText: '',
//                                                 hintStyle: Theme.of(context)
//                                                     .textTheme
//                                                     .headlineMedium
//                                                     ?.copyWith(
//                                                   color: AppColors.yellow,
//                                                   fontSize: 12.sp,
//                                                   fontWeight:
//                                                   FontWeight.w400,
//                                                 ),
//                                                 isDense: true,
//                                                 contentPadding:
//                                                 EdgeInsets.symmetric(
//                                                   horizontal: 12.sp,
//                                                   vertical: 6.sp,
//                                                 ),
//                                                 isCollapsed: true,
//                                                 alignLabelWithHint: true,
//                                                 suffix: makeAddAndMinusButton(
//                                                   onAdd: () {
//                                                     cubit.addQuantity();
//                                                   },
//                                                   onMinus: () {
//                                                     cubit.subtractQuantity();
//                                                   },
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                         SizedBox(height: 12.h),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 LocaleKeys.sellWhenPriceIs,
//                                                 style: Theme.of(context)
//                                                     .textTheme
//                                                     .bodyLarge
//                                                     ?.copyWith(
//                                                   color: AppColors.yellow,
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(width: 12.w),
// ///////////////////////////////////////////////////////////////////////////////////////////////// buy when switch button
//                                             BlocBuilder<ProductCubit,
//                                                 ProductState>(
//                                               buildWhen: (previous, current) {
//                                                 return current
//                                                 is ChangeSellWhenPriceIsState ||
//                                                     current
//                                                     is ResetControllersState;
//                                               },
//                                               builder: (context, state) {
//                                                 return Switch.adaptive(
//                                                   value: cubit.sellWhenPriceIs,
//                                                   onChanged: (value) {
//                                                     cubit.changeSellWhenPriceIs(
//                                                         value);
//                                                   },
//                                                   activeColor:
//                                                   AppColors.yellow2,
//                                                   inactiveThumbColor:
//                                                   AppColors.greyText,
//                                                   inactiveTrackColor: AppColors
//                                                       .grey
//                                                       .withOpacity(0.8),
//                                                 );
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: 12.h),
// ///////////////////////////////////////////////////////////////////////////////////////////////// amount  that will change order to open trade
//                                         BlocBuilder<ProductCubit, ProductState>(
//                                           buildWhen: (previous, current) {
//                                             return current
//                                             is ChangeSellWhenPriceIsState ||
//                                                 current
//                                                 is ResetControllersState;
//                                           },
//                                           builder: (context, state) {
//                                             return Visibility(
//                                               visible: cubit.sellWhenPriceIs,
//                                               child: Column(
//                                                 children: [
//                                                   Container(
//                                                     width: double.infinity,
//                                                     padding:
//                                                     EdgeInsets.all(8.sp),
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                       BorderRadius.circular(
//                                                           12.r),
//                                                       border: Border.all(
//                                                         color: AppColors
//                                                             .yellowBorder,
//                                                         width: 1.w,
//                                                       ),
//                                                     ),
//                                                     child: Text(
//                                                       LocaleKeys.amount.tr(),
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .headlineMedium
//                                                           ?.copyWith(
//                                                         color: AppColors
//                                                             .yellow,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 12.h),
// ///////////////////////////////////////////////////////////////////////////////////////////////// amount  that will change order to open trade
//                                                   BlocBuilder<ProductCubit,
//                                                       ProductState>(
//                                                     buildWhen:
//                                                         (previous, current) {
//                                                       return current
//                                                       is AddAmountState ||
//                                                           current
//                                                           is SubtractAmountState ||
//                                                           current
//                                                           is ResetControllersState;
//                                                     },
//                                                     builder: (context, state) {
//                                                       return TextFormField(
//                                                         controller: cubit
//                                                             .sellWhenController,
//                                                         textInputAction:
//                                                         TextInputAction
//                                                             .done,
//                                                         style: Theme.of(context)
//                                                             .textTheme
//                                                             .headlineMedium
//                                                             ?.copyWith(
//                                                           color: AppColors
//                                                               .yellow,
//                                                         ),
//                                                         keyboardType:
//                                                         const TextInputType
//                                                             .numberWithOptions(
//                                                             decimal: true),
//                                                         inputFormatters: [
//                                                           FilteringTextInputFormatter
//                                                               .allow(
//                                                             RegExp(
//                                                                 r'^\d+\.?\d{0,2}'),
//                                                           ),
//                                                         ],
//                                                         onTapOutside: (_) {
//                                                           FocusScope.of(context)
//                                                               .unfocus();
//                                                         },
//
//                                                         // ✅ هنا بقى live
//                                                         validator: (value) =>
//                                                             Validator
//                                                                 .validatePriceWithRange(
//                                                               value: value,
//                                                               originalPrice:
//                                                               liveOpenPrice,
//                                                             ),
//
//                                                         decoration:
//                                                         InputDecoration(
//                                                           hintText: '',
//                                                           hintStyle: Theme.of(
//                                                               context)
//                                                               .textTheme
//                                                               .headlineMedium
//                                                               ?.copyWith(
//                                                             color: AppColors
//                                                                 .yellow,
//                                                             fontSize: 12.sp,
//                                                             fontWeight:
//                                                             FontWeight
//                                                                 .w400,
//                                                           ),
//                                                           isDense: true,
//                                                           contentPadding:
//                                                           EdgeInsets
//                                                               .symmetric(
//                                                             horizontal: 12.sp,
//                                                             vertical: 6.sp,
//                                                           ),
//                                                           isCollapsed: true,
//                                                           alignLabelWithHint:
//                                                           true,
//                                                           suffix:
//                                                           makeAddAndMinusButton(
//                                                             onAdd: () {
//                                                               cubit.addAmount();
//                                                             },
//                                                             onMinus: () {
//                                                               cubit
//                                                                   .subtractAmount();
//                                                             },
//                                                           ),
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//
//                                                   SizedBox(height: 12.h),
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                         const Divider(
//                                             color: AppColors.yellowBorder),
//                                         SizedBox(height: 12.h),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Stop Loss
//                                         Container(
//                                           padding: EdgeInsets.all(12.sp),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                             BorderRadius.circular(12.r),
//                                             border: Border.all(
//                                               color: AppColors.yellowBorder,
//                                               width: 1.w,
//                                             ),
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Text(
//                                                       LocaleKeys.stopLoss.tr(),
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .bodyLarge
//                                                           ?.copyWith(
//                                                         color: AppColors
//                                                             .yellow,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(width: 12.w),
//                                                   BlocBuilder<ProductCubit,
//                                                       ProductState>(
//                                                     buildWhen:
//                                                         (previous, current) {
//                                                       return current
//                                                       is ChangeStopLossState ||
//                                                           current
//                                                           is ResetControllersState;
//                                                     },
//                                                     builder: (context, state) {
//                                                       return Switch.adaptive(
//                                                         value: cubit.stopLoss,
//                                                         onChanged: (value) {
//                                                           cubit.changeStopLoss(
//                                                               value);
//                                                         },
//                                                         activeColor:
//                                                         AppColors.yellow2,
//                                                         inactiveThumbColor:
//                                                         AppColors.greyText,
//                                                         inactiveTrackColor:
//                                                         AppColors.grey
//                                                             .withOpacity(
//                                                             0.8),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                               BlocBuilder<ProductCubit,
//                                                   ProductState>(
//                                                 buildWhen: (previous, current) {
//                                                   return current
//                                                   is ChangeStopLossState ||
//                                                       current
//                                                       is ResetControllersState;
//                                                 },
//                                                 builder: (context, state) {
//                                                   return Visibility(
//                                                     visible: cubit.stopLoss,
//                                                     child: Column(
//                                                       children: [
//                                                         SizedBox(height: 12.h),
//                                                         Container(
//                                                           width:
//                                                           double.infinity,
//                                                           padding:
//                                                           EdgeInsets.all(
//                                                               8.sp),
//                                                           decoration:
//                                                           BoxDecoration(
//                                                             borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                 12.r),
//                                                             border: Border.all(
//                                                               color: AppColors
//                                                                   .yellowBorder,
//                                                               width: 1.w,
//                                                             ),
//                                                           ),
//                                                           child: Text(
//                                                             LocaleKeys.amount
//                                                                 .tr(),
//                                                             style: Theme.of(
//                                                                 context)
//                                                                 .textTheme
//                                                                 .headlineMedium
//                                                                 ?.copyWith(
//                                                               color: AppColors
//                                                                   .yellow,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(height: 12.h),
//                                                         BlocBuilder<
//                                                             ProductCubit,
//                                                             ProductState>(
//                                                           buildWhen: (previous,
//                                                               current) {
//                                                             return current
//                                                             is AddAmountStopLossState ||
//                                                                 current
//                                                                 is SubtractAmountStopLossState ||
//                                                                 current
//                                                                 is ResetControllersState;
//                                                           },
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  lose amount
//                                                           builder:
//                                                               (context, state) {
//                                                             return TextFormField(
//                                                               controller: cubit
//                                                                   .stopLossController,
//                                                               textInputAction:
//                                                               TextInputAction
//                                                                   .done,
//                                                               validator: (value) =>
//                                                                   Validator
//                                                                       .validateStopLoss(
//                                                                     value: value,
//                                                                     livePrice:
//                                                                     liveOpenPrice,
//                                                                   ),
//                                                               style: Theme.of(
//                                                                   context)
//                                                                   .textTheme
//                                                                   .headlineMedium
//                                                                   ?.copyWith(
//                                                                 color:
//                                                                 AppColors
//                                                                     .red,
//                                                               ),
//                                                               keyboardType:
//                                                               const TextInputType
//                                                                   .numberWithOptions(
//                                                                   decimal:
//                                                                   true),
//                                                               inputFormatters: [
//                                                                 FilteringTextInputFormatter
//                                                                     .allow(
//                                                                   RegExp(
//                                                                       r'^\d+\.?\d{0,2}'),
//                                                                 ),
//                                                               ],
//                                                               onTapOutside:
//                                                                   (_) {
//                                                                 FocusScope.of(
//                                                                     context)
//                                                                     .unfocus();
//                                                               },
//                                                               decoration:
//                                                               InputDecoration(
//                                                                 hintText: '',
//                                                                 hintStyle: Theme.of(
//                                                                     context)
//                                                                     .textTheme
//                                                                     .headlineMedium
//                                                                     ?.copyWith(
//                                                                   color: AppColors
//                                                                       .red,
//                                                                   fontSize:
//                                                                   12.sp,
//                                                                   fontWeight:
//                                                                   FontWeight
//                                                                       .w400,
//                                                                 ),
//                                                                 isDense: true,
//                                                                 contentPadding:
//                                                                 EdgeInsets
//                                                                     .symmetric(
//                                                                   horizontal:
//                                                                   12.sp,
//                                                                   vertical:
//                                                                   6.sp,
//                                                                 ),
//                                                                 isCollapsed:
//                                                                 true,
//                                                                 alignLabelWithHint:
//                                                                 true,
//                                                                 suffix:
//                                                                 makeAddAndMinusButton(
//                                                                   onAdd: () {
//                                                                     cubit
//                                                                         .addAmountStopLoss();
//                                                                   },
//                                                                   onMinus: () {
//                                                                     cubit
//                                                                         .subtractAmountStopLoss();
//                                                                   },
//                                                                 ),
//                                                               ),
//                                                             );
//                                                           },
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 12.h),
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Take Profit
//                                         Container(
//                                           padding: EdgeInsets.all(12.sp),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                             BorderRadius.circular(12.r),
//                                             border: Border.all(
//                                               color: AppColors.yellowBorder,
//                                               width: 1.w,
//                                             ),
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Text(
//                                                       LocaleKeys.takeProfit
//                                                           .tr(),
//                                                       style: Theme.of(context)
//                                                           .textTheme
//                                                           .bodyLarge
//                                                           ?.copyWith(
//                                                         color: AppColors
//                                                             .yellow,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(width: 12.w),
//                                                   BlocBuilder<ProductCubit,
//                                                       ProductState>(
//                                                     buildWhen:
//                                                         (previous, current) {
//                                                       return current
//                                                       is ChangeTakeProfitState ||
//                                                           current
//                                                           is ResetControllersState;
//                                                     },
//                                                     builder: (context, state) {
//                                                       return Switch.adaptive(
//                                                         value: cubit.takeProfit,
//                                                         onChanged: (value) {
//                                                           cubit
//                                                               .changeTakeProfit(
//                                                               value);
//                                                         },
//                                                         activeColor:
//                                                         AppColors.yellow2,
//                                                         inactiveThumbColor:
//                                                         AppColors.greyText,
//                                                         inactiveTrackColor:
//                                                         AppColors.grey
//                                                             .withOpacity(
//                                                             0.8),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                               BlocBuilder<ProductCubit,
//                                                   ProductState>(
//                                                 buildWhen: (previous, current) {
//                                                   return current
//                                                   is ChangeTakeProfitState ||
//                                                       current
//                                                       is ResetControllersState;
//                                                 },
//                                                 builder: (context, state) {
//                                                   return Visibility(
//                                                     visible: cubit.takeProfit,
//                                                     child: Column(
//                                                       children: [
//                                                         SizedBox(height: 12.h),
//                                                         Container(
//                                                           width:
//                                                           double.infinity,
//                                                           padding:
//                                                           EdgeInsets.all(
//                                                               8.sp),
//                                                           decoration:
//                                                           BoxDecoration(
//                                                             borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                 12.r),
//                                                             border: Border.all(
//                                                               color: AppColors
//                                                                   .yellowBorder,
//                                                               width: 1.w,
//                                                             ),
//                                                           ),
//                                                           child: Text(
//                                                             LocaleKeys.amount
//                                                                 .tr(),
//                                                             style: Theme.of(
//                                                                 context)
//                                                                 .textTheme
//                                                                 .headlineMedium
//                                                                 ?.copyWith(
//                                                               color: AppColors
//                                                                   .yellow,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(height: 12.h),
//                                                         BlocBuilder<
//                                                             ProductCubit,
//                                                             ProductState>(
//                                                           buildWhen: (previous,
//                                                               current) {
//                                                             return current
//                                                             is AddAmountTakeProfitState ||
//                                                                 current
//                                                                 is SubtractAmountTakeProfitState ||
//                                                                 current
//                                                                 is ResetControllersState;
//                                                           },
//  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////  Profit value
//                                                           builder:
//                                                               (context, state) {
//                                                             return TextFormField(
//                                                               controller: cubit
//                                                                   .takeProfitController,
//                                                               validator: (value) =>
//                                                                   Validator
//                                                                       .validateTakeProfit(
//                                                                     value: value,
//                                                                     livePrice:
//                                                                     liveOpenPrice,
//                                                                     requiredField: cubit
//                                                                         .takeProfit,
//                                                                   ),
//                                                               textInputAction:
//                                                               TextInputAction
//                                                                   .done,
//                                                               style: Theme.of(
//                                                                   context)
//                                                                   .textTheme
//                                                                   .headlineMedium
//                                                                   ?.copyWith(
//                                                                 color: AppColors
//                                                                     .green,
//                                                               ),
//                                                               keyboardType:
//                                                               const TextInputType
//                                                                   .numberWithOptions(
//                                                                   decimal:
//                                                                   true),
//                                                               inputFormatters: [
//                                                                 FilteringTextInputFormatter
//                                                                     .allow(
//                                                                   RegExp(
//                                                                       r'^\d+\.?\d{0,2}'),
//                                                                 ),
//                                                               ],
//                                                               onTapOutside:
//                                                                   (_) {
//                                                                 FocusScope.of(
//                                                                     context)
//                                                                     .unfocus();
//                                                               },
//                                                               decoration:
//                                                               InputDecoration(
//                                                                 hintText: '',
//                                                                 hintStyle: Theme.of(
//                                                                     context)
//                                                                     .textTheme
//                                                                     .headlineMedium
//                                                                     ?.copyWith(
//                                                                   color: AppColors
//                                                                       .red,
//                                                                   fontSize:
//                                                                   12.sp,
//                                                                   fontWeight:
//                                                                   FontWeight
//                                                                       .w400,
//                                                                 ),
//                                                                 isDense: true,
//                                                                 contentPadding:
//                                                                 EdgeInsets
//                                                                     .symmetric(
//                                                                   horizontal:
//                                                                   12.sp,
//                                                                   vertical:
//                                                                   6.sp,
//                                                                 ),
//                                                                 isCollapsed:
//                                                                 true,
//                                                                 alignLabelWithHint:
//                                                                 true,
//                                                                 suffix:
//                                                                 makeAddAndMinusButton(
//                                                                   onAdd: () {
//                                                                     cubit
//                                                                         .addAmountTakeProfit();
//                                                                   },
//                                                                   onMinus: () {
//                                                                     cubit
//                                                                         .subtractAmountTakeProfit();
//                                                                   },
//                                                                 ),
//                                                               ),
//                                                             );
//                                                           },
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 12.h),
//                                         BlocBuilder<ProductCubit, ProductState>(
//                                           buildWhen: (previous, current) {
//                                             return current
//                                             is MakeOrderLoadingState ||
//                                                 current
//                                                 is MakeOrderSuccessState ||
//                                                 current is MakeOrderErrorState;
//                                           },
//                                           builder: (context, state) {
//                                             return Visibility(
//                                               visible: state
//                                               is MakeOrderLoadingState,
//                                               child:
//                                               const LinearProgressIndicator(
//                                                 stopIndicatorColor:
//                                                 AppColors.yellow,
//                                                 color: AppColors.yellow,
//                                                 backgroundColor:
//                                                 AppColors.yellow,
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ),
// /////////////////////////////////////////////////////////////////////////////////////////// make order button
//                                   SizedBox(height: 12.h),
//                                   BlocBuilder<ProductCubit, ProductState>(
//                                     buildWhen: (previous, current) {
//                                       return current is MakeOrderLoadingState ||
//                                           current is MakeOrderSuccessState ||
//                                           current is MakeOrderErrorState;
//                                     },
//                                     builder: (context, state) {
//                                       return ElevatedButton(
//                                         onPressed: hasLive
//                                             ? () {
//                                           if (cubit.formProductKey
//                                               .currentState
//                                               ?.validate() ==
//                                               true &&
//                                               cubit.quantityController
//                                                   .text.isNotEmpty) {
//                                             if (state
//                                             is! MakeOrderLoadingState) {
//                                               ProductCubit.get(context)
//                                                   .makeOrder(
//                                                 product: product,
//                                                 livePrice: liveOpenPrice, // ✅ هنا بقى live
//                                               );
//
//                                             }
//                                           } else {
//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(
//                                               SnackBar(
//                                                 content: Text(
//                                                   LocaleKeys
//                                                       .pleaseFillAllFields
//                                                       .tr(),
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                         }
//                                             : null,
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: AppColors.yellow,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                             BorderRadius.circular(12.r),
//                                           ),
//                                           padding: EdgeInsets.symmetric(
//                                             vertical: 12.h,
//                                           ),
//                                         ),
//                                         child: Text(
//                                           LocaleKeys.buy.tr(),
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .headlineMedium
//                                               ?.copyWith(
//                                             color: AppColors.white,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//
//                                   SizedBox(height: 30.h),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget makeAddAndMinusButton({
//     required void Function()? onAdd,
//     required void Function()? onMinus,
//   }) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // زر الطرح -
//         ExcludeSemantics(
//           child: GestureDetector(
//             onTap: onMinus,
//             child: Container(
//               width: 28,
//               height: 28,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.transparent,
//               ),
//               child: const Icon(
//                 FontAwesomeIcons.minus,
//                 size: 12,
//                 color: AppColors.yellow,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         // زر الجمع +
//         ExcludeSemantics(
//           child: GestureDetector(
//             onTap: onAdd,
//             child: Container(
//               width: 28,
//               height: 28,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.transparent,
//               ),
//               child: const Icon(
//                 FontAwesomeIcons.plus,
//                 size: 12,
//                 color: AppColors.yellow,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


