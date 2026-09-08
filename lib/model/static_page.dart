class StaticPageModel {
  final int id;
  final String title;
  final String content;
  final int publish;
  final String image;

  StaticPageModel({
    required this.id,
    required this.title,
    required this.content,
    required this.publish,
    required this.image,
  });

  factory StaticPageModel.fromJson(Map<String, dynamic> json) {
    return StaticPageModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      publish: json['publish'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}