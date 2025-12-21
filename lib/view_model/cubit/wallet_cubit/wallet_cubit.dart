import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/wallet_repository.dart';

import '../../../model/report.dart';
import '../../models/wallet_models/transaction_model.dart';
import '../../utils/toast.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());

  static WalletCubit get(context) => BlocProvider.of<WalletCubit>(context);

  num wallet = 0;
  TransactionModel? transactionModel;
  List<TransactionData> allTransactions = []; // Store all transactions
  bool isLoadingMoreTransactions = false;
  bool hasMoreTransactions = true;
  int currentTransactionPage = 1;

  Future<void> getWallet() async {
    emit(GetWalletLoadingState());
    await WalletRepository().wallet().then((value) {
      print("Wallet value: $value");
      wallet = double.parse("${value.toStringAsFixed(2)}");
      emit(GetWalletSuccessState(wallet));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        emit(GetWalletErrorState(msg: error.response?.data?.toString()));
      } else {
        debugPrint("Unexpected error: $error");
        emit(GetWalletErrorState(msg: error.toString()));
      }
    });
  }

  // Get initial transactions (first page)
  Future<void> getTransactions({bool refresh = false}) async {
    if (refresh) {
      currentTransactionPage = 1;
      allTransactions.clear();
      hasMoreTransactions = true;
    }

    emit(GetTransactionLoadingState());
    await WalletRepository().transactions(page: currentTransactionPage).then((value) {
      print("Transactions value: $value");
      transactionModel = value;

      if (refresh || currentTransactionPage == 1) {
        allTransactions = value.result.data;
      } else {
        allTransactions.addAll(value.result.data);
      }

      // Check if there are more pages
      hasMoreTransactions = currentTransactionPage < value.result.meta.lastPage;

      emit(GetTransactionSuccessState(transactionModel));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        emit(GetTransactionErrorState(msg: error.response?.data?.toString()));
      } else {
        debugPrint("Unexpected error: $error");
        emit(GetTransactionErrorState(msg: error.toString()));
      }
    });
  }

  // Load more transactions for pagination
  Future<void> loadMoreTransactions() async {
    if (isLoadingMoreTransactions || !hasMoreTransactions) return;

    isLoadingMoreTransactions = true;
    currentTransactionPage++;

    emit(LoadMoreTransactionsState());

    await WalletRepository().transactions(page: currentTransactionPage).then((value) {
      transactionModel = value;
      allTransactions.addAll(value.result.data);

      // Check if there are more pages
      hasMoreTransactions = currentTransactionPage < value.result.meta.lastPage;

      isLoadingMoreTransactions = false;
      emit(LoadMoreTransactionsSuccessState(allTransactions));
    }).catchError((error) {
      currentTransactionPage--; // Revert page increment on error
      isLoadingMoreTransactions = false;

      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        emit(LoadMoreTransactionsErrorState(msg: error.response?.data?.toString()));
      } else {
        debugPrint("Unexpected error: $error");
        emit(LoadMoreTransactionsErrorState(msg: error.toString()));
      }
    });
  }

  // Initialize wallet data - call this when screen starts
  Future<void> initializeWalletData() async {
    await Future.wait([
      getWallet(),
      getTransactions(refresh: true),
    ]);
  }

  Map<String, dynamic> currencies = {};

  Future<void> getCurrencies() async {
    emit(GetCurrenciesLoadingState());
    await WalletRepository().currencies().then((value) {
      currencies = value;
      emit(GetCurrenciesSuccessState(currencies));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
      }
      emit(GetCurrenciesErrorState(msg: error.response?.data?.toString()));
    });
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String currentCurrency = '';

  void changeCurrentCurrency(String currency) {
    currentCurrency = currency;
    emit(ChangeCurrentCurrencyState());
  }

  TextEditingController quantityController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  void clearControllers() {
    currentCurrency = '';
    quantityController.clear();
    messageController.clear();
  }

  Future<void> payUsdt() async {
    emit(PayUsdtLoadingState());
    await WalletRepository()
        .payUsdt(
      currency: currentCurrency,
      amount: num.tryParse(quantityController.text) ?? 0,
      message: messageController.text,
    )
        .then((value) {
      Toast.showMsg(msg: value);
      clearControllers();
      // Refresh transactions after successful payment
      getTransactions(refresh: true);
      emit(PayUsdtSuccessState(value));
    }).catchError((error) {
      if (error is DioException) {
        Toast.showError(
            msg: error.response?.data?.toString() ?? 'Error on pay usdt');
        debugPrint(error.response?.data?.toString());
      }
      emit(PayUsdtErrorState(msg: error.response?.data?.toString()));
    });
  }

  List<Report> depositReports = [];

  Future<void> getDepositReports() async {
    emit(GetDepositReportsLoadingState());
    await WalletRepository().depositReports().then((value) {
      depositReports = value;
      emit(GetDepositReportsSuccessState(depositReports));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
      }
      emit(GetDepositReportsErrorState(msg: error.response?.data?.toString()));
    });
  }

  List<Report> withdrawReports = [];

  Future<void> getWithdrawReports() async {
    emit(GetWithdrawReportsLoadingState());
    await WalletRepository().withdrawReports().then((value) {
      withdrawReports = value;
      emit(GetWithdrawReportsSuccessState(withdrawReports));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
      }
      emit(GetWithdrawReportsErrorState(msg: error.response?.data?.toString()));
    });
  }

  Future<void> withdraw() async {
    emit(WithdrawLoadingState());
    await WalletRepository()
        .withdraw(
      amount: num.tryParse(quantityController.text) ?? 0,
    )
        .then((value) {
      Toast.showMsg(msg: value);
      clearControllers();
      // Refresh transactions after successful withdrawal
      getTransactions(refresh: true);
      emit(WithdrawSuccessState(value));
    }).catchError((error) {
      if (error is DioException) {
        Toast.showError(
            msg: error.response?.data?.toString() ?? 'Error on Make Withdraw');
        debugPrint(error.response?.data?.toString());
      }
      emit(WithdrawErrorState(msg: error.response?.data?.toString()));
      throw error;
    });
  }

  Future<void> deposit() async {
    emit(DepositLoadingState());
    await WalletRepository()
        .deposit(
      amount: num.tryParse(quantityController.text) ?? 0,
    )
        .then((value) {
      Toast.showMsg(msg: value);
      clearControllers();
      // Refresh transactions after successful deposit
      getTransactions(refresh: true);
      emit(DepositSuccessState(value));
    }).catchError((error) {
      if (error is DioException) {
        Toast.showError(
            msg: error.response?.data?.toString() ?? 'Error on Make Deposit');
        debugPrint(error.response?.data?.toString());
      }
      emit(DepositErrorState(msg: error.response?.data?.toString()));
      throw error;
    });
  }
}