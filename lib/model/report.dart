class Report {
  int? id;
  String? amount;
  String? requestAt;
  String? isApproval;
  String? approveAt;

  Report({
    this.id,
    this.amount,
    this.requestAt,
    this.isApproval,
    this.approveAt,
  });

  Report.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    requestAt = json['request_at'];
    isApproval = json['is_approval'];
    approveAt = json['approve_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['request_at'] = requestAt;
    data['is_approval'] = isApproval;
    data['approve_at'] = approveAt;
    return data;
  }
}
