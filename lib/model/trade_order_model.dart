// class TradeOrOrder {
//   final int? id;
//   final String? metal;
//   final String? user;
//   final String? currency;
//
//   final String? prevClosePrice;
//   final String? openPrice;
//   final String? lowPrice;
//   final String? highPrice;
//   final String? price;
//   final String? ch;
//   final String? chp;
//   final String? ask;
//   final String? bid;
//
//   final String? priceGram24k;
//   final String? priceGram22k;
//   final String? priceGram21k;
//   final String? priceGram20k;
//   final String? priceGram18k;
//   final String? priceGram16k;
//   final String? priceGram14k;
//   final String? priceGram10k;
//
//   final String? qty;
//
//   final String? stopLoss;
//   final String? takeProfit;
//   final String? sellWhenPrice;
//   final String? entryPrice;
//   final String? status;
//
//   final String? type;
//   TradeOrOrder({
//     this.status,
//     this.type,
//     this.entryPrice,
//     this.id,
//     this.metal,
//     this.user,
//     this.currency,
//     this.prevClosePrice,
//     this.openPrice,
//     this.lowPrice,
//     this.highPrice,
//     this.price,
//     this.ch,
//     this.chp,
//     this.ask,
//     this.bid,
//     this.priceGram24k,
//     this.priceGram22k,
//     this.priceGram21k,
//     this.priceGram20k,
//     this.priceGram18k,
//     this.priceGram16k,
//     this.priceGram14k,
//     this.priceGram10k,
//     this.qty,
//     this.stopLoss,
//     this.takeProfit,
//     this.sellWhenPrice,
//   });
//
//   /// ✅ helper: أي قيمة (int/double/String/null) -> String
//   /// null أو "" -> "0"
//   static String parseStringNumber(dynamic v, {String def = "0"}) {
//     if (v == null) return def;
//
//     if (v is String) {
//       final t = v.trim();
//       return t.isEmpty ? def : t;
//     }
//
//     return v.toString();
//   }
//
//   /// fromJson
//   factory TradeOrOrder.fromJson(Map<String, dynamic> json) {
//     return TradeOrOrder(
//         id: json['id'], // لو ممكن يجي String قولي أظبطه
//         metal: json['metal'] ?? "",
//         user: json['user'] ?? "",
//         currency: json['currency'] ?? "",
//         openPrice: json['open_price'] ?? "",
//         lowPrice: json['low_price'] ?? "",
//         highPrice: json['high_price'] ?? "",
//         price: json['price'] ?? "",
//         ch: json['ch'] ?? "",
//         chp: json['chp'] ?? "",
//         ask: json['ask'] ?? "",
//         bid: json['bid'] ?? "",
//         priceGram24k: json['price_gram_24k'] ?? "",
//         priceGram22k: json['price_gram_22k'] ?? "",
//         priceGram21k: json['price_gram_21k'] ?? "",
//         priceGram20k: json['price_gram_20k'] ?? "",
//         priceGram18k: json['price_gram_18k'] ?? "",
//         priceGram16k: json['price_gram_16k'] ?? "",
//         priceGram14k: json['price_gram_14k'] ?? "",
//         priceGram10k: json['price_gram_10k'] ?? "",
//         prevClosePrice: json['prev_close_price'] ?? "",
//
//         // ✅ دول اللي محتاجين handling
//         //   qty: parseStringNumber(json['qty']),
//         qty: parseStringNumber(json['quantity']),
//         stopLoss: parseStringNumber(json['stop_loss']),
//         takeProfit: parseStringNumber(json['take_profit']),
//         sellWhenPrice: parseStringNumber(json['sell_when_price']),
//         entryPrice: parseStringNumber(json['entry_price']),
//         type: json['type'],
//         status: json['status']);
//   }
//
//   /// toJson
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'metal': metal,
//       'user': user,
//       'currency': currency,
//       'prev_close_price': prevClosePrice,
//       'open_price': openPrice,
//       'low_price': lowPrice,
//       'high_price': highPrice,
//       'price': price,
//       'ch': ch,
//       'chp': chp,
//       'ask': ask,
//       'bid': bid,
//       'price_gram_24k': priceGram24k,
//       'price_gram_22k': priceGram22k,
//       'price_gram_21k': priceGram21k,
//       'price_gram_20k': priceGram20k,
//       'price_gram_18k': priceGram18k,
//       'price_gram_16k': priceGram16k,
//       'price_gram_14k': priceGram14k,
//       'price_gram_10k': priceGram10k,
//       // 'qty': qty,
//
//       "quantity": qty,
//       'stop_loss': stopLoss,
//       'take_profit': takeProfit,
//       'sell_when_price': sellWhenPrice,
//       'entry_price': entryPrice,
//
//       "type": type,
//       "status": status
//     };
//   }
// }
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
  final num? entryPrice;
  final num? executedPrice;
  final num? closePrice;


  final num? realizedPnl;
  final num? unrealizedPnl;

  final String? closeKind;
  final DateTime? closedAt;

  final num? prevClosePrice;
  final num? lowPrice;
  final num? highPrice;

  final DateTime? openTime;

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
  final num ? openPriceOrder;
  final num? stopLoss;
  final num? takeProfit;
  final num? sellWhenPrice;










  TradeOrOrder({
    this.openPrice,
    this.openPriceOrder,
    this.stopLoss,
    this.takeProfit,
    this.sellWhenPrice,












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
    this.entryPrice,
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


           openPriceOrder: parseNum(json['open_price_per_bar']),
           openPrice: parseNum(json['entry_price_per_bar']),
           stopLoss: parseNum(json['stop_loss_per_bar']),
           takeProfit: parseNum(json['take_profit_per_bar']),
           sellWhenPrice: parseNum(json['sell_when_price_per_bar']),










      price: parseNum(json['price']),
      entryPrice: parseNum(json['entry_price']),
      executedPrice: parseNum(json['executed_price']),
      closePrice: parseNum(json['close_price']),




      realizedPnl: parseNum(json['realized_pnl']),
      unrealizedPnl: parseNum(json['unrealized_pnl']),

      closeKind: json['close_kind']?.toString(),
      closedAt: parseDate(json['closed_at']),

      prevClosePrice: parseNum(json['prev_close_price']),
      lowPrice: parseNum(json['low_price']),
      highPrice: parseNum(json['high_price']),

      openTime: parseDate(json['open_time']),

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
      'open_price_per_bar': openPriceOrder,
      'take_profit_per_bar': takeProfit,
      'sell_when_price_per_bar': sellWhenPrice,
      'stop_loss_per_bar': stopLoss,
















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
      'entry_price': entryPrice,
      'executed_price': executedPrice,
      'close_price': closePrice,




      'realized_pnl': realizedPnl,
      'unrealized_pnl': unrealizedPnl,

      'close_kind': closeKind,
      'closed_at': closedAt?.toIso8601String(),

      'prev_close_price': prevClosePrice,
      'low_price': lowPrice,
      'high_price': highPrice,

      'open_time': openTime?.toIso8601String(),

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





















































































































