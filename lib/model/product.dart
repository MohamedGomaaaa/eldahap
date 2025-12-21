class Product {
  int? id;
  String? name;
  String? category;
  num? lowestPrice;
  num? highestPrice;
  int? timestamp;
  String? metal;
  String? user;
  String? currency;
  String? exchange;
  String? symbol;
  double? prevClosePrice;
  double? openPrice;
  double? lowPrice;
  double? highPrice;
  int? openTime;
  double? price;
  double? ch;
  double? chp;
  double? ask;
  double? bid;
  double? priceGram24k;
  double? priceGram22k;
  double? priceGram21k;
  double? priceGram20k;
  double? priceGram18k;
  double? priceGram16k;
  double? priceGram14k;
  double? priceGram10k;
  String? qty;
  String? stopLoss;
  int? takeProfit;
  String? sellWhenPrice;

  Product({
    this.timestamp,
    this.metal,
    this.user,
    this.currency,
    this.exchange,
    this.symbol,
    this.prevClosePrice,
    this.openPrice,
    this.lowPrice,
    this.highPrice,
    this.openTime,
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
    this.id,
    this.qty,
    this.stopLoss,
    this.takeProfit,
    this.sellWhenPrice,
    this.name,
    this.category,
    this.lowestPrice,
    this.highestPrice,
  });

  Product.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    metal = json['metal'];
    user = json['user'];
    currency = json['currency'];
    exchange = json['exchange'];
    symbol = json['symbol'];
    prevClosePrice = double.tryParse(json['prevClosePrice'].toString());
    openPrice = double.tryParse(json['openPrice'].toString());
    lowPrice = double.tryParse(json['lowPrice'].toString());
    highPrice = double.tryParse(json['highPrice'].toString());
    openTime = int.tryParse(json['openTime'].toString());
    price = double.tryParse(json['price'].toString());
    ch = double.tryParse(json['ch'].toString());
    chp = double.tryParse(json['chp'].toString());
    ask = double.tryParse(json['ask'].toString());
    bid = double.tryParse(json['bid'].toString());
    priceGram24k = double.tryParse(json['priceGram24k'].toString());
    priceGram22k = double.tryParse(json['priceGram22k'].toString());
    priceGram21k = double.tryParse(json['priceGram21k'].toString());
    priceGram20k = double.tryParse(json['priceGram20k'].toString());
    priceGram18k = double.tryParse(json['priceGram18k'].toString());
    priceGram16k = double.tryParse(json['priceGram16k'].toString());
    priceGram14k = double.tryParse(json['priceGram14k'].toString());
    priceGram10k = double.tryParse(json['priceGram10k'].toString());
    id = json['id'];
    qty = json['qty']?.toString();
    stopLoss = json['stopLoss']?.toString();
    takeProfit = json['takeProfit'];
    sellWhenPrice = json['sellWhenPrice']?.toString();
    name = json['name'];
    category = json['category'];
    lowestPrice = json['lowestPrice'];
    highestPrice = json['highestPrice'];
  }
  /*
  "metal": "XAU",
  "currency": "USD",
  "price": 1895.50,
  "qty": 1.00,

  "stop_loss": 1850.00,
  "take_profit": 1950.00,
  "sell_when_price": 1920.00,

  "prev_close_price": 1890.40,
  "open_price": 1892.10,
  "low_price": 1880.00,
  "high_price": 1900.00,
  "open_time": "2025-01-01 10:00:00",
  "ch": "+5",
  "chp": "+0.2",
  "ask": 1896.00,
  "bid": 1895.00,
  "price_gram_24k": 62.50,
  "price_gram_22k": 57.30,
  "price_gram_21k": 54.70,
  "price_gram_20k": 52.10,
  "price_gram_18k": 46.90,
  "price_gram_16k": 41.80,
  "price_gram_14k": 36.50,
  "price_gram_10k": 26.30
   */
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['metal'] = symbol?.split("/")[0];
        //metal;
    //data['user'] = user;
    data['currency'] = currency;
    data['exchange'] = exchange;
    data['symbol'] = symbol;
    data['prevClosePrice'] = prevClosePrice;
    data['openPrice'] = openPrice;
    data['lowPrice'] = lowPrice;
    data['highPrice'] = highPrice;
    data['openTime'] = openTime;
    data['price'] = price ?? 1895.50 ;
    data['ch'] = ch ?? "+5";
    data['chp'] = chp ?? "+0.2";
    data['ask'] = ask ?? 1896.00;
    data['bid'] = bid ?? 1895.00;
    data['priceGram24k'] = priceGram24k ?? 62.50;
    data['priceGram22k'] = priceGram22k ?? 57.30;
    data['priceGram21k'] = priceGram21k ?? 54.70;
    data['priceGram20k'] = priceGram20k ?? 52.10;
    data['priceGram18k'] = priceGram18k ?? 46.90;
    data['priceGram16k'] = priceGram16k ?? 41.80;
    data['priceGram14k'] = priceGram14k ?? 36.50;
    data['priceGram10k'] = priceGram10k ?? 26.30;
    data['id'] = id;
    data['qty'] = qty;
    data['stopLoss'] = stopLoss;
    data['take_profit'] = takeProfit;
    data['sell_when_price'] = sellWhenPrice;
    data['name'] = name;
    data['category'] = category;
    data['lowestPrice'] = lowestPrice;
    data['highestPrice'] = highestPrice;
    return data;
  }
}
