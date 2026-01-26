import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/dio_helper.dart';
import 'package:official_gold/view_model/data/network/end_points.dart';
import 'package:official_gold/view_model/data/network/repos/product_repository.dart';

import '../../../model/category.dart';
import '../../../model/product.dart';
import '../../utils/toast.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  static ProductCubit get(context) => BlocProvider.of<ProductCubit>(context);

  final formProductKey = GlobalKey<FormState>();

  TextEditingController quantityController = TextEditingController();

  void addQuantity() {
    quantityController.text =
        ((num.tryParse(quantityController.text) ?? 0) + 1).toString();
    emit(AddQuantityState());
  }

  void subtractQuantity() {
    if ((num.tryParse(quantityController.text) ?? 0) > 1) {
      quantityController.text =
          ((num.tryParse(quantityController.text) ?? 0) - 1).toString();
      emit(SubtractQuantityState());
    }
  }

  TextEditingController amountController = TextEditingController();
  bool sellWhenPriceIs = true;

  void changeSellWhenPriceIs(bool value) {
    sellWhenPriceIs = value;
    emit(ChangeSellWhenPriceIsState());
  }

  void addAmount() {
    amountController.text =
        ((num.tryParse(amountController.text) ?? 0) + 1).toString();
    emit(AddAmountState());
  }

  void subtractAmount() {
    if ((num.tryParse(amountController.text) ?? 0) > 1) {
      amountController.text =
          ((num.tryParse(amountController.text) ?? 0) - 1).toString();
      emit(SubtractAmountState());
    }
  }

  TextEditingController stopLossController = TextEditingController();
  bool stopLoss = true;

  void changeStopLoss(bool value) {
    stopLoss = value;
    emit(ChangeStopLossState());
  }

  void addAmountStopLoss() {
    stopLossController.text =
        ((num.tryParse(stopLossController.text) ?? 0) + 1).toString();
    emit(AddAmountStopLossState());
  }

  void subtractAmountStopLoss() {
    if ((num.tryParse(stopLossController.text) ?? 0) > 1) {
      stopLossController.text =
          ((num.tryParse(stopLossController.text) ?? 0) - 1).toString();
      emit(SubtractAmountStopLossState());
    }
  }

  TextEditingController takeProfitController = TextEditingController();
  bool takeProfit = true;

  TextEditingController sellWhenPriceController = TextEditingController();
  bool sellWhenPrice = true;

  void changeSellWhenPrice(bool value) {
    sellWhenPrice = value;
    emit(ChangeSellWhenPriceState());
  }

  void changeTakeProfit(bool value) {
    takeProfit = value;
    emit(ChangeTakeProfitState());
  }

  void addSellWhenPriceProfit() {
    sellWhenPriceController.text =
        ((num.tryParse(sellWhenPriceController.text) ?? 0)).toString();
    emit(AddSellWhenPriceState());
  }

  void addAmountTakeProfit() {
    takeProfitController.text =
        ((num.tryParse(takeProfitController.text) ?? 0) + 1).toString();
    emit(AddAmountTakeProfitState());
  }

  void subtractAmountTakeProfit() {
    if ((num.tryParse(takeProfitController.text) ?? 0) > 1) {
      takeProfitController.text =
          ((num.tryParse(takeProfitController.text) ?? 0) - 1).toString();
      emit(SubtractAmountTakeProfitState());
    }
  }

  void resetControllers() {
    quantityController.clear();
    amountController.clear();
    stopLossController.clear();
    takeProfitController.clear();
    sellWhenPriceIs = false;
    stopLoss = false;
    takeProfit = false;
    emit(ResetControllersState());
  }

  List<Category> categories = [];

  Future<void> getCategories() async {
    emit(GetCategoriesLoadingState());
    await ProductRepository().categories().then((value) {
      categories = value;

      // debugPrint(
      //     '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>: ${categories.length}');
      emit(GetCategoriesSuccessState(categories));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(
            'Error on Get Categories: ${error.response?.data?.toString()}');
        Toast.showError(
            msg: error.response?.data?.toString() ?? 'Error on Get Categories');
      }
      emit(GetCategoriesErrorState(msg: error.toString()));
    });
  }

  Future<void> getProducts(int index) async {
    if (state is GetProductsLoadingState) return;
    emit(GetProductsLoadingState());
    await ProductRepository()
        .products(categoryId: categories[index].id ?? 0)
        .then((value) {
      categories[index].products= value;
      categories[index].products;
      emit(GetProductsSuccessState(categories));
    }).catchError((error) {
      print("llllllllllllll $error");
      if (error is DioException) {
        debugPrint(
            'Error on Get Products: ${error.response?.data?.toString()}');
        Toast.showError(
            msg: error.response?.data?.toString() ?? 'Error on Get Products');
      }
      emit(GetProductsErrorState(msg: error.toString()));
    });
  }

  Future<void> makeOrder(Product product,double livePrice) async {
    emit(MakeOrderLoadingState());
    await DioHelper.post(
      path: EndPoints.orderStore,
      data: {
        // ...product.toJson(),
        // 'metal': product.symbol?.split("/")[0] ?? 'XAU',
        // 'currency': product.currency ?? 'USD',
        // 'price': product.price ?? 1895.50,
        // 'prev_close_price': product.prevClosePrice ?? 1890.40,
        // 'open_price': product.openPrice ?? 1892.10,
        // 'low_price': product.lowPrice ?? 1880.00,
        // 'high_price': product.highPrice ?? 1900.00,
        // 'open_time': product.openTime ?? '2025-01-01 10:00:00',
        // 'ch': product.ch ?? '+5',
        // 'chp': product.chp ?? '+0.2',
        // 'ask': product.ask ?? 1896.00,
        // 'bid': product.bid ?? 1895.00,
        //
        // 'price_gram_24k': product.priceGram24k ?? 62.50,
        // 'price_gram_22k': product.priceGram22k ?? 57.30,
        // 'price_gram_21k': product.priceGram21k ?? 54.70,
        // 'price_gram_20k': product.priceGram20k ?? 52.10,
        // 'price_gram_18k': product.priceGram18k ?? 46.90,
        // 'price_gram_16k': product.priceGram16k ?? 41.80,
        // 'price_gram_14k': product.priceGram14k ?? 36.50,
        // 'price_gram_10k': product.priceGram10k ?? 26.30,
        // 'qty' : num.tryParse(quantityController.text) ?? 0,


        //
        // 'stop_loss' : num.tryParse(stopLossController.text) ?? 0,
        // 'take_profit' : num.tryParse(takeProfitController.text) ?? 0,
        //  'sell_when_price' :  num.tryParse(amountController.text) ?? 0, // هوه كاتب الكي غلط هي المفروض  اشتري لما السعر يوصل للكنترولر ده و يحولها من اوردر معلق الي صفقه
//////////////////////////////////////////////////////////////////////////////////// new bu eng gomaa
        "metal": product.symbol?.split("/")[0] ?? 'XAU',
        'currency': product.currency ?? 'USD',
        'open_price': livePrice,
        'qty': num.tryParse(quantityController.text) ?? 0,
        if (stopLossController.text.trim().isNotEmpty)
          'stop_loss': num.parse(stopLossController.text.trim()),
        if (takeProfitController.text.trim().isNotEmpty)
          'take_profit': num.parse(takeProfitController.text.trim()),

      },
      withToken: true,
    ).then((value) {
      log(value.toString());
      Toast.showMsg(msg: value.data['message'].toString());
      resetControllers();
      emit(MakeOrderSuccessState());
    }).catchError((error) {
      if (error is DioException) {
        debugPrint('Error on Make Order: ${error.response?.data?.toString()}');
        Toast.showError(
            msg: error.response?.data?.toString() ?? 'Error on Make Order');
      }
      emit(MakeOrderErrorState(msg: error.toString()));
      throw error;
    });
  }
}
