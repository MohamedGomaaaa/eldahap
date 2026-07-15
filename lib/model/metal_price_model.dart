//// فيه المستقبل لازم نستغني عنه سيبه ناو


class MetalPrices {
  final double market;
  final double buy;
  final double sell;
  final String currency;
  final String timestamp;

  const MetalPrices({
    required this.market,
    required this.buy,
    required this.sell,
    required this.currency,
    required this.timestamp,
  });

  static double _roundTo(double v, int decimals) {
    final p = decimals <= 0
        ? 1.0
        : List.filled(decimals, 0).fold<double>(1.0, (a, _) => a * 10);
    return (v * p).roundToDouble() / p;
  }

  MetalPrices normalized({int decimals = 5}) {
    return MetalPrices(
      market: _roundTo(market, decimals),
      buy: _roundTo(buy, decimals),
      sell: _roundTo(sell, decimals),
      currency: currency,
      timestamp: timestamp,
    );
  }
}

