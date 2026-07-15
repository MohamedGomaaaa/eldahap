class CommissionRateModel {
  final bool? success;
  final String? message;
  final CommissionRateResult? result;

  CommissionRateModel({
    this.success,
    this.message,
    this.result,
  });

  factory CommissionRateModel.fromJson(Map<String, dynamic> json) {
    return CommissionRateModel(
      success: json['success'],
      message: json['message'],
      result: json['result'] != null
          ? CommissionRateResult.fromJson(
        Map<String, dynamic>.from(json['result']),
      )
          : null,
    );
  }
}

class CommissionRateResult {
  final num? commissionRate;
  final String? commissionRatePercent;

  CommissionRateResult({
    this.commissionRate,
    this.commissionRatePercent,
  });

  factory CommissionRateResult.fromJson(Map<String, dynamic> json) {
    return CommissionRateResult(
      commissionRate: json['commission_rate'] ??0,
      commissionRatePercent: json['commission_rate_percent']??"0",
    );
  }
}