
import 'package:official_gold/model/product.dart';

class TradeOrOrder {
  final int? id;

  final String? type;
  final String? status;
  final String? mode;

  final int? productId;
  final num? quantity;

  final num? unitGramWeight;
  final int? unitKarat;

  final Product? product;

  final String? metal;
  final String? currency;

  // final num? qty;
  final num? totalGrams;


  final num? price;

  final num? executedPrice;


  final num? realizedPnl;
  final num? unrealizedPnl;


  final num? lowPrice;
  final num? highPrice;



  final num? ch;
  final num? chp;
  final num? ask;
  final num? bid;

  final num? priceGram24k;
  final num? priceGram22k;
  final num? priceGram21k;
  final num? priceGram20k;
  final num? priceGram18k;
  final num? priceGram16k;
  final num? priceGram14k;
  final num? priceGram10k;

  final String? deliveryStatus;
  final DateTime? deliveryRequestedAt;
  final String? deliveryMethod;
  final String? deliveryCity;
  final String? deliveryPhone;
  final num? deliveryFee;
  final String? deliveryTrackingNo;
  final String? address;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final num? totalCost;

  final num? manufacturingFee; //: 160,
  final bool? hasDelivery; //: true,
  final num? shippingCost; //: 200,







  final num? openPrice;
  // final num ? openPriceOrder;
  final num? stopLoss;
  final num? takeProfit;
  final num? sellWhenPrice;



  final num? pnlUsd;
  final num?  pnlEgp;


  // final num? entryPrice;
  final num? closePrice;
  final String? closeKind;
  final String? closedAt;
  final String? openTime;
  final num? prevClosePrice;



















  TradeOrOrder({
    this.openPrice,
    // this.openPriceOrder,
    this.stopLoss,
    this.takeProfit,
    this.sellWhenPrice,




  this. pnlUsd,
  this.  pnlEgp,







    this.id,
    this.type,
    this.status,
    this.mode,
    this.productId,
     this.quantity,
    this.unitGramWeight,
    this.unitKarat,
    this.product,
    this.metal,
    this.currency,

    this.totalGrams,

    this.price,
    // this.entryPrice,
    this.executedPrice,
    this.closePrice,

    this.realizedPnl,
    this.unrealizedPnl,
    this.closeKind,
    this.closedAt,
    this.prevClosePrice,
    this.lowPrice,
    this.highPrice,
    this.openTime,
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
    this.deliveryStatus,
    this.deliveryRequestedAt,
    this.deliveryMethod,
    this.deliveryCity,
    this.deliveryPhone,
    this.deliveryFee,
    this.deliveryTrackingNo,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.totalCost,
    this.manufacturingFee, //: 160,
    this.hasDelivery, //: true,
    this.shippingCost, //: 200,
  });

  // ===================== HELPERS =====================

