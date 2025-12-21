import 'package:official_gold/model/product.dart';

class Category {
  int? id;
  String? name;
  List<Product> products = [];

  Category({
    this.id,
    this.name,
    this.products = const [],
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
