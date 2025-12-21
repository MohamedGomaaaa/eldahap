import 'package:official_gold/model/category.dart';
import 'package:official_gold/model/product.dart';
import 'package:official_gold/view_model/data/network/data_providers/product_providers.dart';
import 'package:official_gold/view_model/utils/toast.dart';

class ProductRepository {

  late final ProductProvider productProvider;

  ProductRepository() {
    productProvider = ProductProvider();
  }

  Future<List<Category>> categories() async {
    try {
      final categoriesResponse = await productProvider.categories();
      return (categoriesResponse?.data?['result'] as List).map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> products({required int categoryId}) async {
    try {
      final productsResponse = await productProvider.products(categoryId: categoryId);
     // if(productsResponse?.data?['result'] == null || productsRexsponse?.data?['result'][0]['error'] != null) {
      if(!productsResponse?.data?['success']) {
        Toast.showError(msg: productsResponse?.data?['result'][0]['error'] ?? 'Error on Get Products');
        return [];
      }
      print("Products Response: ${productsResponse?.data?['products']}");
      return (productsResponse?.data?['products'] as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
