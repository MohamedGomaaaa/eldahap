class LivePriceModel {
  final String metal;     // XAU
  final String currency;  // USD / EGP
  final double market;
  final double buy;
  final double sell;
  final String timestamp;

  LivePriceModel({
    required this.metal,
    required this.currency,
    required this.market,
    required this.buy,
    required this.sell,
    required this.timestamp,
  });

  factory LivePriceModel.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return LivePriceModel(
      metal: (json['metal'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      market: d(json['market']),
      buy: d(json['buy']),
      sell: d(json['sell']),
      timestamp: (json['timestamp'] ?? '').toString(),
    );
  }
}
