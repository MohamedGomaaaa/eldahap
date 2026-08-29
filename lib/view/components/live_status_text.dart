import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../view_model/utils/colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../view_model/cubit/live_price_cubit/live_cubit.dart';
import '../../../../view_model/cubit/live_price_cubit/live_states.dart';
import '../../../../view_model/utils/colors.dart';

class LiveStatusText extends StatelessWidget {
  final double dotSize;
  final double space;
  final TextStyle? style;

  final String liveText;
  final String connectingText;
  final String noInternetText;
  final String disconnectedText;

  const LiveStatusText({
    super.key,
    this.dotSize = 8,
    this.space = 6,
    this.style,
    this.liveText = 'Live Price',
    this.connectingText = 'Connecting...',
    this.noInternetText = 'No Internet',
    this.disconnectedText = 'Disconnected',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivePriceCubit, LivePriceState>(
      // ✅ نعيد البناء لما النوع يتغير أو لما live prices تتغير (أول tick مهم)
      buildWhen: (prev, curr) {
        if (prev.runtimeType != curr.runtimeType) return true;
        if (prev is LivePriceLive && curr is LivePriceLive) {
          // أول ما الأسعار تبقى > 0 هنغير النص/اللون
          final prevOk = _hasAnyPrice(prev);
          final currOk = _hasAnyPrice(curr);
          return prevOk != currOk;
        }
        return false;
      },
      builder: (context, state) {
        final bool hasPrice = state is LivePriceLive && _hasAnyPrice(state);

        // ✅ أخضر فقط لو في سعر فعلي
        final Color dotColor = hasPrice ? AppColors.green : AppColors.red;

        final String text = _textFromState(
          state,
          hasPrice: hasPrice,
          liveText: liveText,
          connectingText: connectingText,
          noInternetText: noInternetText,
          disconnectedText: disconnectedText,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: space),
            Text(
              text,
              style: (style ??
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                  .copyWith(color: dotColor),
            ),
          ],
        );
      },
    );
  }

  bool _hasAnyPrice(LivePriceLive s) {
    // ✅ يعتبر "جاهز" لو في أي معدن/عملة فيها buy أو sell أكبر من صفر
    for (final currencyMap in s.metals.values) {
      for (final p in currencyMap.values) {
        if (p.buy > 0 || p.sell > 0) return true;
      }
    }
    return false;
  }

  String _textFromState(
      LivePriceState state, {
        required bool hasPrice,
        required String liveText,
        required String connectingText,
        required String noInternetText,
        required String disconnectedText,
      }) {
    // ✅ لو اتصلنا بس لسه مفيش Tick
    if (state is LivePriceLive && !hasPrice) return connectingText;

    if (state is LivePriceLive && hasPrice) return liveText;
    if (state is LivePriceConnecting) return connectingText;

    if (state is LivePriceStopped) {
      final m = state.message.toLowerCase();
      if (m.contains('no internet')) return noInternetText;
      return disconnectedText;
    }

    return connectingText;
  }
}
