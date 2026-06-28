import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/l10n/locale_keys.g.dart';
import 'package:official_gold/view/components/app_loader.dart';
import 'package:official_gold/view/components/gradient_widget.dart';
import 'package:official_gold/view/components/app_bar_widget.dart';
import '../../../../model/metal_price_model.dart';
import '../../../../model/trade_order_model.dart';
import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../view_model/cubit/product_cubit/product_cubit.dart';
import '../../../../view_model/utils/colors.dart';
import '../../../../view_model/utils/navigation.dart';
import '../../../../view_model/utils/toast.dart';
import '../../../../view_model/utils/validator.dart';
import '../../../components/creat_order_trade_details.dart';
import '../../static_pages/static_page_screen.dart';
import '../layout_screen.dart';





class TradeDetailsScreen extends StatefulWidget {
  final TradeOrOrder trade;
   final String productTitle;

  const TradeDetailsScreen({
    super.key,
    required this.trade,
     required this.productTitle,

  });

  @override
  State<TradeDetailsScreen> createState() => _TradeDetailsScreenState();
}

class _TradeDetailsScreenState extends State<TradeDetailsScreen> {
  final ApiService _appService = ApiService();

  int _tabIndex = 0; // ✅ 0 => Edit , 1 => Sell

  @override
  void initState() {
    super.initState();

    // ✅ أهم سطر: خلي السويتشات دايمًا مقفولة أول ما تفتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = ProductCubit.get(context);
      cubit
          .resetEditToggles(); // ✅ stopLoss=false + takeProfit=false + clear controllers
    });
  }

  @override
  Widget build(BuildContext context) {
    final trade = widget.trade;

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: BlocBuilder<LivePriceCubit, LivePriceState>(
        builder: (context, liveState) {
          // ✅ العملة حسب category index (0 => USD, 1 => EGP)
          final String currencyKey = trade.currency ?? "USD";
          MetalPrices? mp;
          if (liveState is LivePriceLive) {
            mp = liveState.metals[currencyKey];
          }

          final double livePrice =
              (mp?.buy ?? 0).toDouble() * (trade.unitGramWeight ?? 1);

          final double openPrice = (trade.openPrice ?? 0).toDouble();

          // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
          final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;

          final double pnl =
              (livePrice - openPrice) * (trade.quantity ?? 0).toDouble();

          final bool isProfit = pnl >= 0;

          return Stack(
            children: [
              GradientWidget(
                // ✅ الصفحة كلها Scroll
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(12.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBarCustom(
                        showBalance: true,
                      ),
////////////////////////////////////////////////////////////////////////////////////////////////////////////  live price
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Center(
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(vertical: 10),
//                               child: const LiveStatusText(),
//                             ),
//                           ),
//                           LivePriceText(
//                             price: livePrice,
//                             decimals: 2,
//                             fakeMinDelta: 0.01,
//                             fakeMaxDelta: 0.05,
//                             fakeTickEvery: const Duration(milliseconds: 900),
//                           ),
//                         ],
//                       ),

//                       Center(
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(vertical: 10),
//                           child: const LiveStatusText(),
//                         ),
//                       ),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////  title
//                       Align(
//                         alignment: Alignment.center,
//                         child: Text(
//                           "${widget.productTitle} ${trade.unitGramWeight} gm",
//                           style: Theme.of(context)
//                               .textTheme
//                               .displayMedium
//                               ?.copyWith(
//                                 color: AppColors.white,
//                               ),
//                         ),
//                       ),
//                       SizedBox(height: 12.sp),
///////////////////////////////////////////////////////////////////////////////////////////// Creat Trade Order Details
                      CreatTradeOrderDetails(
                       tradeOrOrder:trade,
                       isOrder:false, productTitle:widget. productTitle,
                      ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// Tab Bar
                      DefaultTabController(
                        length: 2,
                        initialIndex: _tabIndex,
                        child: Column(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                //This is for background color
                                color: AppColors.transparent,
                                //This is for bottom border that is needed
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.grey,
                                    width: 0.8.sp,
                                  ),
                                ),
                              ),
                              child: TabBar(
                                tabs: [
                                  Tab(text: LocaleKeys.edit.tr()),
                                  Tab(text: LocaleKeys.sell.tr()),
                                ],
                                onTap: (index) {
                                  setState(() => _tabIndex = index);
                                },
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // ✅ هنا بنغيّر المحتوى بس — بدون TabBarView وبدون Scroll داخلي
                            if (_tabIndex == 0)
                              _buildEditTab(context, livePrice, hasLive),
                            if (_tabIndex == 1) _buildSellTab(context, hasLive),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
              // ✅ Overlay باهت لما مفيش Live
              if (!hasLive)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true, // مجرد لون فقط
                    child: Container(
                      color: Colors.grey.withOpacity(0.35), // غير النسبة براحتك
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditTab(BuildContext context, double livePrice, bool hasLive) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final cubit = ProductCubit.get(context);

        return AbsorbPointer(
          absorbing: !hasLive, // ✅ يقفل كل التاتش لو السوكت وقف
          child: Form(
            // ✅ Form واحدة فقط (ده اللي بيخلي الفاليديتر يشتغل + يمنع GlobalKey error)
            key: cubit.formProductKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ///////////////////////////////////////////////////////////////////////////////////////////////////////// Stop Loss XXXXXXXXXXXXXXxX
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
                                    color: AppColors.yellow,
                                  ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Switch.adaptive(
                            value: cubit.stopLoss,
                            onChanged: (value) {
                              cubit.changeStopLoss(value);
                              if (!value) {
                                cubit.stopLossController.clear();
                                cubit.formProductKey.currentState?.validate();
                              }
                            },
                            activeColor: AppColors.yellow,
                            inactiveThumbColor: AppColors.yellow,
                            inactiveTrackColor: AppColors.grey.withOpacity(0.8),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: cubit.stopLoss,
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
                                LocaleKeys.amount.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppColors.yellow),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            BlocBuilder<ProductCubit, ProductState>(
                              buildWhen: (previous, current) {
                                return current is AddAmountStopLossState ||
                                    current is SubtractAmountStopLossState ||
                                    current is ResetControllersState ||
                                    current is ChangeStopLossState;
                              },
                              builder: (context, state) {
                                return TextFormField(
                                  validator: (value) =>
                                      Validator.validateStopLoss(
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
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
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
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.sp),
////////////////////////////////////////////////////////////////////////////////////////////////////////////// Take Profit
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
                                    color: AppColors.yellow,
                                  ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Switch.adaptive(
                            value: cubit.takeProfit,
                            onChanged: (value) {
                              cubit.changeTakeProfit(value);
                              if (!value) {
                                cubit.takeProfitController.clear();
                                cubit.formProductKey.currentState?.validate();
                              }
                            },
                            activeColor: AppColors.yellow,
                            inactiveThumbColor: AppColors.yellow,
                            inactiveTrackColor: AppColors.grey.withOpacity(0.8),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: cubit.takeProfit,
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
                                LocaleKeys.amount.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppColors.yellow),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            BlocBuilder<ProductCubit, ProductState>(
                              buildWhen: (previous, current) {
                                return current is AddAmountTakeProfitState ||
                                    current is SubtractAmountTakeProfitState ||
                                    current is ResetControllersState ||
                                    current is ChangeTakeProfitState;
                              },
                              builder: (context, state) {
                                return TextFormField(
                                  validator: (value) =>
                                      Validator.validateTakeProfit(
                                    enteredValue: value,
                                    livePrice: livePrice,
                                    requiredField: cubit.takeProfit,
                                  ),
                                  controller: cubit.takeProfitController,
                                  textInputAction: TextInputAction.done,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: AppColors.green),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
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
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.sp),

///////////////////////////////////////////////////////////////////////////////////////////////////////// button edit update position
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () {
                      confirmBottomSheet(
                        context: context,
                        title: "update trade",
                        onPressed: () async {
                          // ✅ لازم نعمل validate عشان الفاليديتر يظهر
                          if (cubit.stopLoss == true ||
                              cubit.takeProfit == true) {
                            final ok =
                                cubit.formProductKey.currentState?.validate() ??
                                    false;
                            if (!ok) return;
                          }

                          if ((cubit.stopLoss == false &&
                                  cubit.takeProfit == false) ||
                              (cubit.takeProfitController.text.trim().isEmpty &&
                                  cubit.takeProfit == true) ||
                              (cubit.stopLossController.text.trim().isEmpty &&
                                  cubit.stopLoss == true)) {
                            Toast.showMsg(
                                msg: LocaleKeys.canNotDoOpreation.tr());
                            return;
                          }

                          AppLoader.showLoader(
                              context, ValueKey("updateOrder"));

                          if (cubit.takeProfit == false) {
                            cubit.takeProfitController.text = "0";
                          }
                          if (cubit.stopLoss == false) {
                            cubit.stopLossController.text = "0";
                          }

                          try {
                            await _appService.updateOrder(
                              orderId: widget.trade.id ?? 0,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      disabledBackgroundColor: AppColors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.updatePosition.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppColors.white),
                    ),
                  ),
                ),

                // ✅ مساحة زيادة تحت عشان آخر عنصر مايلزقش
                SizedBox(height: 50.h),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildSellTab(BuildContext context, bool hasLive) {
    final trade = widget.trade;

    return AbsorbPointer(
      absorbing: !hasLive,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
//////////////////////////////////////////////////////////////////////////////////////////////////////// button sell  close
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
              onPressed: () async {
                confirmBottomSheet(
                    context: context,
                    title: "close trade",
                    onPressed: () async {
                      AppLoader.showLoader(
                          context, const ValueKey("sell_price"));

                      await _appService.sellOrder(
                          orderId: trade.id ?? 0, ctx: context);

                      Navigation.push(context, LayoutScreen());
                    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                disabledBackgroundColor: AppColors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                LocaleKeys.close.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              ),
            ),
          ),
          SizedBox(height: 12.sp),
///////////////////////////////////////////////////////////////////////////////////////////////////////// button sell  deliveryData
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
              onPressed: () async {
                final trade = widget.trade;
                final deliveryData = await showDialog<Map<String, String>>(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) =>
                      DeliveryDataDialog(dialogContext: dialogContext),
                );

                if (deliveryData != null) {
                  AppLoader.showLoader(context, ValueKey("requestDelivery"));
                  _appService.requestDelivery(
                    trade: trade,
                    orderId: trade.id ?? 0,
                    deliveryAddress: deliveryData["delivery_address"] ?? '',
                    deliveryCity: deliveryData["delivery_city"] ?? '',
                    deliveryPhone: deliveryData["delivery_phone"] ?? '',
                    ctx: context,
                  );
                }

                Navigation.push(context, const LayoutScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                disabledBackgroundColor: AppColors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                LocaleKeys.delivery.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.white),
              ),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

void confirmBottomSheet(
    {required BuildContext context,
    required String title,
    required void Function()? onPressed})
{
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
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
                  Navigator.pop(context, false);
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

class DeliveryDataDialog extends StatefulWidget {
  final BuildContext dialogContext;
  const DeliveryDataDialog({Key? key, required this.dialogContext})
      : super(key: key);

  @override
  State<DeliveryDataDialog> createState() => _DeliveryDataDialogState();
}

class _DeliveryDataDialogState extends State<DeliveryDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and check format
    String cleanPhone = value.replaceAll(' ', '');

    // Check if it matches Egyptian phone number format (11 digits starting with 01)
    RegExp phoneRegex = RegExp(r'^01[0-9]{9}$');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Invalid phone format (example: 0 10 1234 5678)';
    }

    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void _formatPhoneNumber() {
    String text = _phoneController.text.replaceAll(' ', '');
    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 1 || i == 3 || i == 7) {
        formatted += ' ';
      }
      formatted += text[i];
    }

    _phoneController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _submitForm() {
    // ✅ لو الفاليديتور كان مش باين، ده بيضمن إنه ينعكس فوراً
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      setState(() {});
      return;
    }

    // Process the data
    Map<String, String> deliveryData = {
      'delivery_address': _addressController.text.trim(),
      'delivery_city': _cityController.text.trim(),
      'delivery_phone': _phoneController.text.replaceAll(' ', ''),
    };

    // Return data to parent widget
    Navigator.of(context).pop(deliveryData);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: AppColors.grey,
          width: 1.w,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.grey,
            width: 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            // ✅ يخلي الايرور يبان أثناء الكتابة (مش بس بعد Submit)
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Information',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(
                                widget.dialogContext); // ✅ يقفل الديالوج فقط
                          },
                          icon: Icon(
                            Icons.close,
                            color: AppColors.yellow,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Address Field
                  Text(
                    'Address',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                          fontSize: 14.sp,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _addressController,
                    validator: (value) => _validateRequired(value, 'Address'),
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter delivery address',
                      hintStyle: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundGrey2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.grey,
                          width: 1.w,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.grey,
                          width: 1.w,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.yellow,
                          width: 2.w,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.w,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2.w,
                        ),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    maxLines: 2,
                  ),

                  SizedBox(height: 16.h),

                  // City Field
                  Text(
                    'City',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                          fontSize: 14.sp,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _cityController,
                    validator: (value) => _validateRequired(value, 'City'),
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter city',
                      hintStyle: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundGrey2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.grey,
                          width: 1.w,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.grey,
                          width: 1.w,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.yellow,
                          width: 2.w,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.w,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2.w,
                        ),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Phone Field
                  Text(
                    'Phone Number',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                          fontSize: 14.sp,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _phoneController,
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14.sp,
                    ),
                    onChanged: (value) {
                      if (value.replaceAll(' ', '').length <= 11) {
                        _formatPhoneNumber();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: '0 10 1234 5678',
                      hintStyle: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundGrey2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.grey,
                          width: 1.w,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.grey,
                          width: 1.w,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.yellow,
                          width: 2.w,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.w,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2.w,
                        ),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      prefixIcon: Container(
                        padding: EdgeInsets.all(12.w),
                        child: Icon(
                          Icons.phone,
                          color: AppColors.yellow,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.black,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}






// // Complete widget with the delivery button using the new colors
// class DeliveryButton extends StatelessWidget {
//   const DeliveryButton({Key? key}) : super(key: key);
//
//   void _showDeliveryDialog(BuildContext context) async {
//     final result = await showDialog<Map<String, String>>(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: AppColors.black.withOpacity(0.7),
//       builder: (context) => const DeliveryDataDialog(),
//     );
//
//     if (result != null) {
//       // Handle the delivery data
//       print('Delivery Address: ${result['delivery_address']}');
//       print('Delivery City: ${result['delivery_city']}');
//       print('Delivery Phone: ${result['delivery_phone']}');
//
//       // Show success message with dark theme
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Delivery data saved successfully',
//             style: TextStyle(
//               color: AppColors.black,
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           backgroundColor: AppColors.yellow,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           margin: EdgeInsets.all(16.w),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 40.h,
//       child: ElevatedButton(
//         onPressed: () => _showDeliveryDialog(context),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.yellow,
//           foregroundColor: AppColors.black,
//           disabledBackgroundColor: AppColors.lightGrey,
//           elevation: 0,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//         child: Text(
//           'Delivery', // or LocaleKeys.delivery.tr() if you're using localization
//           style: TextStyle(
//             color: AppColors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 16.sp,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Usage example with different ways to call the dialog
// class DeliveryFeesExample extends StatelessWidget {
//   const DeliveryFeesExample({Key? key}) : super(key: key);
//
//   // Method 1: Simple usage
//   void _showDeliveryFeesDialog(BuildContext context, String fees) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierColor: AppColors.black.withOpacity(0.7),
//       builder: (context) => DeliveryFeesDialog(deliveryFees: fees),
//     );
//   }
//
//   // Method 2: With callback
//   void _showFeesWithCallback(BuildContext context, String fees) {
//     showDialog(
//       context: context,
//       barrierColor: AppColors.black.withOpacity(0.7),
//       builder: (context) => DeliveryFeesDialog(deliveryFees: fees),
//     ).then((_) {
//       // Do something after dialog is closed
//       print('Delivery fees dialog closed');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('Delivery Fees Example'),
//         backgroundColor: AppColors.backgroundGrey,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Example buttons with different fees
//             ElevatedButton(
//               onPressed: () => _showDeliveryFeesDialog(context, '\$5.99'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.yellow,
//                 foregroundColor: AppColors.black,
//               ),
//               child: const Text('Show Fees - \$5.99'),
//             ),
//
//             SizedBox(height: 16.h),
//
//             ElevatedButton(
//               onPressed: () => _showDeliveryFeesDialog(context, '25 EGP'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.yellow,
//                 foregroundColor: AppColors.black,
//               ),
//               child: const Text('Show Fees - 25 EGP'),
//             ),
//
//             SizedBox(height: 16.h),
//
//             ElevatedButton(
//               onPressed: () => _showDeliveryFeesDialog(context, 'Free'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.yellow,
//                 foregroundColor: AppColors.black,
//               ),
//               child: const Text('Show Free Delivery'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Direct usage in your existing button
// class YourExistingWidget extends StatelessWidget {
//   final String deliveryFeesValue; // This comes from your data
//
//   const YourExistingWidget({
//     Key? key,
//     required this.deliveryFeesValue,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         // Show the delivery fees dialog
//         showDialog(
//           context: context,
//           barrierColor: AppColors.black.withOpacity(0.7),
//           builder: (context) => DeliveryFeesDialog(
//             deliveryFees: deliveryFeesValue, // Pass your fees value here
//           ),
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.yellow,
//         foregroundColor: AppColors.black,
//       ),
//       child: const Text('View Delivery Fees'),
//     );
//   }
//
//
//
//
//
//
//
//
// //
// }
/////////////////////////////////////////////////////////////////////////////////////////////////////////// before

// class TradeDetailsScreen extends StatelessWidget {
//   final TradeOrOrder trade;
//   final String productTitle;
//   TradeDetailsScreen({super.key, required this.trade, required this.productTitle});
//
//   ApiService _appService = ApiService();
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.transparent,
//       body: GradientWidget(
//         child: ListView(
//           padding: EdgeInsets.all(12.sp),
//           children: [
//             const AppBarCustom(
//               showBalance: true,
//             ),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////  title
//             Align(
//               alignment: Alignment.center,
//               child: Text(
//                 productTitle,
//                 style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                   color: AppColors.white,
//                 ),
//               ),
//             ),
//             // Align(
//             //   alignment: Alignment.center,
//             //   child: Text(
//             //     LocaleKeys.goldSpot.tr(),
//             //     style: Theme.of(context).textTheme.labelLarge?.copyWith(
//             //           color: AppColors.greyText,
//             //         ),
//             //   ),
//             // ),
//             SizedBox(
//               height: 12.sp,
//             ),
// //////////////////////////////////////////////////////////////////////////////////////////////////////////  purpule container
//             Container(
//               padding: EdgeInsets.all(12.sp),
//               decoration: BoxDecoration(
//                 color: AppColors.purple2,
//                 borderRadius: BorderRadius.circular(12.sp),
//               ),
//               child: Text(
//
//
//
//
//
//
//                 LocaleKeys.marketIsClosedItOpensIn.tr(
//                   namedArgs: {
//                     'days': '1',
//                   },
//                 ),
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context)
//                     .textTheme
//                     .labelMedium
//                     ?.copyWith(color: AppColors.white, fontSize: 13.sp),
//               ),
//             ),
//             SizedBox(
//               height: 12.sp,
//             ),
// //////////////////////////////////////////////////////////////////////////////////////////////////////////  trade creat at
//             Text(
//               Methods.formatCreatedAt( trade.createdAt!.toString())
//               ,
//               style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                 color: AppColors.greyText,
//               ),
//             ),
//             SizedBox(
//               height: 12.sp,
//             ),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////// Bought
//             Row(
//               children: [
//                 Text(
//                   LocaleKeys.bought.tr(),
//                   style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                     color: AppColors.yellow,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 6.sp,
//                 ),
//                 Material(
//                   color: AppColors.blueColor,
//                   borderRadius: BorderRadius.circular(8.sp),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 12.sp,
//                       vertical: 3.h,
//                     ),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////// trade.qty
//                     child: Text(
//                       '+${trade.qty}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineSmall
//                           ?.copyWith(color: AppColors.white, fontSize: 13),
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '@ ',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: AppColors.greyText,
//                   ),
//                 ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// open price
//                 Text(
//                   trade.openPrice!.toStringAsFixed(2),
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: AppColors.white,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 12.sp,
//             ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// live price
//             Row(
//               children: [
//                 Text(
//                   LocaleKeys.currentPrice.tr().toUpperCase(),
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.yellow,
//                   ),
//                 ),
//                 const Spacer(),
//                 ///////////////////////////////////////////////////////////////////////////////////////////////////////// profit Or Lose
//                 Text(
//                   '2,025.8',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.white,
//                   ),
//                 ),
//               ],
//             ),
//             Divider(
//               height: 20.h,
//               color: AppColors.greyText,
//             ),
//             Row(
//               children: [
//                 Text(
//                   LocaleKeys.profit.tr().toUpperCase(),
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.yellow,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '+\$ 45.85',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.blueColor,
//                   ),
//                 ),
//               ],
//             ),
//             Divider(
//               height: 20.h,
//               color: AppColors.greyText,
//             ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// app Commision
//             Row(
//               children: [
//                 Text(
//                   LocaleKeys.appCommision.tr().toUpperCase(),
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.yellow,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   "12223",
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.white,
//                   ),
//                 ),
//               ],
//             ),
//             Divider(
//               height: 20.h,
//               color: AppColors.greyText,
//             ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// position Details
// //             InkWell(
// //               onTap: () => _showOrderDetailsSheet(context),
// //               child: Row(
// //                 children: [
// //                   Text(
// //                     LocaleKeys.positionDetails.tr().toUpperCase(),
// //                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                           color: AppColors.yellow,
// //                         ),
// //                   ),
// //                   SizedBox(
// //                     width: 6.sp,
// //                   ),
// //                   const Icon(
// //                     Icons.info_outline_rounded,
// //                     color: AppColors.greyText,
// //                   ),
// //                 ],
// //               ),
// //             ),
//
//
//
//             SizedBox(
//               height: 0.5.sh,
//               child: DefaultTabController(
//                 initialIndex: 0,
//                 length: 2,
//                 child: Column(
//                   children: [
//                     DecoratedBox(
//                       decoration: BoxDecoration(
//                         //This is for background color
//                         color: AppColors.transparent,
//                         //This is for bottom border that is needed
//                         border: Border(
//                           bottom: BorderSide(
//                             color: AppColors.grey,
//                             width: 0.8.sp,
//                           ),
//                         ),
//                       ),
//                       child: TabBar(
//                         tabs: [
//                           Tab(
//                             text: LocaleKeys.edit.tr(),
//                           ),
//                           Tab(
//                             text: LocaleKeys.sell.tr(),
//                           ),
//                         ],
//                         onTap: (index) {
//                           // productCubit.getProducts(index);
//                         },
//                       ),
//                     ),
//                     Expanded(
//                       child: TabBarView(
//                         children: [
//                           Column(
//
//                             // physics:  const NeverScrollableScrollPhysics(),
//
//                             // padding: EdgeInsets.symmetric(vertical: 12.h),
//                             children: [
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// Stop Loss XXXXXXXXXXXXXXxX
//                               Container(
//
//                                 padding: EdgeInsets.all(12.sp),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   border: Border.all(
//                                     color: AppColors.yellowBorder,
//                                     width: 1.w,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             LocaleKeys.stopLoss.tr(),
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyLarge
//                                                 ?.copyWith(
//                                               color: AppColors.yellow,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 12.w,
//                                         ),
//                                         BlocBuilder<ProductCubit, ProductState>(
//                                           buildWhen: (previous, current) {
//                                             return current
//                                             is ChangeStopLossState ||
//                                                 current
//                                                 is ResetControllersState;
//                                           },
//                                           builder: (context, state) {
//                                             var cubit =
//                                             ProductCubit.get(context);
//                                             return Switch.adaptive(
//                                               value: cubit.stopLoss,
//                                               onChanged: (value) {
//                                                 cubit.changeStopLoss(value);
//                                               },
//                                               activeColor: AppColors.yellow,
//                                               inactiveThumbColor:
//                                               AppColors.yellow,
//                                               inactiveTrackColor: AppColors.grey
//                                                   .withOpacity(0.8),
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                     BlocBuilder<ProductCubit, ProductState>(
//                                       buildWhen: (previous, current) {
//                                         return current is ChangeStopLossState ||
//                                             current is ResetControllersState;
//                                       },
//                                       builder: (context, state) {
//                                         var cubit = ProductCubit.get(context);
//                                         return Visibility(
//                                           visible: cubit.stopLoss,
//                                           child: Column(
//                                             children: [
//                                               SizedBox(
//                                                 height: 12.h,
//                                               ),
//                                               Container(
//                                                 width: double.infinity,
//                                                 padding: EdgeInsets.all(8.sp),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                   BorderRadius.circular(
//                                                       12.r),
//                                                   border: Border.all(
//                                                     color:
//                                                     AppColors.yellowBorder,
//                                                     width: 1.w,
//                                                   ),
//                                                 ),
//                                                 child: Text(
//                                                   LocaleKeys.amount.tr(),
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .headlineMedium
//                                                       ?.copyWith(
//                                                     color: AppColors.yellow,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 height: 12.h,
//                                               ),
//                                               BlocBuilder<ProductCubit,
//                                                   ProductState>(
//                                                 buildWhen: (previous, current) {
//                                                   return current
//                                                   is AddAmountStopLossState ||
//                                                       current
//                                                       is SubtractAmountStopLossState ||
//                                                       current
//                                                       is ResetControllersState;
//                                                 },
//                                                 builder: (context, state) {
//                                                   var cubit =
//                                                   ProductCubit.get(context);
//
//                                                   return TextFormField(
//                                                     validator: (value) =>
//                                                         Validator
//                                                             .validateStopLoss(
//                                                           value: value,
//                                                           livePrice:
//                                                           1233,
//                                                         ),
//
//                                                     controller: cubit
//                                                         .stopLossController,
//                                                     textInputAction:
//                                                     TextInputAction.done,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .headlineMedium
//                                                         ?.copyWith(
//                                                       color:
//                                                       AppColors.white,
//                                                     ),
//                                                     keyboardType:
//                                                     const TextInputType
//                                                         .numberWithOptions(
//                                                         decimal: true),
//                                                     inputFormatters: [
//                                                       FilteringTextInputFormatter
//                                                           .allow(
//                                                         RegExp(
//                                                             r'^\d+\.?\d{0,2}'),
//                                                       ),
//                                                     ],
//                                                     onTapOutside: (_) {
//                                                       FocusScope.of(context)
//                                                           .unfocus();
//                                                     },
//                                                     decoration: InputDecoration(
//                                                       // hintText: '123',
//                                                       // hintStyle: Theme.of(context)
//                                                       //     .textTheme
//                                                       //     .headlineMedium
//                                                       //     ?.copyWith(
//                                                       //   color: AppColors.red,
//                                                       // ),
//                                                       // prefix: Text(
//                                                       //   '\$',
//                                                       //   style: Theme.of(context)
//                                                       //       .textTheme
//                                                       //       .headlineMedium
//                                                       //       ?.copyWith(
//                                                       //     color: AppColors.red,
//                                                       //   ),
//                                                       // ),
//                                                       isDense: true,
//                                                       contentPadding:
//                                                       EdgeInsets.symmetric(
//                                                         horizontal: 12.sp,
//                                                         vertical:12.sp,
//                                                       ),
//                                                       isCollapsed: true,
//                                                       alignLabelWithHint: true,
//                                                       // suffix: Row(
//                                                       //   mainAxisSize:
//                                                       //       MainAxisSize.min,
//                                                       //   children: [
//                                                       //     FloatingActionButton(
//                                                       //       onPressed: () {
//                                                       //         cubit
//                                                       //             .subtractAmountStopLoss();
//                                                       //       },
//                                                       //       heroTag: null,
//                                                       //       shape:
//                                                       //           const CircleBorder(),
//                                                       //       mini: true,
//                                                       //       materialTapTargetSize:
//                                                       //           MaterialTapTargetSize
//                                                       //               .shrinkWrap,
//                                                       //       backgroundColor:
//                                                       //           AppColors
//                                                       //               .transparent,
//                                                       //       child: const Center(
//                                                       //         child: Icon(
//                                                       //           FontAwesomeIcons
//                                                       //               .minus,
//                                                       //           color: AppColors
//                                                       //               .white,
//                                                       //         ),
//                                                       //       ),
//                                                       //     ),
//                                                       //     // FloatingActionButton(
//                                                       //     //   onPressed: () {
//                                                       //     //     cubit
//                                                       //     //         .addAmountStopLoss();
//                                                       //     //   },
//                                                       //     //   heroTag: null,
//                                                       //     //   shape:
//                                                       //     //       const CircleBorder(),
//                                                       //     //   mini: true,
//                                                       //     //   materialTapTargetSize:
//                                                       //     //       MaterialTapTargetSize
//                                                       //     //           .shrinkWrap,
//                                                       //     //   backgroundColor:
//                                                       //     //       AppColors
//                                                       //     //           .transparent,
//                                                       //     //   child: const Center(
//                                                       //     //     child: Icon(
//                                                       //     //       FontAwesomeIcons
//                                                       //     //           .plus,
//                                                       //     //       color: AppColors
//                                                       //     //           .white,
//                                                       //     //     ),
//                                                       //     //   ),
//                                                       //     // ),
//                                                       //   ],
//                                                       // ),
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 12.sp,
//                               ),
// ////////////////////////////////////////////////////////////////////////////////////////////////////////////// Take Profit
//                               Container(
//                                 padding: EdgeInsets.all(12.sp),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   border: Border.all(
//                                     color: AppColors.yellowBorder,
//                                     width: 1.w,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             LocaleKeys.takeProfit.tr(),
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyLarge
//                                                 ?.copyWith(
//                                               color: AppColors.yellow,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 12.w,
//                                         ),
//                                         BlocBuilder<ProductCubit, ProductState>(
//                                           buildWhen: (previous, current) {
//                                             return current
//                                             is ChangeTakeProfitState ||
//                                                 current
//                                                 is ResetControllersState;
//                                           },
//                                           builder: (context, state) {
//                                             var cubit =
//                                             ProductCubit.get(context);
//                                             return Switch.adaptive(
//                                               value: cubit.takeProfit,
//                                               onChanged: (value) {
//                                                 cubit.changeTakeProfit(value);
//                                               },
//                                               activeColor: AppColors.yellow,
//                                               inactiveThumbColor:
//                                               AppColors.yellow,
//                                               inactiveTrackColor: AppColors.grey
//                                                   .withOpacity(0.8),
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                     BlocBuilder<ProductCubit, ProductState>(
//                                       buildWhen: (previous, current) {
//                                         return current
//                                         is ChangeTakeProfitState ||
//                                             current is ResetControllersState;
//                                       },
//                                       builder: (context, state) {
//                                         var cubit = ProductCubit.get(context);
//                                         return Visibility(
//                                           visible: cubit.takeProfit,
//                                           child: Column(
//                                             children: [
//                                               SizedBox(
//                                                 height: 12.h,
//                                               ),
//                                               Container(
//                                                 width: double.infinity,
//                                                 padding: EdgeInsets.all(8.sp),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                   BorderRadius.circular(
//                                                       12.r),
//                                                   border: Border.all(
//                                                     color:
//                                                     AppColors.yellowBorder,
//                                                     width: 1.w,
//                                                   ),
//                                                 ),
//                                                 child: Text(
//                                                   LocaleKeys.amount.tr(),
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .headlineMedium
//                                                       ?.copyWith(
//                                                     color: AppColors.yellow,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 height: 12.h,
//                                               ),
//                                               BlocBuilder<ProductCubit,
//                                                   ProductState>(
//                                                 buildWhen: (previous, current) {
//                                                   return current
//                                                   is AddAmountTakeProfitState ||
//                                                       current
//                                                       is SubtractAmountTakeProfitState ||
//                                                       current
//                                                       is ResetControllersState;
//                                                 },
//                                                 builder: (context, state) {
//                                                   var cubit =
//                                                   ProductCubit.get(context);
//                                                   return TextFormField(
//                                                     controller: cubit
//                                                         .takeProfitController,
//                                                     textInputAction:
//                                                     TextInputAction.done,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .headlineMedium
//                                                         ?.copyWith(
//                                                       color:
//                                                       AppColors.white,
//                                                     ),
//                                                     keyboardType:
//                                                     const TextInputType
//                                                         .numberWithOptions(
//                                                         decimal: true),
//                                                     inputFormatters: [
//                                                       FilteringTextInputFormatter
//                                                           .allow(
//                                                         RegExp(
//                                                             r'^\d+\.?\d{0,2}'),
//                                                       ),
//                                                     ],
//                                                     onTapOutside: (_) {
//                                                       FocusScope.of(context)
//                                                           .unfocus();
//                                                     },
//                                                     decoration: InputDecoration(
//                                                       // hintText: '123',
//                                                       // hintStyle: Theme.of(context)
//                                                       //     .textTheme
//                                                       //     .headlineMedium
//                                                       //     ?.copyWith(
//                                                       //   color: AppColors.red,
//                                                       // ),
//                                                       // prefix: Text(
//                                                       //   '\$',
//                                                       //   style: Theme.of(context)
//                                                       //       .textTheme
//                                                       //       .headlineMedium
//                                                       //       ?.copyWith(
//                                                       //     color: AppColors.red,
//                                                       //   ),
//                                                       // ),
//                                                       isDense: true,
//                                                       contentPadding:
//                                                       EdgeInsets.symmetric(
//                                                         horizontal: 12.sp,
//                                                         vertical:12.sp,
//                                                       ),
//                                                       isCollapsed: true,
//                                                       alignLabelWithHint: true,
//                                                       // suffix: Row(
//                                                       //   mainAxisSize:
//                                                       //       MainAxisSize.min,
//                                                       //   children: [
//                                                       //     FloatingActionButton(
//                                                       //       onPressed: () {
//                                                       //         cubit
//                                                       //             .subtractAmountTakeProfit();
//                                                       //       },
//                                                       //       heroTag: null,
//                                                       //       shape:
//                                                       //           const CircleBorder(),
//                                                       //       mini: true,
//                                                       //       materialTapTargetSize:
//                                                       //           MaterialTapTargetSize
//                                                       //               .shrinkWrap,
//                                                       //       backgroundColor:
//                                                       //           AppColors
//                                                       //               .transparent,
//                                                       //       child: const Center(
//                                                       //         child: Icon(
//                                                       //           FontAwesomeIcons
//                                                       //               .minus,
//                                                       //           color: AppColors
//                                                       //               .white,
//                                                       //         ),
//                                                       //       ),
//                                                       //     ),
//                                                       //     FloatingActionButton(
//                                                       //       onPressed: () {
//                                                       //         cubit
//                                                       //             .addAmountTakeProfit();
//                                                       //       },
//                                                       //       heroTag: null,
//                                                       //       shape:
//                                                       //           const CircleBorder(),
//                                                       //       mini: true,
//                                                       //       materialTapTargetSize:
//                                                       //           MaterialTapTargetSize
//                                                       //               .shrinkWrap,
//                                                       //       backgroundColor:
//                                                       //           AppColors
//                                                       //               .transparent,
//                                                       //       child: const Center(
//                                                       //         child: Icon(
//                                                       //           FontAwesomeIcons
//                                                       //               .plus,
//                                                       //           color: AppColors
//                                                       //               .white,
//                                                       //         ),
//                                                       //       ),
//                                                       //     ),
//                                                       //   ],
//                                                       // ),
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 12.sp,
//                               ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// button edit
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 40.h,
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     var cubit = ProductCubit.get(context);
//
//                                     if (cubit.stopLoss == false &&
//                                         cubit.takeProfit == false) {
//                                       Toast.showMsg(
//                                           msg: LocaleKeys.canNotDoOpreation
//                                               .tr());
//                                       return;
//                                     }
//                                     AppLoader.showLoader(
//                                         context, ValueKey("updateOrder"));
//
//                                     print(" trad.id >>> ${trade.id}");
//                                     print( " takeProfitController >>> ${cubit.takeProfitController.text}");
//                                     print(  " stopLossController >>> ${cubit.stopLossController.text}");
//                                     print( " cubit.sellWhenPriceController >>> ${cubit.sellWhenPriceController.text}");
//
//
//                                     if (cubit.takeProfit == false) {
//                                       cubit.takeProfitController.text = "0";
//                                     }
//                                     if (cubit.stopLoss == false) {
//                                       cubit.stopLossController.text = "0";
//                                     }
//                                     // if(cubit.sellWhenPrice==false){
//                                     //   cubit.sellWhenPriceController.text="0";
//                                     // }
//
//                                     try {
//                                       print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
//                                       // await _appService.updateOrder(
//                                       //     orderId: trade.id ?? 0,
//                                       //     stopLoss: double.parse(cubit
//                                       //             .stopLossController
//                                       //             .text
//                                       //             .isEmpty
//                                       //         ? "0"
//                                       //         : cubit.stopLossController.text),
//                                       //     takeProfit: double.parse(cubit
//                                       //             .takeProfitController
//                                       //             .text
//                                       //             .isEmpty
//                                       //         ? "0"
//                                       //         : cubit
//                                       //             .takeProfitController.text),
//                                       //     ctx: context
//                                       //     // sellWhenPrice: double.parse(cubit.sellWhenPriceController.text.isEmpty?"0":cubit.sellWhenPriceController.text),
//                                       //     );
//                                       // AppLoader.closeLoader(
//                                       //     context, ValueKey("updateOrder"));
//                                     } on DioException catch (e) {
//                                     } catch (e) {
//                                       // AppLoader.closeLoader(
//                                       //     context, ValueKey("updateOrder"));
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.yellow,
//                                     disabledBackgroundColor: AppColors.grey,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     LocaleKeys.updatePosition.tr(),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headlineMedium
//                                         ?.copyWith(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// button sell  close
//                           Column(
//                             children: [
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 40.h,
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     // AppLoader.showLoader(
//                                     //     context, ValueKey("sell_price"));
//                                     // await _appService.sellOrder(
//                                     //     orderId: trade.id ?? 0, ctx: context);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.yellow,
//                                     disabledBackgroundColor: AppColors.grey,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     LocaleKeys.close.tr(),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headlineMedium
//                                         ?.copyWith(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 12.sp,
//                               ),
// ///////////////////////////////////////////////////////////////////////////////////////////////////////// button sell  deliveryData
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 40.h,
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     // final deliveryData =
//                                     //     await showDialog<Map<String, String>>(
//                                     //   context: context,
//                                     //   builder: (context) =>
//                                     //       const DeliveryDataDialog(),
//                                     // );
//                                     //
//                                     // if (deliveryData != null) {
//                                     //   print('البيانات: $deliveryData');
//
//                                     /*
//                                           print('Delivery Address: ${result['delivery_address']}');
//       print('Delivery City: ${result['delivery_city']}');
//       print('Delivery Phone: ${result['delivery_phone']}');
//                                        */
//
//
//                                     // AppLoader.showLoader(
//                                     //     context, ValueKey("requestDelivery"));
//                                     // _appService.requestDelivery(
//                                     //     orderId: trade.id ?? 0,
//                                     //     deliveryAddress: deliveryData[
//                                     //             "delivery_address"] ??
//                                     //         '',
//                                     //     deliveryCity:
//                                     //         deliveryData["delivery_city"] ??
//                                     //             '',
//                                     //     deliveryPhone:
//                                     //         deliveryData["delivery_phone"] ??
//                                     //             '',
//                                     //     ctx: context);
//                                     // }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.yellow,
//                                     disabledBackgroundColor: AppColors.grey,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     LocaleKeys.delivery.tr(),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headlineMedium
//                                         ?.copyWith(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   void _showOrderDetailsSheet(BuildContext context) {
//
//
//
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.grey,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) => Container(
//         padding: EdgeInsets.all(24.sp),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Order details',
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 24.h),
//             _buildSheetRow(
//               'Trade size',
//               '\$${ '1,750.00'}',
//               hasInfo: true,
//             ),
//             Divider(color: AppColors.lightGrey, height: 32.h),
//             _buildSheetRow(
//               'Leverage',
//               ' 1:1 ',
//             ),
// // Divider(color: AppColors.lightGrey, height: 32.h),
// // _buildSheetRow(
// //   'Margin',
// //   '\$${order?.margin.toStringAsFixed(2) ?? '17.50'}',
// //   hasInfo: true,
// // ),
//             Divider(color: AppColors.lightGrey, height: 32.h),
//             _buildSheetRow(
//               'app commision',
//               '-\$${ '0.27'}',
//               hasInfo: true,
//             ),
//             SizedBox(height: 24.h),
//             InkWell(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 16.h),
//                 decoration: BoxDecoration(
//                   color: AppColors.yellow,
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Close',
//                     style: TextStyle(
//                       color: AppColors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildSheetRow(String label, String value, {bool hasInfo = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: AppColors.greyText,
//                 fontSize: 16.sp,
//               ),
//             ),
//             // if (hasInfo) ...[
//             //   SizedBox(width: 8.w),
//             //   Icon(
//             //     Icons.info_outline,
//             //     color: AppColors.greyText,
//             //     size: 18.sp,
//             //   ),
//             // ],
//           ],
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: AppColors.white,
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////// old code

///////////////////////////////////////////////////////////////////////////////////////////////// before osama

// class TradeDetailsScreen extends StatelessWidget {
//   TradeOrOrder trade;
//   TradeDetailsScreen(this.trade, {super.key});
//
//   ApiService _appService = ApiService();
//   @override
//   Widget build(BuildContext context) {
//     var cubit = ProductCubit.get(context);
//
//     cubit.takeProfitController.text = trade.takeProfit ?? "0";
//     cubit.stopLossController.text = trade.stopLoss ?? "0";
//     return Scaffold(
//       // extendBodyBehindAppBar: true,
//       backgroundColor: AppColors.transparent,
//       body: GradientWidget(
//         child: ListView(
//           padding: EdgeInsets.all(12.sp),
//           children: [
//             const AppBarCustom(
//               showBalance: true,
//             ),
//             Align(
//               alignment: Alignment.center,
//               child: Text(
//                 LocaleKeys.gold.tr(),
//                 style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                   color: AppColors.white,
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.center,
//               child: Text(
//                 LocaleKeys.goldSpot.tr(),
//                 style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                   color: AppColors.greyText,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 12.sp,
//             ),
//             Container(
//               padding: EdgeInsets.all(12.sp),
//               decoration: BoxDecoration(
//                 color: AppColors.purple2,
//                 borderRadius: BorderRadius.circular(12.sp),
//               ),
//               child: Text(
//                 LocaleKeys.marketIsClosedItOpensIn.tr(
//                   namedArgs: {
//                     'days': '1',
//                   },
//                 ),
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context)
//                     .textTheme
//                     .labelMedium
//                     ?.copyWith(color: AppColors.white, fontSize: 13.sp),
//               ),
//             ),
//             SizedBox(
//               height: 12.sp,
//             ),
//             Text(
//               //"${trad.}",
//               '5-1-2024, 10:44 pm',
//               style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                 color: AppColors.greyText,
//               ),
//             ),
//             SizedBox(
//               height: 12.sp,
//             ),
//             Row(
//               children: [
//                 Text(
//                   LocaleKeys.bought.tr(),
//                   style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                     color: AppColors.white,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 6.sp,
//                 ),
//                 Material(
//                   color: AppColors.blueColor,
//                   borderRadius: BorderRadius.circular(8.sp),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 12.sp,
//                       vertical: 3.h,
//                     ),
//                     child: Text(
//                       '+${trade.qty}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineSmall
//                           ?.copyWith(color: AppColors.white, fontSize: 13),
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '@ ',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: AppColors.greyText,
//                   ),
//                 ),
//                 Text(
//                   '2,025.8',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: AppColors.white,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 12.sp,
//             ),
//             Row(
//               children: [
//                 Text(
//                   LocaleKeys.currentPrice.tr().toUpperCase(),
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.greyText,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '2,025.8',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.white,
//                   ),
//                 ),
//               ],
//             ),
//             Divider(
//               height: 20.h,
//               color: AppColors.greyText,
//             ),
//             Row(
//               children: [
//                 Text(
//                   LocaleKeys.profit.tr().toUpperCase(),
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.greyText,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '+\$ 45.85',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.blueColor,
//                   ),
//                 ),
//               ],
//             ),
//             Divider(
//               height: 20.h,
//               color: AppColors.greyText,
//             ),
//             Row(
//               children: [
//                 Text(
//                   LocaleKeys.appCommision.tr().toUpperCase(),
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.greyText,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   "12223",
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.white,
//                   ),
//                 ),
//               ],
//             ),
//             Divider(
//               height: 20.h,
//               color: AppColors.greyText,
//             ),
//
//             InkWell(
//               onTap: () => _showOrderDetailsSheet(context),
//               child: Row(
//                 children: [
//                   Text(
//                     LocaleKeys.positionDetails.tr().toUpperCase(),
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       color: AppColors.greyText,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 6.sp,
//                   ),
//                   const Icon(
//                     Icons.info_outline_rounded,
//                     color: AppColors.greyText,
//                   ),
//                 ],
//               ),
//             ),
//
//
//
//             SizedBox(
//               height: 0.5.sh,
//               child: DefaultTabController(
//                 initialIndex: 0,
//                 length: 2,
//                 child: Column(
//                   children: [
//                     DecoratedBox(
//                       decoration: BoxDecoration(
//                         //This is for background color
//                         color: AppColors.transparent,
//                         //This is for bottom border that is needed
//                         border: Border(
//                           bottom: BorderSide(
//                             color: AppColors.grey,
//                             width: 0.8.sp,
//                           ),
//                         ),
//                       ),
//                       child: TabBar(
//                         tabs: [
//                           Tab(
//                             text: LocaleKeys.edit.tr(),
//                           ),
//                           Tab(
//                             text: LocaleKeys.sell.tr(),
//                           ),
//                         ],
//                         onTap: (index) {
//                           // productCubit.getProducts(index);
//                         },
//                       ),
//                     ),
//                     Expanded(
//                       child: TabBarView(
//                         children: [
//                           ListView(
//                             padding: EdgeInsets.symmetric(vertical: 12.h),
//                             children: [
//                               /// Stop Loss
//                               Container(
//                                 padding: EdgeInsets.all(12.sp),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   border: Border.all(
//                                     color: AppColors.yellowBorder,
//                                     width: 1.w,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             LocaleKeys.stopLoss.tr(),
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyLarge
//                                                 ?.copyWith(
//                                               color: AppColors.white,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 12.w,
//                                         ),
//                                         BlocBuilder<ProductCubit, ProductState>(
//                                           buildWhen: (previous, current) {
//                                             return current
//                                             is ChangeStopLossState ||
//                                                 current
//                                                 is ResetControllersState;
//                                           },
//                                           builder: (context, state) {
//                                             var cubit =
//                                             ProductCubit.get(context);
//                                             return Switch.adaptive(
//                                               value: cubit.stopLoss,
//                                               onChanged: (value) {
//                                                 cubit.changeStopLoss(value);
//                                               },
//                                               activeColor: AppColors.yellow,
//                                               inactiveThumbColor:
//                                               AppColors.grey,
//                                               inactiveTrackColor: AppColors.grey
//                                                   .withOpacity(0.8),
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                     BlocBuilder<ProductCubit, ProductState>(
//                                       buildWhen: (previous, current) {
//                                         return current is ChangeStopLossState ||
//                                             current is ResetControllersState;
//                                       },
//                                       builder: (context, state) {
//                                         var cubit = ProductCubit.get(context);
//                                         return Visibility(
//                                           visible: cubit.stopLoss,
//                                           child: Column(
//                                             children: [
//                                               SizedBox(
//                                                 height: 12.h,
//                                               ),
//                                               Container(
//                                                 width: double.infinity,
//                                                 padding: EdgeInsets.all(8.sp),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                   BorderRadius.circular(
//                                                       12.r),
//                                                   border: Border.all(
//                                                     color:
//                                                     AppColors.yellowBorder,
//                                                     width: 1.w,
//                                                   ),
//                                                 ),
//                                                 child: Text(
//                                                   LocaleKeys.amount.tr(),
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .headlineMedium
//                                                       ?.copyWith(
//                                                     color: AppColors.white,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 height: 12.h,
//                                               ),
//                                               BlocBuilder<ProductCubit,
//                                                   ProductState>(
//                                                 buildWhen: (previous, current) {
//                                                   return current
//                                                   is AddAmountStopLossState ||
//                                                       current
//                                                       is SubtractAmountStopLossState ||
//                                                       current
//                                                       is ResetControllersState;
//                                                 },
//                                                 builder: (context, state) {
//                                                   var cubit =
//                                                   ProductCubit.get(context);
//
//                                                   return TextFormField(
//                                                     controller: cubit
//                                                         .stopLossController,
//                                                     textInputAction:
//                                                     TextInputAction.done,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .headlineMedium
//                                                         ?.copyWith(
//                                                       color:
//                                                       AppColors.white,
//                                                     ),
//                                                     keyboardType:
//                                                     const TextInputType
//                                                         .numberWithOptions(
//                                                         decimal: true),
//                                                     inputFormatters: [
//                                                       FilteringTextInputFormatter
//                                                           .allow(
//                                                         RegExp(
//                                                             r'^\d+\.?\d{0,2}'),
//                                                       ),
//                                                     ],
//                                                     onTapOutside: (_) {
//                                                       FocusScope.of(context)
//                                                           .unfocus();
//                                                     },
//                                                     decoration: InputDecoration(
//                                                       // hintText: '123',
//                                                       // hintStyle: Theme.of(context)
//                                                       //     .textTheme
//                                                       //     .headlineMedium
//                                                       //     ?.copyWith(
//                                                       //   color: AppColors.red,
//                                                       // ),
//                                                       // prefix: Text(
//                                                       //   '\$',
//                                                       //   style: Theme.of(context)
//                                                       //       .textTheme
//                                                       //       .headlineMedium
//                                                       //       ?.copyWith(
//                                                       //     color: AppColors.red,
//                                                       //   ),
//                                                       // ),
//                                                       isDense: true,
//                                                       contentPadding:
//                                                       EdgeInsets.symmetric(
//                                                         horizontal: 12.sp,
//                                                         vertical: 6.sp,
//                                                       ),
//                                                       isCollapsed: true,
//                                                       alignLabelWithHint: true,
//                                                       suffix: Row(
//                                                         mainAxisSize:
//                                                         MainAxisSize.min,
//                                                         children: [
//                                                           FloatingActionButton(
//                                                             onPressed: () {
//                                                               cubit
//                                                                   .subtractAmountStopLoss();
//                                                             },
//                                                             heroTag: null,
//                                                             shape:
//                                                             const CircleBorder(),
//                                                             mini: true,
//                                                             materialTapTargetSize:
//                                                             MaterialTapTargetSize
//                                                                 .shrinkWrap,
//                                                             backgroundColor:
//                                                             AppColors
//                                                                 .transparent,
//                                                             child: const Center(
//                                                               child: Icon(
//                                                                 FontAwesomeIcons
//                                                                     .minus,
//                                                                 color: AppColors
//                                                                     .white,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           FloatingActionButton(
//                                                             onPressed: () {
//                                                               cubit
//                                                                   .addAmountStopLoss();
//                                                             },
//                                                             heroTag: null,
//                                                             shape:
//                                                             const CircleBorder(),
//                                                             mini: true,
//                                                             materialTapTargetSize:
//                                                             MaterialTapTargetSize
//                                                                 .shrinkWrap,
//                                                             backgroundColor:
//                                                             AppColors
//                                                                 .transparent,
//                                                             child: const Center(
//                                                               child: Icon(
//                                                                 FontAwesomeIcons
//                                                                     .plus,
//                                                                 color: AppColors
//                                                                     .white,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 12.sp,
//                               ),
//
//                               /// Take Profit
//                               Container(
//                                 padding: EdgeInsets.all(12.sp),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   border: Border.all(
//                                     color: AppColors.yellowBorder,
//                                     width: 1.w,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             LocaleKeys.takeProfit.tr(),
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyLarge
//                                                 ?.copyWith(
//                                               color: AppColors.white,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 12.w,
//                                         ),
//                                         BlocBuilder<ProductCubit, ProductState>(
//                                           buildWhen: (previous, current) {
//                                             return current
//                                             is ChangeTakeProfitState ||
//                                                 current
//                                                 is ResetControllersState;
//                                           },
//                                           builder: (context, state) {
//                                             var cubit =
//                                             ProductCubit.get(context);
//                                             return Switch.adaptive(
//                                               value: cubit.takeProfit,
//                                               onChanged: (value) {
//                                                 cubit.changeTakeProfit(value);
//                                               },
//                                               activeColor: AppColors.yellow,
//                                               inactiveThumbColor:
//                                               AppColors.grey,
//                                               inactiveTrackColor: AppColors.grey
//                                                   .withOpacity(0.8),
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                     BlocBuilder<ProductCubit, ProductState>(
//                                       buildWhen: (previous, current) {
//                                         return current
//                                         is ChangeTakeProfitState ||
//                                             current is ResetControllersState;
//                                       },
//                                       builder: (context, state) {
//                                         var cubit = ProductCubit.get(context);
//                                         return Visibility(
//                                           visible: cubit.takeProfit,
//                                           child: Column(
//                                             children: [
//                                               SizedBox(
//                                                 height: 12.h,
//                                               ),
//                                               Container(
//                                                 width: double.infinity,
//                                                 padding: EdgeInsets.all(8.sp),
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                   BorderRadius.circular(
//                                                       12.r),
//                                                   border: Border.all(
//                                                     color:
//                                                     AppColors.yellowBorder,
//                                                     width: 1.w,
//                                                   ),
//                                                 ),
//                                                 child: Text(
//                                                   LocaleKeys.amount.tr(),
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .headlineMedium
//                                                       ?.copyWith(
//                                                     color: AppColors.white,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 height: 12.h,
//                                               ),
//                                               BlocBuilder<ProductCubit,
//                                                   ProductState>(
//                                                 buildWhen: (previous, current) {
//                                                   return current
//                                                   is AddAmountTakeProfitState ||
//                                                       current
//                                                       is SubtractAmountTakeProfitState ||
//                                                       current
//                                                       is ResetControllersState;
//                                                 },
//                                                 builder: (context, state) {
//                                                   var cubit =
//                                                   ProductCubit.get(context);
//                                                   return TextFormField(
//                                                     controller: cubit
//                                                         .takeProfitController,
//                                                     textInputAction:
//                                                     TextInputAction.done,
//                                                     style: Theme.of(context)
//                                                         .textTheme
//                                                         .headlineMedium
//                                                         ?.copyWith(
//                                                       color:
//                                                       AppColors.white,
//                                                     ),
//                                                     keyboardType:
//                                                     const TextInputType
//                                                         .numberWithOptions(
//                                                         decimal: true),
//                                                     inputFormatters: [
//                                                       FilteringTextInputFormatter
//                                                           .allow(
//                                                         RegExp(
//                                                             r'^\d+\.?\d{0,2}'),
//                                                       ),
//                                                     ],
//                                                     onTapOutside: (_) {
//                                                       FocusScope.of(context)
//                                                           .unfocus();
//                                                     },
//                                                     decoration: InputDecoration(
//                                                       // hintText: '123',
//                                                       // hintStyle: Theme.of(context)
//                                                       //     .textTheme
//                                                       //     .headlineMedium
//                                                       //     ?.copyWith(
//                                                       //   color: AppColors.red,
//                                                       // ),
//                                                       // prefix: Text(
//                                                       //   '\$',
//                                                       //   style: Theme.of(context)
//                                                       //       .textTheme
//                                                       //       .headlineMedium
//                                                       //       ?.copyWith(
//                                                       //     color: AppColors.red,
//                                                       //   ),
//                                                       // ),
//                                                       isDense: true,
//                                                       contentPadding:
//                                                       EdgeInsets.symmetric(
//                                                         horizontal: 12.sp,
//                                                         vertical: 6.sp,
//                                                       ),
//                                                       isCollapsed: true,
//                                                       alignLabelWithHint: true,
//                                                       suffix: Row(
//                                                         mainAxisSize:
//                                                         MainAxisSize.min,
//                                                         children: [
//                                                           FloatingActionButton(
//                                                             onPressed: () {
//                                                               cubit
//                                                                   .subtractAmountTakeProfit();
//                                                             },
//                                                             heroTag: null,
//                                                             shape:
//                                                             const CircleBorder(),
//                                                             mini: true,
//                                                             materialTapTargetSize:
//                                                             MaterialTapTargetSize
//                                                                 .shrinkWrap,
//                                                             backgroundColor:
//                                                             AppColors
//                                                                 .transparent,
//                                                             child: const Center(
//                                                               child: Icon(
//                                                                 FontAwesomeIcons
//                                                                     .minus,
//                                                                 color: AppColors
//                                                                     .white,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           FloatingActionButton(
//                                                             onPressed: () {
//                                                               cubit
//                                                                   .addAmountTakeProfit();
//                                                             },
//                                                             heroTag: null,
//                                                             shape:
//                                                             const CircleBorder(),
//                                                             mini: true,
//                                                             materialTapTargetSize:
//                                                             MaterialTapTargetSize
//                                                                 .shrinkWrap,
//                                                             backgroundColor:
//                                                             AppColors
//                                                                 .transparent,
//                                                             child: const Center(
//                                                               child: Icon(
//                                                                 FontAwesomeIcons
//                                                                     .plus,
//                                                                 color: AppColors
//                                                                     .white,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 12.sp,
//                               ),
//
//                               /// Sell when Price
//                               // Container(
//                               //   padding: EdgeInsets.all(12.sp),
//                               //   decoration: BoxDecoration(
//                               //     borderRadius: BorderRadius.circular(12.r),
//                               //     border: Border.all(
//                               //       color: AppColors.yellowBorder,
//                               //       width: 1.w,
//                               //     ),
//                               //   ),
//                               //   child: Column(
//                               //     crossAxisAlignment: CrossAxisAlignment.start,
//                               //     children: [
//                               //       Row(
//                               //         children: [
//                               //           Expanded(
//                               //             child: Text(
//                               //               LocaleKeys.sellWhenPrice.tr(),
//                               //               style: Theme.of(context)
//                               //                   .textTheme
//                               //                   .bodyLarge
//                               //                   ?.copyWith(
//                               //                 color: AppColors.white,
//                               //               ),
//                               //             ),
//                               //           ),
//                               //           SizedBox(
//                               //             width: 12.w,
//                               //           ),
//                               //           BlocBuilder<ProductCubit, ProductState>(
//                               //             buildWhen: (previous, current) {
//                               //               return current is ChangeSellWhenPriceState ||
//                               //                   current is ResetControllersState;
//                               //             },
//                               //             builder: (context, state) {
//                               //               var cubit = ProductCubit.get(context);
//                               //               return Switch.adaptive(
//                               //                 value: cubit.sellWhenPrice,
//                               //                 onChanged: (value) {
//                               //                   print("value >>>>> $value");
//                               //                   cubit.changeSellWhenPrice(value);
//                               //                 },
//                               //                 activeColor: AppColors.green,
//                               //                 inactiveThumbColor: AppColors.grey,
//                               //                 inactiveTrackColor:
//                               //                 AppColors.grey.withOpacity(0.8),
//                               //               );
//                               //             },
//                               //           ),
//                               //         ],
//                               //       ),
//                               //       BlocBuilder<ProductCubit, ProductState>(
//                               //         buildWhen: (previous, current) {
//                               //           return current is ChangeSellWhenPriceState ||
//                               //               current is ResetControllersState;
//                               //         },
//                               //         builder: (context, state) {
//                               //           var cubit = ProductCubit.get(context);
//                               //           return Visibility(
//                               //             visible: cubit.sellWhenPrice,
//                               //             child: Column(
//                               //               children: [
//                               //                 SizedBox(
//                               //                   height: 12.h,
//                               //                 ),
//                               //                 Container(
//                               //                   width: double.infinity,
//                               //                   padding: EdgeInsets.all(8.sp),
//                               //                   decoration: BoxDecoration(
//                               //                     borderRadius:
//                               //                     BorderRadius.circular(12.r),
//                               //                     border: Border.all(
//                               //                       color: AppColors.yellowBorder,
//                               //                       width: 1.w,
//                               //                     ),
//                               //                   ),
//                               //                   child: Text(
//                               //                     LocaleKeys.amount.tr(),
//                               //                     style: Theme.of(context)
//                               //                         .textTheme
//                               //                         .headlineMedium
//                               //                         ?.copyWith(
//                               //                       color: AppColors.white,
//                               //                     ),
//                               //                   ),
//                               //                 ),
//                               //                 SizedBox(
//                               //                   height: 12.h,
//                               //                 ),
//                               //                 BlocBuilder<ProductCubit, ProductState>(
//                               //                   buildWhen: (previous, current) {
//                               //                     return current
//                               //                     is AddAmountTakeProfitState ||
//                               //                         current
//                               //                         is SubtractAmountTakeProfitState ||
//                               //                         current is ResetControllersState;
//                               //                   },
//                               //                   builder: (context, state) {
//                               //                     var cubit = ProductCubit.get(context);
//                               //                     return TextFormField(
//                               //                       controller:
//                               //                       cubit.sellWhenPriceController,
//                               //                       textInputAction: TextInputAction.done,
//                               //                       style: Theme.of(context)
//                               //                           .textTheme
//                               //                           .headlineMedium
//                               //                           ?.copyWith(
//                               //                         color: AppColors.red,
//                               //                       ),
//                               //                       keyboardType: const TextInputType
//                               //                           .numberWithOptions(decimal: true),
//                               //                       inputFormatters: [
//                               //                         FilteringTextInputFormatter.allow(
//                               //                           RegExp(r'^\d+\.?\d{0,2}'),
//                               //                         ),
//                               //                       ],
//                               //                       onTapOutside: (_) {
//                               //                         FocusScope.of(context).unfocus();
//                               //                       },
//                               //                       decoration: InputDecoration(
//                               //                         hintText: '123',
//                               //                         hintStyle: Theme.of(context)
//                               //                             .textTheme
//                               //                             .headlineMedium
//                               //                             ?.copyWith(
//                               //                           color: AppColors.red,
//                               //                         ),
//                               //                         prefix: Text(
//                               //                           '\$',
//                               //                           style: Theme.of(context)
//                               //                               .textTheme
//                               //                               .headlineMedium
//                               //                               ?.copyWith(
//                               //                             color: AppColors.red,
//                               //                           ),
//                               //                         ),
//                               //                         isDense: true,
//                               //                         contentPadding:
//                               //                         EdgeInsets.symmetric(
//                               //                           horizontal: 12.sp,
//                               //                           vertical: 6.sp,
//                               //                         ),
//                               //                         isCollapsed: true,
//                               //                         alignLabelWithHint: true,
//                               //                         suffix: Row(
//                               //                           mainAxisSize: MainAxisSize.min,
//                               //                           children: [
//                               //                             FloatingActionButton(
//                               //                               onPressed: () {
//                               //                                 cubit
//                               //                                     .subtractAmountTakeProfit();
//                               //                               },
//                               //                               heroTag: null,
//                               //                               shape: const CircleBorder(),
//                               //                               mini: true,
//                               //                               materialTapTargetSize:
//                               //                               MaterialTapTargetSize
//                               //                                   .shrinkWrap,
//                               //                               backgroundColor:
//                               //                               AppColors.transparent,
//                               //                               child: const Center(
//                               //                                 child: Icon(
//                               //                                   FontAwesomeIcons.minus,
//                               //                                   color: AppColors.white,
//                               //                                 ),
//                               //                               ),
//                               //                             ),
//                               //                             FloatingActionButton(
//                               //                               onPressed: () {
//                               //                                 cubit.addSellWhenPriceProfit();
//                               //                               },
//                               //                               heroTag: null,
//                               //                               shape: const CircleBorder(),
//                               //                               mini: true,
//                               //                               materialTapTargetSize:
//                               //                               MaterialTapTargetSize
//                               //                                   .shrinkWrap,
//                               //                               backgroundColor:
//                               //                               AppColors.transparent,
//                               //                               child: const Center(
//                               //                                 child: Icon(
//                               //                                   FontAwesomeIcons.plus,
//                               //                                   color: AppColors.white,
//                               //                                 ),
//                               //                               ),
//                               //                             ),
//                               //                           ],
//                               //                         ),
//                               //                       ),
//                               //                     );
//                               //                   },
//                               //                 ),
//                               //               ],
//                               //             ),
//                               //           );
//                               //         },
//                               //       ),
//                               //
//                               //
//                               //
//                               //     ],
//                               //   ),
//                               // ),
//                               //
//                               // SizedBox(
//                               //   height: 12.sp,
//                               // ),
//
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 40.h,
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     var cubit = ProductCubit.get(context);
//
//                                     if (cubit.stopLoss == false &&
//                                         cubit.takeProfit == false) {
//                                       Toast.showMsg(
//                                           msg: LocaleKeys.canNotDoOpreation
//                                               .tr());
//                                       return;
//                                     }
//                                     AppLoader.showLoader(
//                                         context, ValueKey("updateOrder"));
//
//                                     print(" trad.id >>> ${trade.id}");
//                                     print(
//                                         " takeProfitController >>> ${cubit.takeProfitController.text}");
//                                     print(
//                                         " stopLossController >>> ${cubit.stopLossController.text}");
//                                     print(
//                                         " cubit.sellWhenPriceController >>> ${cubit.sellWhenPriceController.text}");
//
//                                     if (cubit.takeProfit == false) {
//                                       cubit.takeProfitController.text = "0";
//                                     }
//                                     if (cubit.stopLoss == false) {
//                                       cubit.stopLossController.text = "0";
//                                     }
//                                     // if(cubit.sellWhenPrice==false){
//                                     //   cubit.sellWhenPriceController.text="0";
//                                     // }
//
//                                     try {
//                                       await _appService.updateOrder(
//                                           orderId: trade.id ?? 0,
//                                           stopLoss: double.parse(cubit
//                                               .stopLossController
//                                               .text
//                                               .isEmpty
//                                               ? "0"
//                                               : cubit.stopLossController.text),
//                                           takeProfit: double.parse(cubit
//                                               .takeProfitController
//                                               .text
//                                               .isEmpty
//                                               ? "0"
//                                               : cubit
//                                               .takeProfitController.text),
//                                           ctx: context
//                                         // sellWhenPrice: double.parse(cubit.sellWhenPriceController.text.isEmpty?"0":cubit.sellWhenPriceController.text),
//                                       );
//                                       AppLoader.closeLoader(
//                                           context, ValueKey("updateOrder"));
//                                     } on DioException catch (e) {
//                                     } catch (e) {
//                                       AppLoader.closeLoader(
//                                           context, ValueKey("updateOrder"));
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.yellow,
//                                     disabledBackgroundColor: AppColors.grey,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     LocaleKeys.updatePosition.tr(),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headlineMedium
//                                         ?.copyWith(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           ListView(
//                             children: [
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 40.h,
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     AppLoader.showLoader(
//                                         context, ValueKey("sell_price"));
//                                     await _appService.sellOrder(
//                                         orderId: trade.id ?? 0, ctx: context);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.yellow,
//                                     disabledBackgroundColor: AppColors.grey,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     LocaleKeys.close.tr(),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headlineMedium
//                                         ?.copyWith(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 12.sp,
//                               ),
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 40.h,
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     final deliveryData =
//                                     await showDialog<Map<String, String>>(
//                                       context: context,
//                                       builder: (context) =>
//                                       const DeliveryDataDialog(),
//                                     );
//
//                                     if (deliveryData != null) {
//                                       print('البيانات: $deliveryData');
//
//                                       /*
//                                           print('Delivery Address: ${result['delivery_address']}');
//       print('Delivery City: ${result['delivery_city']}');
//       print('Delivery Phone: ${result['delivery_phone']}');
//                                        */
//                                       AppLoader.showLoader(
//                                           context, ValueKey("requestDelivery"));
//                                       _appService.requestDelivery(
//                                           orderId: trade.id ?? 0,
//                                           deliveryAddress: deliveryData[
//                                           "delivery_address"] ??
//                                               '',
//                                           deliveryCity:
//                                           deliveryData["delivery_city"] ??
//                                               '',
//                                           deliveryPhone:
//                                           deliveryData["delivery_phone"] ??
//                                               '',
//                                           ctx: context);
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.yellow,
//                                     disabledBackgroundColor: AppColors.grey,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     LocaleKeys.delivery.tr(),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headlineMedium
//                                         ?.copyWith(
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   void _showOrderDetailsSheet(BuildContext context) {
//
//
//
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.grey,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) => Container(
//         padding: EdgeInsets.all(24.sp),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Order details',
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 24.h),
//             _buildSheetRow(
//               'Trade size',
//               '\$${ '1,750.00'}',
//               hasInfo: true,
//             ),
//             Divider(color: AppColors.lightGrey, height: 32.h),
//             _buildSheetRow(
//               'Leverage',
//               ' 1:1 ',
//             ),
// // Divider(color: AppColors.lightGrey, height: 32.h),
// // _buildSheetRow(
// //   'Margin',
// //   '\$${order?.margin.toStringAsFixed(2) ?? '17.50'}',
// //   hasInfo: true,
// // ),
//             Divider(color: AppColors.lightGrey, height: 32.h),
//             _buildSheetRow(
//               'app commision',
//               '-\$${ '0.27'}',
//               hasInfo: true,
//             ),
//             SizedBox(height: 24.h),
//             InkWell(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 16.h),
//                 decoration: BoxDecoration(
//                   color: AppColors.yellow,
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Close',
//                     style: TextStyle(
//                       color: AppColors.black,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildSheetRow(String label, String value, {bool hasInfo = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: AppColors.greyText,
//                 fontSize: 16.sp,
//               ),
//             ),
//             // if (hasInfo) ...[
//             //   SizedBox(width: 8.w),
//             //   Icon(
//             //     Icons.info_outline,
//             //     color: AppColors.greyText,
//             //     size: 18.sp,
//             //   ),
//             // ],
//           ],
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: AppColors.white,
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class DeliveryFeesDialog extends StatelessWidget {
//   final String deliveryFees;
//
//   const DeliveryFeesDialog({
//     Key? key,
//     required this.deliveryFees,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: AppColors.backgroundGrey,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.r),
//         side: BorderSide(
//           color: AppColors.grey,
//           width: 1.w,
//         ),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.backgroundGrey,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(
//             color: AppColors.grey,
//             width: 1.w,
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(24.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Delivery Fees',
//                     style: TextStyle(
//                       color: AppColors.yellow,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18.sp,
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.grey,
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: IconButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       icon: Icon(
//                         Icons.close,
//                         color: AppColors.white,
//                         size: 20.sp,
//                       ),
//                       padding: EdgeInsets.all(8.w),
//                     ),
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: 24.h),
//
//               // Delivery Icon
//               Container(
//                 width: 60.w,
//                 height: 60.h,
//                 decoration: BoxDecoration(
//                   color: AppColors.backgroundGrey2,
//                   borderRadius: BorderRadius.circular(30.r),
//                   border: Border.all(
//                     color: AppColors.yellow,
//                     width: 2.w,
//                   ),
//                 ),
//                 child: Icon(
//                   Icons.delivery_dining,
//                   color: AppColors.yellow,
//                   size: 30.sp,
//                 ),
//               ),
//
//               SizedBox(height: 16.h),
//
//               // Fees Amount
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 20.w,
//                   vertical: 12.h,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.backgroundGrey2,
//                   borderRadius: BorderRadius.circular(12.r),
//                   border: Border.all(
//                     color: AppColors.grey,
//                     width: 1.w,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Fees: ',
//                       style: TextStyle(
//                         color: AppColors.white,
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       deliveryFees,
//                       style: TextStyle(
//                         color: AppColors.yellow,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 24.h),
//
//               // OK Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 48.h,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.yellow,
//                     foregroundColor: AppColors.black,
//                     elevation: 0,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                   ),
//                   child: Text(
//                     'OK',
//                     style: TextStyle(
//                       color: AppColors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16.sp,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//
