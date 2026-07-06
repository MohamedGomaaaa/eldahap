import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/model/faq.dart';
import 'package:official_gold/model/slider.dart' as slider;
import 'package:official_gold/model/user.dart';
import 'package:official_gold/view_model/data/network/repos/home_repository.dart';

import '../../../model/news_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(context) => BlocProvider.of<HomeCubit>(context);







  List<slider.Slider> sliders = [];

  Future<void> getSliders() async {
    emit(GetSlidersLoadingState());
    await HomeRepository().sliders().then((List<slider.Slider> value) {
      sliders = value;
      emit(GetSlidersSuccessState(value));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get Sliders');
        emit(GetSlidersErrorState(
            msg: error.response?.data?['message'].toString()));
      }
    });
  }




  List<News> news = [];

  Future<void> getNews() async {
    emit(GetNewsLoadingState());
    await HomeRepository().news().then((value) {
      // news = value;
      news = value.reversed.toList();

      emit(GetNewsSuccessState(value));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get News');
        emit(GetNewsErrorState(
            msg: error.response?.data?['message'].toString()));
      }
    });
  }

  List<FAQ> faqs = [];

  Future<void> getFaqs() async {
    emit(GetFAQLoadingState());
    await HomeRepository().faq().then((value) {
      faqs = value;
      emit(GetFAQSuccessState(value));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get News');
        emit(
            GetFAQErrorState(msg: error.response?.data?['message'].toString()));
      }
    });
  }

  void changeFAQ(int index, bool isExpanded) {
    faqs[index].isExpanded = isExpanded;
    emit(GetFAQSuccessState(faqs));
  }

  ValueNotifier<User> user = ValueNotifier<User>(User());

  Future<void> getProfile() async {
    emit(GetProfileLoadingState());
    await HomeRepository().profile().then((value) {
      user.value = value;
      print("user home= ${user.value.toJson()}");
      fillControllers();
      emit(GetProfileSuccessState(user.value));
    }).catchError((error) {
      print("errrrrrr $error");
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get News');
        emit(GetProfileErrorState(
            msg: error.response?.data?['message'].toString()));
      }
    });
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  File? nationalIdFront;
  File? nationalIdBack;

  void clearControllers() {
    // nameController.clear();
    // emailController.clear();
    // phoneController.clear();
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void fillControllers() {
    nameController.text = user.value.name ?? '';
    emailController.text = user.value.email ?? '';
    phoneController.text = user.value.mobile ?? '';
  }

  Future<void> updateProfile() async {
    emit(GetProfileLoadingState());
    await HomeRepository()
        .updateProfile(
      name: nameController.text,
      mobileNumber: phoneController.text,
      email: emailController.text,
      password: newPasswordController.text,
      nationalIdFront: nationalIdFront,
      nationalIdBack: nationalIdBack,

    )
        .then((value) {
      user.value = value;
      fillControllers();
      clearControllers();
      emit(GetProfileSuccessState(user.value));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get News');
        emit(GetProfileErrorState(
            msg: error.response?.data?['message'].toString()));
      }
      throw error;
    });
  }

  Future<void> changeMode() async {
    emit(GetProfileLoadingState());
    await HomeRepository()
        .changeMode(
      mode: user.value.mode =="demo" ? "live" : "demo",
    )
        .then((value) {
      user.value = value;
      fillControllers();
      clearControllers();
      emit(GetProfileSuccessState(user.value));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get News');
        emit(GetProfileErrorState(
            msg: error.response?.data?['message'].toString()));
      }
      throw error;
    });
  }




  Future<void> updateProfileNationalId(File? nationalIdFront, File? nationalIdBack) async {
    emit(GetProfileLoadingState());
    print("nationalIdFront = ${nationalIdFront?.path}");
    print("nationalIdBack = ${nationalIdBack?.path}");
    await HomeRepository()
        .updateProfileNationalIds(
      nationalIdFront: nationalIdFront,
      nationalIdBack: nationalIdBack,

    )
        .then((value) {
      user.value = value;

      emit(GetProfileSuccessState(user.value));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString() ?? 'Error on Get News');
        emit(GetProfileErrorState(
            msg: error.response?.data?['message'].toString()));
      }
      throw error;
    });
  }void resetHomeData() {
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>. Reseting/Cleaning Home Profile Data");

    // 1. إعادة تعيين كائن المستخدم لكائن فارغ جديد
    user.value = User();

    // 2. تصفير الـ Controllers تماماً
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    nationalIdFront = null;
    nationalIdBack = null;

    // 3. إرجاع الـ Cubit للحالة المبدئية
    emit(HomeInitial());
  }
}
