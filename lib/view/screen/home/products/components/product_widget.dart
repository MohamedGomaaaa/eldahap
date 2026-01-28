
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/model/product.dart';
import 'package:official_gold/view_model/utils/navigation.dart';
import '../../../../../l10n/locale_keys.g.dart';
import '../../../../../model/category.dart';
import '../../../../../view_model/utils/assets.dart';
import '../../../../../view_model/utils/colors.dart';
import '../../../../components/live_text.dart'; // LivePriceText
import '../../product_chart/product_chart_screen.dart';
import 'product_details_screen.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../../model/metal_price_model.dart';


class ProductWidget extends StatelessWidget {
  final Product product;
  final Category category;
  final int tabIndex;

  const ProductWidget({
    required this.product,
    required this.category,
    required this.tabIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundGrey,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.yellowBorder,
            width: 1.w,
          ),
        ),
        child: BlocBuilder<LivePriceCubit, LivePriceState>(
          builder: (context, state) {
            // ✅ هات الأسعار من الستيت
            final metals = (state is LivePriceLive)
                ? state.metals
                : const <String, MetalPrices>{};

            // ✅ لو index==0 اعرض الدولار / لو 1 اعرض المصري
            final String currencyKey = (tabIndex == 0) ? 'USD' : 'EGP';

            final MetalPrices p = metals[currencyKey] ??
                MetalPrices(
                  market: 0,
                  buy: 0,
                  sell: 0,
                  currency: currencyKey,
                  timestamp: '',
                );

            // ✅ سعر الجرام لايف
            final double gramBuy = p.buy;
            final double gramSell = p.sell;

            // ✅ اضرب في وزن المنتج بالجرام
            final double weight = (product.gramWeight ?? 0).toDouble();

            final double liveBuyTotal = gramBuy * weight;
            final double liveSellTotal = gramSell * weight;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// title and image
                    SvgPicture.asset(AppAssets.gold),
                    SizedBox(width: 12.w),
                    Text(
                      "${product.name} ${product.gramWeight} gm",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textYellow,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// body
                Row(
                  children: [
                    //////////////////////////////////////////////////////////////////////////////////////////////// ✅ SELL (مكان 888)
                    Expanded(
                      child: Column(
                        children: [
                          LivePriceText(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 6),
                            price: liveSellTotal,
                            decimals: 2,
                            fakeMinDelta: 0.01,
                            fakeMaxDelta: 0.05,
                            fakeTickEvery: const Duration(milliseconds: 900),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigation.push(
                                  context,
                                  ProductDetailsScreen(
                                    tabIndex: tabIndex,
                                    product: product,
                                    category: category,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.transparent,
                                disabledBackgroundColor: AppColors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: AppColors.yellowBorder,
                                    width: 1.w,
                                  ),
                                ),
                              ),
                              child: Text(
                                LocaleKeys.low.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  color: AppColors.textYellow,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 6.w),

////////////////////////////////////////////////////////////////////////////////////////////////////// // ✅ Chart (زي ما هو)
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 6.h),
                          LiveChartIcon(
                            tabIndex: tabIndex,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TradingViewPage(
                                    type: product.metal?.toLowerCase() == 'gold'
                                        ? 1
                                        : product.metal?.toLowerCase() == 'silver'
                                        ? 2
                                        : 3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 6.w),

///////////////////////////////////////////////////////////////////////////////////////////////////////////// // ✅ BUY (مكان 7777)
                    Expanded(
                      child: Column(
                        children: [
                          LivePriceText(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 6),
                            price: liveBuyTotal,
                            decimals: 2,
                            fakeMinDelta: 0.01,
                            fakeMaxDelta: 0.05,
                            fakeTickEvery: const Duration(milliseconds: 900),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigation.push(
                                  context,
                                  ProductDetailsScreen(
                                    tabIndex: tabIndex,
                                    product: product,
                                    category: category,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.transparent,
                                elevation: 0,
                                disabledBackgroundColor: AppColors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: AppColors.yellowBorder,
                                    width: 1.w,
                                  ),
                                ),
                              ),
                              child: Text(
                                LocaleKeys.high.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  color: AppColors.textYellow,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
class LiveChartIcon extends StatefulWidget {
  final int tabIndex; // 0 => USD, 1 => EGP
  final double size;
  final VoidCallback onTap;

  const LiveChartIcon({
    super.key,
    required this.tabIndex,
    required this.onTap,
    this.size = 26,
  });

  @override
  State<LiveChartIcon> createState() => _LiveChartIconState();
}

class _LiveChartIconState extends State<LiveChartIcon> {
  double? _last;
  int _dir = 0;

  @override
  Widget build(BuildContext context) {
    final key = widget.tabIndex == 0 ? 'USD' : 'EGP';

    return BlocConsumer<LivePriceCubit, LivePriceState>(
      // ✅ اسمع فقط لما buy بتاع العملة دي يتغير
      listenWhen: (prev, curr) {
        if (prev is! LivePriceLive || curr is! LivePriceLive) return false;
        final prevBuy = prev.metals[key]?.buy;
        final currBuy = curr.metals[key]?.buy;
        if (prevBuy == null || currBuy == null) return false;
        return prevBuy != currBuy;
      },
      listener: (context, state) {
        if (state is! LivePriceLive) return;

        final p = state.metals[key];
        if (p == null) return;

        final next = p.buy;
        final prev = _last ?? next;

        setState(() {
          _dir = next > prev ? 1 : (next < prev ? -1 : 0);
          _last = next;
        });
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Image.asset(
            'assets/images/trading_chart_white.png', // ✅ الصورة الجديدة
            width: widget.size.w,
            height: widget.size.w,
            color: _dir > 0
                ? AppColors.green
                : _dir < 0
                ? AppColors.red
                : const Color(0xFF343A40), // neutralColor نفس LivePriceText
          ),
        );
      },
    );
  }
}
// class ProductWidget extends StatelessWidget {
//   final Product product;
//   final Category category;
//   final int tabIndex;
//
//   const ProductWidget({
//     required this.product,
//     required this.category,
//     required this.tabIndex,
//     super.key,
//   });
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//     return Material(
//       color: AppColors.backgroundGrey,
//       borderRadius: BorderRadius.circular(12.r),
//       child: Container(
//         padding: EdgeInsets.all(12.sp),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: AppColors.yellowBorder,
//             width: 1.w,
//           ),
//         ),
//         child: BlocBuilder<LivePriceCubit, LivePriceState>(
//           builder: (context, state) {
//
//             return Column(
//
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// title and image
//                     SvgPicture.asset(AppAssets.gold),
//                     SizedBox(width: 12.w),
//                     Text(
//                       "${product.name } ${product.gramWeight } gm",
//
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             color: AppColors.textYellow,
//                           ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12.h),
//
//  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// body
//                 Row(
//                   children: [
//   //////////////////////////////////////////////////////////////////////////////////////////////// ✅ SELL (مكان 888)
//   //                   Expanded(
//   //                     child: Column(
//   //                       children: [
//   //                         LivePriceText(
//   //                           padding: const EdgeInsets.symmetric(
//   //                               horizontal: 30, vertical: 6),
//   //                           price: 343.9,
//   //                           decimals: 2,
//   //                           fakeMinDelta: 0.01,
//   //                           fakeMaxDelta: 0.05,
//   //                           fakeTickEvery: const Duration(milliseconds: 900),
//   //                           style: Theme.of(context)
//   //                               .textTheme
//   //                               .titleLarge
//   //                               ?.copyWith(
//   //                                 color: Colors.white,
//   //                               ),
//   //                         ),
//   //                         SizedBox(height: 6.h),
//   //                         SizedBox(
//   //                           width: double.infinity,
//   //                           child: ElevatedButton(
//   //                             onPressed: () {
//   //                               Navigation.push(
//   //                                 context,
//   //                                 ProductDetailsScreen(
//   //                                   product: product,
//   //                                   category: category,
//   //                                 ),
//   //                               );
//   //                             },
//   //                             style: ElevatedButton.styleFrom(
//   //                               backgroundColor: AppColors.transparent,
//   //                               disabledBackgroundColor: AppColors.transparent,
//   //                               elevation: 0,
//   //                               shape: RoundedRectangleBorder(
//   //                                 borderRadius: BorderRadius.circular(12.r),
//   //                                 side: BorderSide(
//   //                                   color: AppColors.yellowBorder,
//   //                                   width: 1.w,
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                             child: Text(
//   //                               LocaleKeys.low.tr(),
//   //                               style: Theme.of(context)
//   //                                   .textTheme
//   //                                   .titleLarge
//   //                                   ?.copyWith(
//   //                                     color: AppColors.textYellow,
//   //                                   ),
//   //                             ),
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   ),
// ////////////////////////////////////////////////////////////////////////////////////////////// ✅ SELL (مكان 888)
//                     Expanded(
//                       child: Column(
//                         children: [
//                           LivePriceText(
//                             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
//                             price: liveSellTotal,
//                             decimals: 2,
//                             fakeMinDelta: 0.01,
//                             fakeMaxDelta: 0.05,
//                             fakeTickEvery: const Duration(milliseconds: 900),
//                             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                               color: Colors.white,
//                             ),
//                           ),
//                           SizedBox(height: 6.h),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigation.push(
//                                   context,
//                                   ProductDetailsScreen(
//                                     product: product,
//                                     category: category,
//                                   ),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.transparent,
//                                 disabledBackgroundColor: AppColors.transparent,
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   side: BorderSide(
//                                     color: AppColors.yellowBorder,
//                                     width: 1.w,
//                                   ),
//                                 ),
//                               ),
//                               child: Text(
//                                 LocaleKeys.low.tr(),
//                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                   color: AppColors.textYellow,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 6.w),
//
// ////////////////////////////////////////////////////////////////////////////////////////////////////// // ✅ Chart (زي ما هو)
//                     Expanded(
//                       child: Column(
//                         children: [
//                           Text(
//                             '${product.lowestPrice}',
//                             textAlign: TextAlign.center,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleLarge
//                                 ?.copyWith(
//                                   color: AppColors.textYellow,
//                                 ),
//                           ),
//                           SizedBox(height: 6.h),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => TradingViewPage(
//                                     type: product.metal?.toLowerCase() == 'gold'
//                                         ? 1
//                                         : product.metal?.toLowerCase() ==
//                                                 'silver'
//                                             ? 2
//                                             : 3,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child:
//
//                             Image.asset(AppAssets.tradingChart,color: Colors.yellow,),
//                           )
//                         ],
//                       ),
//                     ),
//
//                     SizedBox(width: 6.w),
//
// ///////////////////////////////////////////////////////////////////////////////////////////////////////////// // ✅ BUY (مكان 7777)
//
//
//                     Expanded(
//                       child: Column(
//                         children: [
//                           LivePriceText(
//                             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
//                             price: liveBuyTotal,
//                             decimals: 2,
//                             fakeMinDelta: 0.01,
//                             fakeMaxDelta: 0.05,
//                             fakeTickEvery: const Duration(milliseconds: 900),
//                             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                               color: Colors.white,
//                             ),
//                           ),
//                           SizedBox(height: 6.h),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigation.push(
//                                   context,
//                                   ProductDetailsScreen(
//                                     product: product,
//                                     category: category,
//                                   ),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.transparent,
//                                 elevation: 0,
//                                 disabledBackgroundColor: AppColors.transparent,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12.r),
//                                   side: BorderSide(
//                                     color: AppColors.yellowBorder,
//                                     width: 1.w,
//                                   ),
//                                 ),
//                               ),
//                               child: Text(
//                                 LocaleKeys.high.tr(),
//                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                   color: AppColors.textYellow,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//
//
//
// //                     Expanded(
// //                       child: Column(
// //                         children: [
// //                           LivePriceText(
// //                             padding: const EdgeInsets.symmetric(
// //                                 horizontal: 30, vertical: 6),
// //                             price: 33.9,
// //                             decimals: 2,
// //                             fakeMinDelta: 0.01,
// //                             fakeMaxDelta: 0.05,
// //                             fakeTickEvery: const Duration(milliseconds: 900),
// //                             style: Theme.of(context)
// //                                 .textTheme
// //                                 .titleLarge
// //                                 ?.copyWith(
// //                                   color: Colors.white,
// //                                 ),
// //                           ),
// //                           SizedBox(height: 6.h),
// //                           SizedBox(
// //                             width: double.infinity,
// //                             child: ElevatedButton(
// //                               onPressed: () {
// //                                 Navigation.push(
// //                                   context,
// //                                   ProductDetailsScreen(
// //                                     product: product,
// //                                     category: category,
// //                                   ),
// //                                 );
// //                               },
// //                               style: ElevatedButton.styleFrom(
// //                                 backgroundColor: AppColors.transparent,
// //                                 elevation: 0,
// //                                 disabledBackgroundColor: AppColors.transparent,
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius: BorderRadius.circular(12.r),
// //                                   side: BorderSide(
// //                                     color: AppColors.yellowBorder,
// //                                     width: 1.w,
// //                                   ),
// //                                 ),
// //                               ),
// //                               child: Text(
// //                                 LocaleKeys.high.tr(),
// //                                 style: Theme.of(context)
// //                                     .textTheme
// //                                     .titleLarge
// //                                     ?.copyWith(
// //                                       color: AppColors.textYellow,
// //                                     ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }



// class LiveLineChart extends StatefulWidget {
//   final String metalKey; // مثال: 'Gold (24)'
//   final bool useBuy;     // true=buy, false=sell
//   final int maxPoints;
//
//   const LiveLineChart({
//     super.key,
//     required this.metalKey,
//     this.useBuy = true,
//     this.maxPoints = 40,
//   });
//
//   @override
//   State<LiveLineChart> createState() => _LiveLineChartState();
// }
// class _LiveLineChartState extends State<LiveLineChart> {
//   final List<FlSpot> _spots = [];
//   double _x = 0;
//
//   void _pushPoint(double y) {
//     _x += 1;
//     _spots.add(FlSpot(_x, y));
//     if (_spots.length > widget.maxPoints) _spots.removeAt(0);
//   }
//
//   List<LineChartBarData> _coloredSegments(List<FlSpot> s) {
//     if (s.length < 2) return [];
//
//     final bars = <LineChartBarData>[];
//     for (int i = 1; i < s.length; i++) {
//       final p0 = s[i - 1];
//       final p1 = s[i];
//
//       final isUp = p1.y >= p0.y;
//       final c = isUp ? Colors.green : Colors.red;
//
//       bars.add(
//         LineChartBarData(
//           spots: [p0, p1],
//           isCurved: false, // نفس الشكل الـ sharp زي الصورة
//           barWidth: 2,
//           color: c,
//           dotData: const FlDotData(show: false),
//           belowBarData: BarAreaData(show: false),
//         ),
//       );
//     }
//     return bars;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final minY = _spots.isEmpty ? 0.0 : _spots.map((e) => e.y).reduce(min);
//     final maxY = _spots.isEmpty ? 1.0 : _spots.map((e) => e.y).reduce(max);
//     final pad = (maxY - minY) == 0 ? 1.0 : (maxY - minY) * 0.15;
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(8),
//       child: BlocListener<LivePriceCubit, LivePriceState>(
//         listenWhen: (_, curr) => curr is LivePriceLive,
//         listener: (context, state) {
//           if (state is LivePriceLive) {
//             final mp = state.metals[widget.metalKey];
//             final y = widget.useBuy ? (mp?.buy ?? 0.0) : (mp?.sell ?? 0.0);
//             if (y > 0) setState(() => _pushPoint(y));
//           }
//         },
//         child: LineChart(
//           LineChartData(
//             // ✅ نفس خلفية الصورة
//             backgroundColor: Colors.black,
//
//             minY: _spots.isEmpty ? 0 : (minY - pad),
//             maxY: _spots.isEmpty ? 1 : (maxY + pad),
//
//             gridData: const FlGridData(show: false),
//             titlesData: const FlTitlesData(show: false),
//             borderData: FlBorderData(show: false),
//             lineTouchData: const LineTouchData(enabled: false),
//
//             // ✅ هنا السحر: Segments متلوّنة
//             lineBarsData: _coloredSegments(_spots),
//           ),
//           // لو عايز حركة انسيابية:
//           // swapAnimationDuration: const Duration(milliseconds: 250),
//           // swapAnimationCurve: Curves.easeOut,
//         ),
//       ),
//     );
//   }
// }
