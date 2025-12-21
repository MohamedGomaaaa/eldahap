class Trades {
  final int? id;
  final String? metal;
  final String? user;
  final String? currency;

  final String? prevClosePrice;
  final String? openPrice;
  final String? lowPrice;
  final String? highPrice;
  final String? price;
  final String? ch;
  final String? chp;
  final String? ask;
  final String? bid;

  final String? priceGram24k;
  final String? priceGram22k;
  final String? priceGram21k;
  final String? priceGram20k;
  final String? priceGram18k;
  final String? priceGram16k;
  final String? priceGram14k;
  final String? priceGram10k;

  final String? qty;
  final String? stopLoss;
  final String? takeProfit;
  final String? sellWhenPrice;

  Trades({
    this.id,
    this.metal,
    this.user,
    this.currency,
    this.prevClosePrice,
    this.openPrice,
    this.lowPrice,
    this.highPrice,
    this.price,
    this.ch,
    this.chp,
    this.ask,
    this.bid,
    this.priceGram24k,
    this.priceGram22k,
    this.priceGram21k,
    this.priceGram20k,
    this.priceGram18k,
    this.priceGram16k,
    this.priceGram14k,
    this.priceGram10k,
    this.qty,
    this.stopLoss,
    this.takeProfit,
    this.sellWhenPrice,
  });

  /// fromJson
  factory Trades.fromJson(Map<String, dynamic> json) {
    return Trades(
      id: json['id'],
      metal: json['metal'] ?? "",
      user: json['user'] ?? "",
      currency: json['currency'] ?? "",
      prevClosePrice: json['prev_close_price'] ?? "",
      openPrice: json['open_price'] ?? "",
      lowPrice: json['low_price'] ?? "",
      highPrice: json['high_price'] ?? "",
      price: json['price'] ?? "",
      ch: json['ch'] ?? "",
      chp: json['chp'] ?? "",
      ask: json['ask'] ?? "",
      bid: json['bid'] ?? "",
      priceGram24k: json['price_gram_24k'] ?? "",
      priceGram22k: json['price_gram_22k'] ?? "",
      priceGram21k: json['price_gram_21k'] ?? "",
      priceGram20k: json['price_gram_20k'] ?? "",
      priceGram18k: json['price_gram_18k'] ?? "",
      priceGram16k: json['price_gram_16k'] ?? "",
      priceGram14k: json['price_gram_14k'] ?? "",
      priceGram10k: json['price_gram_10k'] ?? "",
      qty: json['qty'] ?? "",
      stopLoss: json['stop_loss'] ?? "",
      takeProfit: json['take_profit'] ?? "",
      sellWhenPrice: json['sell_when_price'] ?? "",
    );
  }

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metal': metal,
      'user': user,
      'currency': currency,
      'prev_close_price': prevClosePrice,
      'open_price': openPrice,
      'low_price': lowPrice,
      'high_price': highPrice,
      'price': price,
      'ch': ch,
      'chp': chp,
      'ask': ask,
      'bid': bid,
      'price_gram_24k': priceGram24k,
      'price_gram_22k': priceGram22k,
      'price_gram_21k': priceGram21k,
      'price_gram_20k': priceGram20k,
      'price_gram_18k': priceGram18k,
      'price_gram_16k': priceGram16k,
      'price_gram_14k': priceGram14k,
      'price_gram_10k': priceGram10k,
      'qty': qty,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'sell_when_price': sellWhenPrice,
    };
  }
}
