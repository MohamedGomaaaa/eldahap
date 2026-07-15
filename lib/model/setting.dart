import 'package:official_gold/view_model/utils/app_constant.dart';

class Setting {
  bool? success;
  String? message;
  SettingResult? result;

  Setting({this.success, this.message, this.result});

  Setting.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    result =
    json['result'] != null ? new SettingResult.fromJson(json['result']) : null;
  }

}

class SettingResult {
  String? from;
  String? to;
  num? exchangeDollarRate;
  String? lastUpdated;

  SettingResult({this.from, this.to, this.exchangeDollarRate, this.lastUpdated});

  SettingResult.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    exchangeDollarRate = json['rate']??AppConstant.dollarConstant;
    lastUpdated = json['last_updated'];
  }

}
