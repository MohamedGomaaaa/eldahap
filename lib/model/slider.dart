class Slider {
  int? id;
  String? title;
  String? subTitle;
  String? link;
  String? image;

  Slider({
    this.id,
    this.title,
    this.subTitle,
    this.link,
    this.image,
  });

  Slider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    subTitle = json['sub_title'];
    link = json['link'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['sub_title'] = subTitle;
    data['link'] = link;
    data['image'] = image;
    return data;
  }
}
