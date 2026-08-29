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

    // ❌ متفصلش هنا عشان التنقل بين الصفحات مايفصلش السوكت
    // _liveCubit.stop();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ignore: avoid_print
    print('🟣 lifecycle => $state');

    if (state == AppLifecycleState.resumed) {
      _liveCubit.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _liveCubit.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocBuilder<LivePriceCubit, LivePriceState>(
        builder: (context, state) {
          final allMetals = _metalsFromState(state);

          final key = selectedCurrency.toUpperCase();

          // ✅ Gold (XAU)
          final MetalPrices goldP = allMetals['XAU']?[key] ??
              MetalPrices(
                market: 0,
                buy: 0,
                sell: 0,
                currency: key,
                timestamp: '',
              );

          final goldGramBuy = goldP.buy;
          final goldGramSell = goldP.sell;
          final goldOunceBuy = goldGramBuy * LocaleKeys.ounceFactor;
          final goldOunceSell = goldGramSell * LocaleKeys.ounceFactor;

          final goldRows = <_MetalRow>[
            _MetalRow(name: 'Ounce', buy: goldOunceBuy, sell: goldOunceSell),
            _MetalRow(name: 'Gram', buy: goldGramBuy, sell: goldGramSell),

          ];

          // ✅ Silver (XAG)
          final MetalPrices silverP = allMetals['XAG']?[key] ??
              MetalPrices(
                market: 0,
                buy: 0,
                sell: 0,
                currency: key,
                timestamp: '',
              );

          final silverGramBuy = silverP.buy;
          final silverGramSell = silverP.sell;
          final silverOunceBuy = silverGramBuy * LocaleKeys.ounceFactor;
          final silverOunceSell = silverGramSell * LocaleKeys.ounceFactor;

          final silverRows = <_MetalRow>[
            _MetalRow(name: 'Ounce', buy: silverOunceBuy, sell: silverOunceSell),
            _MetalRow(name: 'Gram', buy: silverGramBuy, sell: silverGramSell),
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
///////////////////////////////////////////////////////////////////////////// drop down button
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
////////////////////////////////////////////////////////////////////////////////////////////////////    Live Status Text
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
              // ✅ Gold (XAU) Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Gold (XAU)',
                  style: TextStyle(
                    color: AppColors.yellow2,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                children: goldRows.map((m) {
                  return _buildMetalRow(m);
                }).toList(),
              ),
              const SizedBox(height: 16),
              // ✅ Silver (XAG) Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Silver (XAG)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                children: silverRows.map((m) {
                  return _buildMetalRow(m);
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, Map<String, MetalPrices>> _metalsFromState(LivePriceState state) {
    if (state is LivePriceLive) return state.metals;
    return const {};
  }

  Widget _buildMetalRow(_MetalRow m) {
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 10),
                price: m.buy,
                fontSize: 14,
                decimals: 2,
                fakeMinDelta: 0.01,
                fakeMaxDelta: 0.05,
                fakeTickEvery: const Duration(milliseconds: 900),
              ),
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: LivePriceText(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 10),
                fontSize: 14,
                price: m.sell,
                decimals: 2,
                fakeMinDelta: 0.01,
                fakeMaxDelta: 0.05,
                fakeTickEvery: const Duration(milliseconds: 900),
              ),
            ),
          ),
        ],
      ),
    );
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
