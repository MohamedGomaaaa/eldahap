

import 'package:official_gold/model/trade_model.dart';

class Tradess {
  bool? success;
  String? message;
  List<GroupOfTradesOrOrders>? groupOfTradesOrOrders;

  Tradess({this.success, this.message, this.groupOfTradesOrOrders});

  Tradess.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['result'] != null) {
      groupOfTradesOrOrders = <GroupOfTradesOrOrders>[];
      json['result'].forEach((v) {
        groupOfTradesOrOrders!.add(new GroupOfTradesOrOrders.fromJson(v));
      });
    }
  }






  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.groupOfTradesOrOrders != null) {
      data['result'] = this.groupOfTradesOrOrders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupOfTradesOrOrders {
  String? metal;
  String? title;
  List<TradeOrOrder>? tradesOrOrders;

  GroupOfTradesOrOrders({this.metal, this.title, this.tradesOrOrders});

  GroupOfTradesOrOrders.fromJson(Map<String, dynamic> json) {
    metal = json['metal']??"";
    title = json['title']??"";
    if (json['orders'] != null) {
      tradesOrOrders = <TradeOrOrder>[];
      json['orders'].forEach((v) {
        tradesOrOrders!.add(new TradeOrOrder.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['metal'] = this.metal;
    data['title'] = this.title;
    if (this.tradesOrOrders != null) {
      data['orders'] = this.tradesOrOrders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

