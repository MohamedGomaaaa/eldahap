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
class Response {
  int? id;
  int? ticket;
  String? response;
  String? replyAt;
  String? user;

  Response({
    this.id,
    this.ticket,
    this.response,
    this.replyAt,
    this.user,
  });

  Response.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ticket = json['ticket'];
    response = json['response'];
    replyAt = json['reply_at'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ticket'] = ticket;
    data['response'] = response;
    data['reply_at'] = replyAt;
    data['user'] = user;
    return data;
  }
}