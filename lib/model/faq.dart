class FAQ {
  int? id;
  String? question;
  String? answer;
  bool? isExpanded = false;

  FAQ({this.id, this.question, this.answer, this.isExpanded = false,});

  FAQ.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['answer'] = answer;
    return data;
  }
}