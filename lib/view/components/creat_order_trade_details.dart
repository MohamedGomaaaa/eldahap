import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../model/metal_price_model.dart';
import '../../../../model/trade_order_model.dart';
import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../view_model/utils/colors.dart';
import '../../../../view_model/utils/common_method.dart';
import '../../l10n/locale_keys.g.dart';
import '../../view_model/cubit/trades_cubit/trades_cubit.dart';
import 'live_status_text.dart';
import 'live_text.dart';

class CreatTradeOrderDetails extends StatefulWidget {
  final TradeOrOrder tradeOrOrder;
  final bool isOrder;
  final String productTitle;
  const CreatTradeOrderDetails({
    super.key,
    required this.tradeOrOrder,
    required this.isOrder,
    required this.productTitle,
  });

  @override
  State<CreatTradeOrderDetails> createState() => _CreatTradeOrderDetailsState();
}

class _CreatTradeOrderDetailsState extends State<CreatTradeOrderDetails> {

  @override
  void initState() {
    super.initState();
    context.read<TradesCubit>().getCommissionRate();

  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivePriceCubit, LivePriceState>(
      builder: (context, liveState) {
        // ✅ العملة حسب category index (0 => USD, 1 => EGP)
        final String currencyKey = widget.tradeOrOrder.currency ?? "USD";
        // ✅ تحديد نوع المعدن
        final String metalKey = (widget.tradeOrOrder.metal ?? 'XAU').toUpperCase();
        MetalPrices? mp;
        if (liveState is LivePriceLive) {
          mp = liveState.metals[metalKey]?[currencyKey];
        }

        final double livePrice =
            (mp?.buy ?? 0).toDouble() * (widget.tradeOrOrder.unitGramWeight ?? 1);

        final double openPrice = (widget.tradeOrOrder.openPrice ?? 0).toDouble();

        // ✅ لو مفيش live فعلاً (لسه السوكت مجابش سعر)
        final bool hasLive = (liveState is LivePriceLive) && livePrice > 0;

        final double pnl =
            (livePrice - openPrice) * (widget.tradeOrOrder.quantity ?? 0).toDouble();

        final bool isProfit = pnl >= 0;

        return Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: const LiveStatusText(),
              ),
            ),
////////////////////////////////////////////////////////////////////////////////////////////////////////////  product name and weight
            Align(
              alignment: Alignment.center,
              child: Text(
                "${widget.productTitle} ${widget.tradeOrOrder.unitGramWeight} gm",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.white,
                    ),
              ),
            ),
            SizedBox(
              height: widget.isOrder == true ? 12.sp : 0,
            ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// grey creat ar
            widget.isOrder == true
                ? const SizedBox()
                : Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 10.sp),
                    child: Text(
                      Methods.formatCreatedAt(
                          widget.tradeOrOrder.createdAt!.toString()),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.greyText,
                          ),
                    ),
                  ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// Bought
            creatBuyPrice(context: context, isOrder: widget.isOrder),

