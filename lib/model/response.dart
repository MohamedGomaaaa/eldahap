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
