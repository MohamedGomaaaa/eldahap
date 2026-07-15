part of 'product_cubit.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class AddQuantityState extends ProductState {}

class SubtractQuantityState extends ProductState {}

class AddAmountState extends ProductState {}

class SubtractAmountState extends ProductState {}

class AddAmountStopLossState extends ProductState {}

class SubtractAmountStopLossState extends ProductState {}

class AddAmountTakeProfitState extends ProductState {}
class AddSellWhenPriceState extends ProductState {}

class SubtractAmountTakeProfitState extends ProductState {}

class ChangeSellWhenPriceIsState extends ProductState {}

class ChangeStopLossState extends ProductState {}

class ChangeTakeProfitState extends ProductState {}
class ChangeSellWhenPriceState extends ProductState {}

class GetCategoriesLoadingState extends ProductState {}

class GetCategoriesSuccessState extends ProductState {
  final List<Category> categories;

  GetCategoriesSuccessState(this.categories);
}

class GetCategoriesErrorState extends ProductState {
  final String? msg;

  GetCategoriesErrorState({this.msg});
}

class GetProductsLoadingState extends ProductState {}

class GetProductsSuccessState extends ProductState {
  final List<Category> categories;

  GetProductsSuccessState(this.categories);
}

class GetProductsErrorState extends ProductState {
  final String? msg;

  GetProductsErrorState({this.msg});
}

class ResetControllersState extends ProductState {}

class MakeOrderLoadingState extends ProductState {}

class MakeOrderSuccessState extends ProductState {}

class MakeOrderErrorState extends ProductState {
  final String? msg;

  MakeOrderErrorState({this.msg});
}