///////////////////////////////////////////////////////////////////////////////////////////////////////// live price and live status
            Container(
              margin: EdgeInsets.only(bottom: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Current Price",
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: AppColors.yellow, fontSize: 19),
                  ),
                  LivePriceText(
                    price: livePrice,
                    decimals: 2,
                    fakeMinDelta: 0.01,
                    fakeMaxDelta: 0.05,
                    fakeTickEvery: const Duration(milliseconds: 900),
                  ),
                ],
              ),
            ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// trade id
            creatDetails(
              context: context,
              title: widget.isOrder ? 'order id' : 'trade id',
              value: widget.tradeOrOrder.id!,
              creatPnl: const SizedBox(),
            ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// order type
            widget.isOrder == true
                ? creatDetails(
                    context: context,
                    title: 'Type',
                    value: widget.tradeOrOrder.sellWhenPrice! < livePrice
                        ? 'Buy Limit'
                        : "Buy Stop",
                    creatPnl: const SizedBox(),
                  )
                : const SizedBox(),
///////////////////////////////////////////////////////////////////////////////////////////////////////// pl & profit Or Lose
            widget.isOrder == false
                ? creatDetails(
                    context: context,
                    title: 'P&L',
                    isPnl: true,
                    currency: widget.tradeOrOrder.currency!,
                    value: widget.tradeOrOrder.id!,
                    creatPnl: Flexible(
                      child: LivePriceText(
                        price: pnl,
                        decimals: 2,
                        fakeMinDelta: 0.01,
                        fakeMaxDelta: 0.05,
                        fakeTickEvery: const Duration(milliseconds: 900),
                        neutralColor: Colors.transparent,
                        upColor: Colors.transparent,
                        downColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        width: null, // ✅ ياخد عرض الأب (Flexible)
                        alignment: Alignment.centerRight,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isProfit
                                  ? AppColors.blueColor
                                  : AppColors.red,
                            ),
                      ),
                    ))
                : const SizedBox(),

//////////////////////////////////////////////////////////////////////////////////////////////////////// trade quantity
//         creatDetails(
//           context: context,
//           title: isOrder ? "amount to buy" : "Quantity",
//           value: tradeOrOrder.quantity.toString(),
//           creatPnl: const SizedBox(),
//         ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// trade size
            widget.isOrder == false
                ? creatDetails(
                    context: context,
                    title: "trade size",
                    value: (widget.tradeOrOrder.quantity ?? 0) * livePrice,
                    creatPnl: const SizedBox(),
                    currency: widget.tradeOrOrder.currency!)
                : const SizedBox(),
////////////////////////////////////////////////////////////////////////////////////////////////////////////// buy price
            creatDetails(
                context: context,
                title: "Buy price",
                value: widget.tradeOrOrder.openPrice!,
                creatPnl: const SizedBox(),
                currency: widget.tradeOrOrder.currency!),
////////////////////////////////////////////////////////////////////////////////////////////////////////////// Enter price
//             creatDetails(
//                 context: context,
//                 title: "Enter price",
//                 value: tradeOrOrder.entryPrice!,
//                 creatPnl: const SizedBox(),
//                 currency: tradeOrOrder.currency!),
////////////////////////////////////////////////////////////////////////////////////////////////////////////// sell when price
            creatDetails(
                context: context,
                title: "Buy When",
                value: widget.tradeOrOrder.sellWhenPrice!,
                creatPnl: const SizedBox(),
                currency: widget.tradeOrOrder.currency!),
////////////////////////////////////////////////////////////////////////////////////////////////////////////// close price
            creatDetails(
                context: context,
                title: "close price",
                value: widget.tradeOrOrder.closePrice!,
                creatPnl: const SizedBox(),
                currency: widget.tradeOrOrder.currency!),
////////////////////////////////////////////////////////////////////////////////////////////////////////////// close at
            creatDetails(
              context: context,
              title: "close At",
              value: widget.tradeOrOrder.closedAt.toString().trim().isNotEmpty
                  ? Methods.formatCreatedAt(widget.tradeOrOrder.closedAt!.toString())
                  : widget.tradeOrOrder.closedAt!.toString(),
              creatPnl: const SizedBox(),
            ),
