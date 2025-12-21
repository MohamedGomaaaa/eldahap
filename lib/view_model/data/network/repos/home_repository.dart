import 'dart:io';

import 'package:official_gold/model/new.dart';
import 'package:official_gold/model/slider.dart';
import 'package:official_gold/view_model/utils/toast.dart';

import '../../../../model/faq.dart';
import '../../../../model/user.dart';
import '../data_providers/home_providers.dart';

class HomeRepository {
  late final HomeProvider homeProvider;

  HomeRepository() {
    homeProvider = HomeProvider();
  }

  Future<List<Slider>> sliders() async {
    try {
      final slidersResponse = await homeProvider.sliders();
      return (slidersResponse?.data?['result'] as List)
          .map((e) => Slider.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<New>> news() async {
    try {
      final newsResponse = await homeProvider.news();
      return (newsResponse?.data?['result'] as List)
          .map((e) => New.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FAQ>> faq() async {
    try {
      final faqResponse = await homeProvider.faq();
      return (faqResponse?.data?['result'] as List)
          .map((e) => FAQ.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> profile() async {
    try {
      final newsResponse = await homeProvider.profile();
      return User.fromJson(newsResponse?.data?['result']);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile({
    required String name,
    required String mobileNumber,
    required String email,
    required String password,
    File? nationalIdFront,
    File? nationalIdBack,
  }) async {
    try {
      final newsResponse = await homeProvider.updateProfile(
        name: name,
        mobileNumber: mobileNumber,
        email: email,
        password: password,
        nationalIdFront: nationalIdFront,
        nationalIdBack: nationalIdBack,
      );
      Toast.showMsg(msg: newsResponse?.data?['message'] ?? 'Profile Updated');
      return User.fromJson(newsResponse?.data?['result']);
    } catch (e) {
      rethrow;
    }
  }


  Future<User> changeMode({
    required String mode,
  }) async {
    try {
      final newsResponse = await homeProvider.changeMode(
        mode: mode,
      );
      Toast.showMsg(msg: newsResponse?.data?['message'] ?? 'Profile Updated');
      return User.fromJson(newsResponse?.data?['result']);
    } catch (e) {
      rethrow;
    }
  }


  Future<User> updateProfileNationalIds({

    File? nationalIdFront,
    File? nationalIdBack,
  }) async {
    try {
      final newsResponse = await homeProvider.updateProfileNationalIds(
        nationalIdFront: nationalIdFront,
        nationalIdBack: nationalIdBack,
      );
      Toast.showMsg(msg: newsResponse?.data?['message'] ?? 'Profile Updated');
      return User.fromJson(newsResponse?.data?['result']);
    } catch (e) {
      rethrow;
    }
  }
}
