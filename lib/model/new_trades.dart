

import 'package:official_gold/model/trade_model.dart';

class Tradess {
  bool? success;
  String? message;
  List<Result>? result;

  Tradess({this.success, this.message, this.result});

  Tradess.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(new Result.fromJson(v));
      });
    }
  }






  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.result != null) {
      data['result'] = this.result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? metal;
  String? title;
  List<Trade>? orders;

  Result({this.metal, this.title, this.orders});

  Result.fromJson(Map<String, dynamic> json) {
    metal = json['metal']??"";
    title = json['title']??"";
    if (json['orders'] != null) {
      orders = <Trade>[];
      json['orders'].forEach((v) {
        orders!.add(new Trade.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['metal'] = this.metal;
    data['title'] = this.title;
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

