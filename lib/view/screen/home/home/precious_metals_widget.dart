import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/locale_keys.g.dart';
import '../../../../model/metal_price_model.dart';
import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../view_model/utils/colors.dart';
import '../../../components/live_status_text.dart';
import '../../../components/live_text.dart';


class PreciousMetalsWidget extends StatefulWidget {
  const PreciousMetalsWidget({super.key});

  @override
  State<PreciousMetalsWidget> createState() => _PreciousMetalsWidgetState();
}

class _PreciousMetalsWidgetState extends State<PreciousMetalsWidget>
    with WidgetsBindingObserver {
  String selectedCurrency = 'EGP';
  late final LivePriceCubit _liveCubit;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _liveCubit = context.read<LivePriceCubit>();
    _liveCubit.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveCubit.stop(); // لو عايز await: اعملها في close بتاع cubit
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ignore: avoid_print
    print('🟣 lifecycle => $state');

    if (state == AppLifecycleState.paused) {
      _liveCubit.stop();
    }

    if (state == AppLifecycleState.resumed) {
      _liveCubit.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<LivePriceCubit, LivePriceState>(
        builder: (context, state) {
          final metals = _metalsFromState(state);

          final key = selectedCurrency.toUpperCase();
          final MetalPrices p = metals[key] ??
              MetalPrices(
                market: 0,
                buy: 0,
                sell: 0,
                currency: key,
                timestamp: '',
              );

          const ounceTitle = 'Ounce';
          const gramTitle = 'Gram';

          final gramBuy = p.buy;
          final gramSell = p.sell;


          final ounceBuy = gramBuy * LocaleKeys.ounceFactor;
          final ounceSell = gramSell * LocaleKeys.ounceFactor;

          final rows = <_MetalRow>[
            _MetalRow(name: ounceTitle, buy: ounceBuy, sell: ounceSell),
            _MetalRow(name: gramTitle, buy: gramBuy, sell: gramSell),
          ];

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Precious Metals',
                      style: TextStyle(
                        color: AppColors.yellow2,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: 30.h,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.yellow2, width: 1),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        dropdownColor: AppColors.grey,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.yellow2),
                        items: const ['EGP', 'USD'].map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Row(
                              children: [
                                const Text('(£) ',
                                    style: TextStyle(color: AppColors.yellow2)),
                                Text(c,
                                    style: const TextStyle(
                                        color: AppColors.yellow2)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => selectedCurrency = v);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: LiveStatusText()),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Buy',
                            style: TextStyle(
                              color: AppColors.yellow2,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Sell',
                            style: TextStyle(
                              color: AppColors.yellow2,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Column(
                children: rows.map((m) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              m.name,
                              style: const TextStyle(
                                color: AppColors.yellow2,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: LivePriceText(
                              price: m.buy,
                              decimals: 2,
                              fakeMinDelta: 0.01,
                              fakeMaxDelta: 0.05,
                              fakeTickEvery:
                              const Duration(milliseconds: 900),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: LivePriceText(
                              price: m.sell,
                              decimals: 2,
                              fakeMinDelta: 0.01,
                              fakeMaxDelta: 0.05,
                              fakeTickEvery:
                              const Duration(milliseconds: 900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, MetalPrices> _metalsFromState(LivePriceState state) {
    if (state is LivePriceLive) return state.metals;
    return const {};
  }
}

class _MetalRow {
  final String name;
  final double buy;
  final double sell;

  const _MetalRow({
    required this.name,
    required this.buy,
    required this.sell,
  });
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  old
// class PreciousMetalsWidget extends StatefulWidget {
//   @override
//   _PreciousMetalsWidgetState createState() => _PreciousMetalsWidgetState();
// }
//
// class _PreciousMetalsWidgetState extends State<PreciousMetalsWidget> {
//   String selectedCurrency = 'EGP';
//   String selectedTab = 'Live Price';
//
//   // Exchange rate EGP to USD (example rate)
//   final double egpToUsdRate = 0.032;
//
//   // Base prices in EGP (as shown in image)
//   final Map<String, Map<String, double>> basePricesEGP = {
//     'Gold (24)': {
//       'livePrice': 2804.91,
//       'bid': 2804.91,
//       'ask': 2806.40,
//       'gram': 90.23
//     },
//     'Gold (21)': {
//       'livePrice': 2804.91,
//       'bid': 2804.91,
//       'ask': 2806.40,
//       'gram': 90.23
//     },
//     'Silver': {'livePrice': 34.32, 'bid': 34.32, 'ask': 34.43, 'gram': 1.11},
//     // 'Platinum': {'livePrice': 1176.87, 'bid': 1176.87, 'ask': 1184.33, 'gram': 38.08},
//     // 'Palladium': {'livePrice': 930.88, 'bid': 930.88, 'ask': 960.72, 'gram': 30.89},
//     // 'Rhodium': {'livePrice': 4978.30, 'bid': 4978.30, 'ask': 5852.55, 'gram': 188.16},
//   };
//
//   Map<String, Map<String, double>> getCurrentPrices() {
//     if (selectedCurrency == 'USD') {
//       Map<String, Map<String, double>> usdPrices = {};
//       basePricesEGP.forEach((metal, prices) {
//         usdPrices[metal] = {};
//         prices.forEach((type, price) {
//           usdPrices[metal]![type] = price * egpToUsdRate;
//         });
//       });
//       return usdPrices;
//     }
//     return basePricesEGP;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentPrices = getCurrentPrices();
//
//     return Container(
//       color: AppColors.background,
//       child: Column(
//         children: [
//           // Header with currency dropdown
//           Container(
//
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Precious Metals',
//                   style: TextStyle(
//                     color: AppColors.yellow2,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
// /////////////////////////////////////////////////////////////////////////////////////////////////////
//                 Container(
//                   height: 30.h,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: AppColors.grey,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: AppColors.yellow2, width: 1),
//                   ),
//                   child: DropdownButton<String>(
//                     value: selectedCurrency,
//                     dropdownColor: AppColors.grey,
//                     underline: const SizedBox.shrink(),
//                     icon: const Icon(Icons.keyboard_arrow_down,
//                         color: AppColors.yellow2),
//                     items: ['EGP', 'USD'].map((String currency) {
//                       return DropdownMenuItem<String>(
//                         value: currency,
//                         child: Row(
//                           children: [
//                             const Text(
//                               '(£) ',
//                               style: TextStyle(color: AppColors.yellow2),
//                             ),
//                             Text(
//                               currency,
//                               style: const TextStyle(color: AppColors.yellow2),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedCurrency = newValue!;
//                       });
//                     },
//                   ),
//                 ),
//                 //),
//               ],
//             ),
//           ),
//
// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Tab bar
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 4),
//             decoration: BoxDecoration(
//               color: AppColors.grey,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: ['Live Price', 'Bid(Oz)', 'Ask(Oz)', 'GRAM'].map((tab) {
//                 bool isSelected = selectedTab == tab;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       // setState(() {
//                       // selectedTab = tab;
//                       // });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: AppColors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (isSelected)
//                             Container(
//                               width: 8,
//                               height: 8,
//                               decoration: const BoxDecoration(
//                                 color: AppColors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                               margin: const EdgeInsets.only(right: 8),
//                             ),
//                           Text(
//                             tab,
//                             style: TextStyle(
//                               color: isSelected
//                                   ? AppColors.yellow2
//                                   : AppColors.greyText,
//                               fontSize: 14,
//                               fontWeight: isSelected
//                                   ? FontWeight.w600
//                                   : FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Table Headers
//           // Container(
//           //   padding: const EdgeInsets.symmetric(horizontal: 20),
//           //   child: const Row(
//           //     children: [
//           //       Expanded(flex: 2, child: SizedBox()),
//           //       Expanded(
//           //         flex: 2,
//           //         child: Text(
//           //           'Bid(Oz)',
//           //           style: TextStyle(color: AppColors.greyText, fontSize: 14),
//           //           textAlign: TextAlign.center,
//           //         ),
//           //       ),
//           //       Expanded(
//           //         flex: 2,
//           //         child: Text(
//           //           'Ask(Oz)',
//           //           style: TextStyle(color: AppColors.greyText, fontSize: 14),
//           //           textAlign: TextAlign.center,
//           //         ),
//           //       ),
//           //       Expanded(
//           //         flex: 2,
//           //         child: Text(
//           //           'GRAM',
//           //           style: TextStyle(color: AppColors.greyText, fontSize: 14),
//           //           textAlign: TextAlign.center,
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//
//
// ////////////////////////////////////////////////////////////////////////////////////////////////// Metal list
//           Column(
//             children: currentPrices.entries.map((entry) {
//               String metalName = entry.key;
//               Map<String, double> prices = entry.value;
//
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.grey,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     // Metal icon and name
//                     Expanded(
//                       flex: 2,
//                       child: Row(
//                         children: [
//                           const SizedBox(width: 12),
//                           Text(
//                             metalName,
//                             style: const TextStyle(
//                               color: AppColors.yellow2,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Bid price
//                     Expanded(
//                       flex: 2,
//                       child: Text(
//                         _formatPrice(prices['bid']!),
//                         style: const TextStyle(
//                           color: AppColors.yellow2,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//
//                     // Ask price
//                     Expanded(
//                       flex: 2,
//                       child: Text(
//                         _formatPrice(prices['ask']!),
//                         style: const TextStyle(
//                           color: AppColors.yellow2,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//
//                     // Gram price
//                     Expanded(
//                       flex: 2,
//                       child: Text(
//                         _formatPrice(prices['gram']!),
//                         style: const TextStyle(
//                           color: AppColors.yellow2,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//
//           ),
//         ],
//       ),
//       // ),
//     );
//   }
//
//   // Color _getMetalColor(String metalName) {
//   //   switch (metalName) {
//   //     case 'Gold':
//   //       return AppColors.yellow;
//   //     case 'Silver':
//   //       return AppColors.lightGrey;
//   //     case 'Platinum':
//   //       return AppColors.lightGrey;
//   //     case 'Palladium':
//   //       return AppColors.lightGrey;
//   //     case 'Rhodium':
//   //       return AppColors.lightGrey;
//   //     default:
//   //       return AppColors.yellow2;
//   //   }
//   // }
//
//   String _formatPrice(double price) {
//     if (selectedCurrency == 'USD') {
//       return price.toStringAsFixed(2);
//     } else {
//       // For EGP, format with appropriate decimal places
//       if (price > 1000) {
//         return price.toStringAsFixed(2);
//       } else if (price > 100) {
//         return price.toStringAsFixed(2);
//       } else {
//         return price.toStringAsFixed(2);
//       }
//     }
//   }
// }
