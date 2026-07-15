import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../model/metal_price_model.dart';
import '../../../../../model/trade_order_model.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../../view_model/cubit/trades_cubit/trades_cubit.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../../view_model/utils/common_method.dart';
import '../../../../../view_model/utils/navigation.dart';
import '../../../../components/live_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../trade_details_screen.dart';

class CreatTrade extends StatelessWidget {
  final TradeOrOrder trade;
  final TradesCubit tradesCubit;
final num livePrice,pnl;
   final bool lastIndex,hasLive,isProfit;
   final String productTitle;
  const CreatTrade({
    super.key,
    required this.trade,
required this.livePrice,
    required this.tradesCubit,
     required this.lastIndex,
     required this.productTitle, required this.hasLive, required this.isProfit, required this.pnl,
  });

  @override
  Widget build(BuildContext context) {
    return
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: lastIndex == true
            ? null
            : const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.yellow, width: 1.0),
          ),
        ),
        padding: EdgeInsets.only(
          top: 4.sp,
          right: 8.sp,
          left: 8.sp,
          bottom: 8.sp,
        ),
        child: Row(
          children: [
/////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ LEFT (ياخد المساحة المتاحة)
            Expanded(
              flex: 6,
              child: InkWell(
                // ✅ ميروحش على التفاصيل لو مفيش live
                onTap: hasLive
                    ? () => Navigation.push(
                  context,

                  TradeDetailsScreen(
                    trade: trade,
                    productTitle: productTitle,
                  ),
                )
                    : null,
                child: Opacity(
                  // ✅ نفس فكرة CreatOrder
                  opacity: hasLive ? 1.0 : 0.35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
//////////////////////////////////////////////////////////////////////////////////////////////////// quantity in blue container
                      Material(
                        color: AppColors.blueColor,
                        borderRadius: BorderRadius.circular(8.sp),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.sp,
                            vertical: 5.h,
                          ),
                          child: Text(
                            '+${trade.quantity?.toString() ?? "0"} of ${Methods.removeTrailingZeros(trade.unitGramWeight!)} gm',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
/////////////////////////////////////////////////////////////////////////////////////////////// _creat Low And High Price
                      _creatLowAndHighPrice(
                        trade: trade,
                        context: context,
                        openPrice:trade.openPrice!,
                        livePrice: livePrice,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),
/////////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ RIGHT (Close + P&L)
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: hasLive
                    ? () => showCloseTradeSheet(
                  context,
                  trade,
                  tradesCubit,
                  livePrice.toDouble(),
                )
                    : null,
                child: Opacity(
                  opacity: hasLive ? 1.0 : 0.35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
//////////////////////////////////////////////////////////////////////////////////////////////////////////// ✅ P&L بيتحرك لايف
                          Flexible(
                            child: LivePriceText(
                              price: pnl.toDouble(),
                              decimals: 2,
                              fakeMinDelta: 0.01,
                              fakeMaxDelta: 0.05,
                              fakeTickEvery:
                              const Duration(milliseconds: 900),
                              neutralColor: Colors.transparent,
                              upColor: Colors.transparent,
                              downColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              width: null, // ✅ ياخد عرض الأب (Flexible)
                              alignment: Alignment.centerRight,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                color: isProfit
                                    ? AppColors.blueColor
                                    : AppColors.red,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          const Text('P&L'),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      //////////////////////////////////////////////////////////////////////////////////////////////////////////// close icon
                      CircleAvatar(
                        backgroundColor: AppColors.red,
                        radius: 10.r,
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }





  Widget _creatLowAndHighPrice({
    required BuildContext context,
    required num openPrice,
    required num livePrice,
    required TradeOrOrder trade
  })
  {
    return Row(
      children: [
        Text(
         Methods.removeTrailingZeros( openPrice),
          style: const TextStyle(color: AppColors.greyText),
        ),
        SizedBox(width: 6.w),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.yellow2,
          size: 12.sp,
        ),
        SizedBox(width: 6.w),

        /// ✅ live price ياخد باقي السطر
        Expanded(
          child:
          LivePriceText(
            alignment: Alignment.centerLeft,
            price: livePrice.toDouble()*trade.unitGramWeight!.toDouble(),
            decimals: 2,
            fakeMinDelta: 0.01,
            fakeMaxDelta: 0.05,
            fakeTickEvery: const Duration(milliseconds: 900),
            neutralColor: Colors.transparent,
            upColor: Colors.transparent,
            downColor: Colors.transparent,
            padding: EdgeInsets.zero,
            width: null,
            style: const TextStyle(color: AppColors.greyText),
          ),
        ),
      ],
    );
  }

  void showCloseTradeSheet(
    BuildContext context,
    TradeOrOrder trade,
    TradesCubit tradesCubit,
    double livePrice,
  )
  {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final open = (trade.openPrice ?? 0).toDouble();
        final pnl = livePrice - open;
        final isProfit = pnl >= 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Close trade?",
                style: TextStyle(
                  color: AppColors.yellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isProfit ? "Profit" : "Lose",
                style: TextStyle(
                  color: isProfit ? AppColors.blueColor : AppColors.red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pnl.toStringAsFixed(2),
                style: TextStyle(
                  color: isProfit ? AppColors.blueColor : AppColors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    tradesCubit.closeTrade(
                      orderId: trade.id,
                      closePrice: pnl.abs().toStringAsFixed(2),
                    );

                    Navigator.pop(context, true);

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
                    "Close",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:(){Navigator.pop(context, false);},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow2,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:  const Text(
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
}






