  /// ✅ أي قيمة (int/double/String/null) -> num?
  static num? parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString())??0;
  }

  /// ✅ أي قيمة (int/double/String/null) -> int?
  static int? parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString())??0;
  }

  /// ✅ parsing للـ DateTime
  // static DateTime? parseDate(dynamic v) {
  //   if (v == null) return null;
  //   final s = v.toString().trim();
  //   if (s.isEmpty) return null;
  //   return DateTime.tryParse(s);
  // }
  static DateTime parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    final s = v.toString().trim();
    if (s.isEmpty) return DateTime.now();
    return DateTime.tryParse(s) ?? DateTime.now();
  }







  // ===================== FROM JSON =====================
  factory TradeOrOrder.fromJson(Map<String, dynamic> json) {
    return TradeOrOrder(
      id: parseInt(json['id']),
      type: json['type']?.toString(),
      status: json['status']?.toString(),
      mode: json['mode']?.toString(),

      productId: parseInt(json['product_id']),


      quantity: parseNum(json['quantity']),

      unitGramWeight: parseNum(json['unit_gram_weight'] ?? "0"),
      unitKarat: parseInt(json['unit_karat']),

      product: (json['product'] is Map<String, dynamic>)
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,

      metal: json['metal']?.toString(),
      currency: json['currency']?.toString(),


      totalGrams: parseNum(json['total_grams']),





              // openPrice: parseNum(json['open_price']),
              // stopLoss: parseNum(json['stop_loss']),
              // takeProfit: parseNum(json['take_profit']),
              // sellWhenPrice: parseNum(json['sell_when_price']),


        // openPriceOrder: parseNum(json['open_price_per_bar']),




        openPrice: parseNum(json['sell_when_price_per_bar']) == 0 ? parseNum(json['open_price_per_bar']) : parseNum(json['sell_when_price_per_bar']),






           stopLoss: parseNum(json['stop_loss_per_bar']),
           takeProfit: parseNum(json['take_profit_per_bar']),
           sellWhenPrice: parseNum(json['sell_when_price_per_bar']),
           // entryPrice: parseNum(json['entry_price']),




      prevClosePrice: parseNum(json['prev_close_price']),
      closeKind: json['close_kind']??"",
      closedAt: json['closed_at']??"",
      closePrice: parseNum(json['close_price']),
      openTime: json['open_time']??"",




      pnlUsd: parseNum(json['floating_pnl_usd']),
      pnlEgp: parseNum(json['floating_pnl_egp']),










      price: parseNum(json['price']),
      executedPrice: parseNum(json['executed_price']),
      realizedPnl: parseNum(json['realized_pnl']),
      unrealizedPnl: parseNum(json['unrealized_pnl']),
      lowPrice: parseNum(json['low_price']),
      highPrice: parseNum(json['high_price']),

      ch: parseNum(json['ch']),
      chp: parseNum(json['chp']),
      ask: parseNum(json['ask']),
      bid: parseNum(json['bid']),

      priceGram24k: parseNum(json['price_gram_24k']),
      priceGram22k: parseNum(json['price_gram_22k']),
      priceGram21k: parseNum(json['price_gram_21k']),
      priceGram20k: parseNum(json['price_gram_20k']),
      priceGram18k: parseNum(json['price_gram_18k']),
      priceGram16k: parseNum(json['price_gram_16k']),
      priceGram14k: parseNum(json['price_gram_14k']),
      priceGram10k: parseNum(json['price_gram_10k']),

      deliveryStatus: json['delivery_status']?.toString(),
      deliveryRequestedAt: parseDate(json['delivery_requested_at']),
      deliveryMethod: json['delivery_method']?.toString(),
      deliveryCity: json['delivery_city']?.toString(),
      deliveryPhone: json['delivery_phone']?.toString(),

      deliveryTrackingNo: json['delivery_tracking_no']?.toString(),
      address: json['address']?.toString(),

      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),

      totalCost: parseNum(json['total_cost']),

      deliveryFee: parseNum(json['delivery_fee']),

      manufacturingFee: json["manufacturingFee"] ?? 0, //: 160,
      hasDelivery: json["hasDelivery"] ?? true, //: true,
      shippingCost: json["shippingCost"] ?? 0, //: 200,
    );
  }

  // ===================== TO JSON =====================
  Map<String, dynamic> toJson() {
    return {





      // 'open_price': openPrice,
      // 'take_profit': takeProfit,
      // 'sell_when_price': sellWhenPrice,
      // 'stop_loss': stopLoss,

      'entry_price_per_bar': openPrice,
      // 'open_price_per_bar': openPriceOrder,


      'take_profit_per_bar': takeProfit,
      'sell_when_price_per_bar': sellWhenPrice,
      'stop_loss_per_bar': stopLoss,




      'close_price': closePrice,
      'close_kind': closeKind,
      'closed_at': closedAt,
      'prev_close_price': prevClosePrice,
      'open_time': openTime,
      "floating_pnl_usd": pnlUsd,
      "floating_pnl_egp": pnlEgp,









      'id': id,
      'type': type,
      'status': status,
      'mode': mode,

      'product_id': productId,
      'quantity': quantity,

      'unit_gram_weight': unitGramWeight,
      'unit_karat': unitKarat,

      'product': product?.toJson(),

      'metal': metal,
      'currency': currency,


      'total_grams': totalGrams,






      'price': price,
      // 'entry_price': entryPrice,
      'executed_price': executedPrice,




      'realized_pnl': realizedPnl,
      'unrealized_pnl': unrealizedPnl,

      'low_price': lowPrice,
      'high_price': highPrice,



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

      'delivery_status': deliveryStatus,
      'delivery_requested_at': deliveryRequestedAt?.toIso8601String(),
      'delivery_method': deliveryMethod,
      'delivery_city': deliveryCity,
      'delivery_phone': deliveryPhone,
      'delivery_fee': deliveryFee,
      'delivery_tracking_no': deliveryTrackingNo,
      'address': address,

      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),

      'total_cost': totalCost,

      "manufacturingFee": manufacturingFee, //: 160,
      "hasDelivery": hasDelivery, //: true,
      "shippingCost": shippingCost //: 200,
    };
  }
}





















































































































