import 'package:official_gold/model/trade_order_model.dart';




class Report1 {
  ReportResult1? result;

  Report1({this.result});

  Report1.fromJson(Map<String, dynamic> json) {
    result =
    json['result'] != null ? ReportResult1.fromJson(json['result']) : null;
  }
}

class ReportResult1 {
  String? mode;
  List<TradeOrOrder>? tradeOrOrder;

  ReportResult1({this.mode, this.tradeOrOrder});

  ReportResult1.fromJson(Map<String, dynamic> json) {
    mode = json['mode']?.toString();

    if (json['data'] != null) {
      tradeOrOrder = <TradeOrOrder>[];
      json['data'].forEach((v) {
        tradeOrOrder!.add(TradeOrOrder.fromJson(v));
      });
    } else {
      tradeOrOrder = [];
    }
  }
}