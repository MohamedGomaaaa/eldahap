import 'package:dio/dio.dart';
import 'package:official_gold/view_model/data/network/dio_helper.dart';
import 'package:official_gold/view_model/data/network/end_points.dart';

class ProductProvider {

  Future<Response?> categories() async {
    try{
      return await DioHelper.get(
        path: EndPoints.categories,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> products({required int categoryId}) async {
    try{
      return await DioHelper.get(
        path: '${EndPoints.products}/$categoryId',
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
