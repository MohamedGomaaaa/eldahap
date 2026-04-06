
import '../view_model/utils/common_method.dart';

class Wallet {
  bool? success;
  String? message;
  WalletResult? result;

  Wallet({this.success, this.message, this.result});

  Wallet.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    result =
    json['result'] != null ?  WalletResult.fromJson(json['result']) : null;
  }
  //
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['success'] = this.success;
  //   data['message'] = this.message;
  //   if (this.result != null) {
  //     data['result'] = this.result!.toJson();
  //   }
  //   return data;
  // }
}

class WalletResult {
  String? mode;
  num? balanceDollar;
  num? balanceEgp;
  num? waitWithdraw;
  num? waitWithdrawEgp;
  num? exchangeRate;

  WalletResult(
      {this.mode,
        this.balanceDollar,
        this.balanceEgp,
        this.waitWithdraw,
        this.waitWithdrawEgp,
        this.exchangeRate});

  WalletResult.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    balanceDollar =num.parse(Methods.removeTrailingZeros(json['balance']??0));
    balanceEgp = num.parse(Methods.removeTrailingZeros(json['balance_egp']??0));
    waitWithdraw = json['wait_withdraw']??0;
    waitWithdrawEgp = json['wait_withdraw_egp']??0;
    exchangeRate = json['exchange_rate']??0;
  }
  //
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['mode'] = this.mode;
  //   data['balance'] = this.balance;
  //   data['balance_egp'] = this.balanceEgp;
  //   data['wait_withdraw'] = this.waitWithdraw;
  //   data['wait_withdraw_egp'] = this.waitWithdrawEgp;
  //   data['exchange_rate'] = this.exchangeRate;
  //   return data;
  // }
}
