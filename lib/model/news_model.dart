class News {
  int? id;
  String? name;
  String? content;
  String? publish;
  String? image;

  News({this.id, this.name, this.content, this.publish, this.image});

  News.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    content = json['content'];
    publish = json['publish'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['content'] = content;
    data['publish'] = publish;
    data['image'] = image;
    return data;
  }
}