////////////////////////////////////////////////////////////////////////////////////////////////////////////// close kind
            creatDetails(
              context: context,
              title: "close kind",
              value: widget.tradeOrOrder.closeKind.toString(),
              creatPnl: const SizedBox(),
            ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// take profit
            creatDetails(
                context: context,
                title: "take profit",
                value: widget.tradeOrOrder.takeProfit!,
                creatPnl: const SizedBox(),
                currency: widget.tradeOrOrder.currency!),
///////////////////////////////////////////////////////////////////////////////////////////////////////// stop lose
            creatDetails(
                context: context,
                title: "stop lose",
                value: widget.tradeOrOrder.stopLoss!,
                creatPnl: const SizedBox(),
                currency: widget.tradeOrOrder.currency!),
///////////////////////////////////////////////////////////////////////////////////////////////////////// app Commision percaentage
            widget.isOrder == true
                ? const SizedBox():  BlocBuilder<TradesCubit, TradesState>(
          builder: (context, state) {
            final cubit = context.read<TradesCubit>();

            final percent = cubit.commissionResult?.commissionRatePercent;

            // 👇 لوج للتأكد
            debugPrint("commissionRate = ${cubit.commissionResult}");

            return Column(
              children: [
                creatDetails(
                  context: context,
                  title: LocaleKeys.appCommision.tr().toUpperCase(),
                  value: percent ?? "Loading...", // 👈 مهم جدًا
                  creatPnl: const SizedBox(),
                ),
 ///////////////////////////////////////////////////////////////////////////////////////////////////////// app Commision value
        creatDetails(  context: context,
                title: LocaleKeys.appCommision2.tr().toUpperCase(),
                value: state is  GetCommissionRateLoadingState ?0:cubit.calculateCommission(
                    (widget.tradeOrOrder.quantity ?? 0) * livePrice ),
                creatPnl: const SizedBox(),
                currency: widget.tradeOrOrder.currency!),
              ],
            );
          },
        ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// "Creat At"
            widget.isOrder == false
                ? const SizedBox()
                : creatDetails(
                    context: context,
                    title: "Creat At",
                    value: widget.tradeOrOrder.createdAt.toString().trim().isNotEmpty
                        ? Methods.formatCreatedAt(
                            widget.tradeOrOrder.createdAt!.toString())
                        : widget.tradeOrOrder.createdAt!.toString(),
                    creatPnl: const SizedBox(),
                  ),
          ],
        );
      },
    );
  }

  Widget creatDetails(
      {required String title,
      required BuildContext context,
      String? currency,
      required dynamic value,
      required Widget creatPnl,
      bool? isPnl}) {
    return (value is num && value == 0) ||
            (value is String && value.toString().isEmpty)
        ? const SizedBox()
        : Column(
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.yellow),
                  ),
                  const Spacer(),
                  isPnl == true
                      ? creatPnl
                      : Text(
                          currency == null && value is String
                              ? value.toString()
                              : Methods.getCurrencyText(
                                  amount: value,
                                  currency: currency,
                                ),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                ],
              ),
              Divider(height: 20.h, color: AppColors.greyText),
            ],
          );
  }

  Widget creatBuyPrice({required BuildContext context, required bool isOrder}) {
    return Container(
      margin: EdgeInsets.only(top: 5.h, bottom: 10.h),
      child: Row(
        children: [
          Text(
            isOrder == true ? "Amount To Buy" : "Bought",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.yellow, fontSize: isOrder == true ? 20 : 22),
          ),
          SizedBox(width: 10.sp),
          Container(
            decoration: BoxDecoration(
              border: isOrder == true
                  ? Border.all(
                      color: AppColors.blueColor,
                      width: 1.5,
                    )
                  : null,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Material(
              color: isOrder == true ? Colors.transparent : AppColors.blueColor,
              borderRadius: BorderRadius.circular(8.sp),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 13.sp,
                  vertical: 4.h,
                ),
                child: Text(
                  '+${widget.tradeOrOrder.quantity}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontSize: 13,
                      ),
                ),
              ),
            ),
          ),





          const Spacer(),
          isOrder == true
              ? const SizedBox()
              : Text(
                  '@ ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.greyText),
                ),
///////////////////////////////////////////////////////////////////////////////////////////////////////// open price
          isOrder == true
              ? const SizedBox()
              : Text(
                  "${Methods.removeTrailingZeros(widget.tradeOrOrder.openPrice!)} "
                  "${Methods.getCurrencyText2(widget.tradeOrOrder.currency)}",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                      ),
                ),
        ],
      ),
    );
  }
}
