class Report2 {
  bool? success;
  String? message;
  List<ReportResult2>? result;

  Report2({this.success, this.message, this.result});

  Report2.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['result'] != null) {
      result = <ReportResult2>[];
      json['result'].forEach((v) {
        result!.add(ReportResult2.fromJson(v));
      });
    }
  }


}

class ReportResult2 {
  int? id;
  String? amount;
  String? requestAt;
  String? isApproval;
  String? approveAt;

  ReportResult2(
      {this.id, this.amount, this.requestAt, this.isApproval, this.approveAt});

  ReportResult2.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount']??"";
    requestAt = json['request_at']??"";
    isApproval = json['is_approval']??"";
    approveAt = json['approve_at']??"";
  }


}
