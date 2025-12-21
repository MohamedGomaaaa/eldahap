import 'dart:io';

import 'package:dio/dio.dart';
import 'package:official_gold/view_model/data/network/dio_helper.dart';
import 'package:official_gold/view_model/data/network/end_points.dart';

class HomeProvider {
  HomeProvider();

  Future<Response?> sliders() async {
    try{
      return await DioHelper.get(
        path: EndPoints.sliders,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> news() async {
    try{
      return await DioHelper.get(
        path: EndPoints.news,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> faq() async {
    try{
      return await DioHelper.get(
        path: EndPoints.faq,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> profile() async {
    try{
      return await DioHelper.get(
        path: EndPoints.profile,
        withToken: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Future<Response?> updateProfile({required String name, required String mobileNumber, required String email, required String password,
  //
  //
  // }) async {
  //   try{
  //     return await DioHelper.post(
  //       path: EndPoints.updateProfile,
  //       withToken: true,
  //       data: {
  //         'name' : name,
  //         'mobile_number' : mobileNumber,
  //         'email' : email,
  //         'password' : password,
  //       },
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<Response?> changeMode({
    required String mode,
  }) async {
    try {
      return await DioHelper.post(
        path: EndPoints.changeMode,
        withToken: true,
        data: {
          "mode": mode,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> updateProfile({
    required String name,
    required String mobileNumber,
    required String email,
    required String password,
    File? nationalIdFront,
    File? nationalIdBack,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'mobile_number': mobileNumber,
        'email': email,
        'password': password,
        if (nationalIdFront != null)
          'national_id_front': await MultipartFile.fromFile(
            nationalIdFront.path,
            filename: nationalIdFront.path.split('/').last,
          ),
        if (nationalIdBack != null)
          'national_id_back': await MultipartFile.fromFile(
            nationalIdBack.path,
            filename: nationalIdBack.path.split('/').last,
          ),
      });

      return await DioHelper.post(
        path: EndPoints.updateProfile,
        withToken: true,
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<Response?> updateProfileNationalIds({
    File? nationalIdFront,
    File? nationalIdBack,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        if (nationalIdFront != null)
          'national_id_front': await MultipartFile.fromFile(
            nationalIdFront.path,
            filename: nationalIdFront.path.split('/').last,
          ),
        if (nationalIdBack != null)
          'national_id_back': await MultipartFile.fromFile(
            nationalIdBack.path,
            filename: nationalIdBack.path.split('/').last,
          ),
      });

      return await DioHelper.post(
        path: EndPoints.updateProfile,
        withToken: true,
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }
}
