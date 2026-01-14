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
      buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      builder: (context, state) {
        final bool isConnected = state is LivePriceLive;
        final Color dotColor = isConnected ? AppColors.green : AppColors.red;

        final String text = _textFromState(
          state,
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
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            SizedBox(width: space),
            Text(
              text,
              style: (style ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                  .copyWith(color: dotColor),
            ),
          ],
        );
      },
    );
  }

  String _textFromState(
      LivePriceState state, {
        required String liveText,
        required String connectingText,
        required String noInternetText,
        required String disconnectedText,
      }) {
    if (state is LivePriceLive) return liveText;
    if (state is LivePriceConnecting) return connectingText;

    if (state is LivePriceStopped) {
      final m = state.message.toLowerCase();
      if (m.contains('no internet')) return noInternetText;
      return disconnectedText;
    }

    return connectingText;
  }
}
