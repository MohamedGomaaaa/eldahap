class Ticket {
  int? id;
  String? message;
  String? sendAt;
  String? status;

  Ticket({this.id, this.message, this.sendAt, this.status});

  Ticket.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    sendAt = json['send_at'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['message'] = message;
    data['send_at'] = sendAt;
    data['status'] = status;
    return data;
  }
}