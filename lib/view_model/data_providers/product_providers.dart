import 'package:dio/dio.dart';

import '../../services/dio_helper/dio_helper.dart';
import '../../services/end_points/end_points.dart';

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
