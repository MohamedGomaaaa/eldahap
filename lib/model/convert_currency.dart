class ConvertCurrencyResult {
  String? from;
  String? to;
  num? amount;
  num? convertedAmount;
  num? exchangeRate;
  num? balanceUsd;
  num? balanceEgp;

  ConvertCurrencyResult.fromJson(Map<String, dynamic> json) {
    from = json['from']??"";
    to = json['to']??"";
    amount = json['amount']??0;
    convertedAmount = json['converted_amount']??0;
    exchangeRate = json['exchange_rate']??0;
    balanceUsd = json['balance_usd']??0;
    balanceEgp = json['balance_egp']??0;
  }
}