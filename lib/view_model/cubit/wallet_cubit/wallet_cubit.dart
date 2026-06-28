import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/wallet_repository.dart';
import 'package:official_gold/view_model/utils/app_constant.dart';

import '../../../model/report_1.dart';
import '../../../model/report_2.dart';
import '../../../model/trade_order_group.dart';
import '../../../model/trade_order_model.dart';
import '../../models/wallet_models/transaction_model.dart';
import '../../utils/toast.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());

  static WalletCubit get(context) => BlocProvider.of<WalletCubit>(context);

  TransactionModel? transactionModel;
  List<TransactionData> allTransactions = []; // Store all transactions
  bool isLoadingMoreTransactions = false;
  bool hasMoreTransactions = true;
  int currentTransactionPage = 1;

  num walletDollar = 0;
  num walletEgp = 0;
  bool isWalletLoading = false;

  Future<void> getWallet() async {
    isWalletLoading = true;
    emit(GetWalletLoadingState());

    try {
      final value = await WalletRepository().wallet();
      print(">>>>>>>>>>>>>>>> Wallet value: $value");
      walletDollar = (value.balanceDollar ?? 0);
      walletEgp = (value.balanceEgp ?? 0);
      isWalletLoading = false;
      emit(GetWalletSuccessState(walletDollar, walletEgp));
    } catch (error) {
      if (error is DioException) {
        isWalletLoading = false;
        debugPrint(error.response?.data?.toString());
        emit(GetWalletErrorState(msg: error.response?.data?.toString()));
      } else {
        isWalletLoading = false;
        debugPrint("Unexpected error: $error");
        emit(GetWalletErrorState(msg: error.toString()));
      }
    }
  }

  Future<void> convertCurrency({
    required num amount,
  }) async {
    emit(ConvertCurrencyLoadingState());

    try {
      final result = await WalletRepository().convertCurrency(
        amount: amount,
      );

      // تحديث القيم مباشرة
      walletDollar = (result.balanceUsd ?? 0).toDouble();
      walletEgp = (result.balanceEgp ?? 0).toDouble();

      emit(ConvertCurrencySuccessState(
        result.convertedAmount ?? 0,
        walletDollar,
        walletEgp,
      ));

      // 🔥 مهم: تحديث الصفحة بالكامل
      await getWallet();
    } catch (error) {
      if (error is DioException) {
        emit(ConvertCurrencyErrorState(
          msg: error.response?.data?['message'] ?? "Error",
        ));
      } else {
        emit(ConvertCurrencyErrorState(msg: error.toString()));
      }
    }
  }

//////////////////////////////////////////////////////////////// setting
//   num exchangeDollarRate = 0;
//   Future<void> getExchangeRate() async {
//     emit(GetExchangeRateLoadingState());
//
//     try {
//       final value = await WalletRepository().getExchangeRate();
//
//       var exchangeDollarRate =
//           value.exchangeDollarRate ?? AppConstant.dollarConstant;
//
//       emit(GetExchangeRateSuccessState(exchangeDollarRate));
//     } catch (error) {
//       if (error is DioException) {
//         debugPrint(error.response?.data?.toString());
//         emit(GetExchangeRateErrorState(
//           msg: error.response?.data?['message'] ?? "Error",
//         ));
//       } else {
//         debugPrint("Unexpected error: $error");
//         emit(GetExchangeRateErrorState(
//           msg: error.toString(),
//         ));
//       }
//     }
//   }

  num exchangeDollarRate = 0;
  num depositUsdAmount = 0;
  num depositEgpAmount = 0;

  Future<void> getExchangeRate() async {
    emit(GetExchangeRateLoadingState());

    try {
      final value = await WalletRepository().getExchangeRate();

      exchangeDollarRate =
          value.exchangeDollarRate ?? AppConstant.dollarConstant;

      emit(GetExchangeRateSuccessState(exchangeDollarRate));
    } catch (error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        emit(GetExchangeRateErrorState(
          msg: error.response?.data?['message'] ?? "Error",
        ));
      } else {
        debugPrint("Unexpected error: $error");
        emit(GetExchangeRateErrorState(
          msg: error.toString(),
        ));
      }
    }
  }

  void calculateDepositInEgp(String value) {
    final amount = num.tryParse(value.trim()) ?? 0;

    depositUsdAmount = amount;
    depositEgpAmount = amount * exchangeDollarRate;

    emit(CalculateDepositAmountState(
      depositUsdAmount: depositUsdAmount,
      depositEgpAmount: depositEgpAmount,
    ));
  }

//////////////////////////////////////////////////// calculate DepositIn Egp

/////////////////////////////////////////////////// old wallet gomaa
//   Future<void> getWallet() async {
//     emit(GetWalletLoadingState());
//
//     await WalletRepository().wallet().then((value) {
//       print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  Wallet value: $value");
//
//       wallet = double.parse(value.toStringAsFixed(2));
//
//       emit(GetWalletSuccessState(wallet));
//     }).catchError((error) {
//       if (error is DioException) {
//         debugPrint(error.response?.data?.toString());
//         emit(GetWalletErrorState(msg: error.response?.data?.toString()));
//       } else {
//         debugPrint("Unexpected error: $error");
//         emit(GetWalletErrorState(msg: error.toString()));
//       }
//     });
//   }
//////////////////////////////////////////////////

  // Future<void> getWallet() async {
  //   emit(GetWalletLoadingState());
  //   await WalletRepository().wallet().then((value) {
  //     print("Wallet value: $value");
  //     wallet = double.parse("${value.toStringAsFixed(2)}");
  //     emit(GetWalletSuccessState(wallet));
  //   }).catchError((error) {
  //     if (error is DioException) {
  //       debugPrint(error.response?.data?.toString());
  //       emit(GetWalletErrorState(msg: error.response?.data?.toString()));
  //     } else {
  //       debugPrint("Unexpected error: $error");
  //       emit(GetWalletErrorState(msg: error.toString()));
  //     }
  //   });
  // }

  // Get initial transactions (first page)
  Future<void> getTransactions({bool refresh = false}) async {
    if (refresh) {
      currentTransactionPage = 1;
      allTransactions.clear();
      hasMoreTransactions = true;
    }

    emit(GetTransactionLoadingState());
    await WalletRepository()
        .transactions(page: currentTransactionPage)
        .then((value) {
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

    await WalletRepository()
        .transactions(page: currentTransactionPage)
        .then((value) {
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
        emit(LoadMoreTransactionsErrorState(
            msg: error.response?.data?.toString()));
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

///////////////////////////////////////////////////////////////////////////////////// old
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////  deposit Reports
//   List<Report> depositReports = [];
//
//   Future<void> getDepositReports() async {
//     emit(GetDepositReportsLoadingState());
//     await WalletRepository().depositReports().then((value) {
//       depositReports = value;
//       emit(GetDepositReportsSuccessState(depositReports));
//     }).catchError((error) {
//       if (error is DioException) {
//         debugPrint(error.response?.data?.toString());
//       }
//       emit(GetDepositReportsErrorState(msg: error.response?.data?.toString()));
//     });
//   }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////  withdraw Reports
//   List<Report> withdrawReports = [];
//
//   Future<void> getWithdrawReports() async {
//     emit(GetWithdrawReportsLoadingState());
//     await WalletRepository().withdrawReports().then((value) {
//       withdrawReports = value;
//       emit(GetWithdrawReportsSuccessState(withdrawReports));
//     }).catchError((error) {
//       if (error is DioException) {
//         debugPrint(error.response?.data?.toString());
//       }
//       emit(GetWithdrawReportsErrorState(msg: error.response?.data?.toString()));
//     });
//   }
//////////////////////////////////////////////////////////////////////////////////////////

  List<ReportResult2> reportsList = [];

  Future<void> getReports({required String type}) async {
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>> type : $type ");
    emit(GetReportsLoadingState());
    await WalletRepository().reports(type: type).then((value) {
      reportsList = value;
      emit(GetReportsSuccessState(reportsList));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        emit(
          GetReportsErrorState(
            msg: error.response?.data?.toString() ?? 'Something went wrong',
          ),
        );
      } else {
        emit(GetReportsErrorState(msg: error.toString()));
      }
    });
  }

  List<TradeOrOrder> orderReportsList = [];

  Future<void> getOrderReports({required String type}) async {
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>> type : $type ");
    emit(GetOrderReportsLoadingState());

    await WalletRepository().getOrderReports(type: type).then((value) {
      orderReportsList = value;
      emit(GetOrderReportsSuccessState(orderReportsList));
    }).catchError((error) {
      if (error is DioException) {
        debugPrint(error.response?.data?.toString());
        emit(
          GetOrderReportsErrorState(
            msg: error.response?.data?.toString() ?? 'Something went wrong',
          ),
        );
      } else {
        emit(GetOrderReportsErrorState(msg: error.toString()));
      }
    });
  }

// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////  withdraw in wallets

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

// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////  deposit in wallets
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// get trades
  List<num> usdTradesPrices = [];
  List<num> egpTradesPrices = [];

  Future<void> getTradess() async {
    emit(GetTradesLoadingState());

    try {
      final result = await WalletRepository().tradess();

      usdTradesPrices = result['usd'] ?? [];
      egpTradesPrices = result['egp'] ?? [];

      debugPrint('USD => $usdTradesPrices');
      debugPrint('EGP => $egpTradesPrices');

      emit(GetTradesSuccessState());
    } catch (e) {
      debugPrint(e.toString());
      emit(GetTradesErrorState());
    }
  }
//////////////////////////////////////////////////////
  Map<String, num> calculateTotals({
    required num currentUsdPrice,
    required num currentEgpPrice,
  })
  {
    final usdTotal = usdTradesPrices.fold<num>(
      0,
      (sum, price) => sum + (currentUsdPrice - price),
    );

    final egpTotal = egpTradesPrices.fold<num>(
      0,
      (sum, price) => sum + (currentEgpPrice - price),
    );

    return {
      'usdTotal': usdTotal,
      'egpTotal': egpTotal,
    };
  }
////////////////////////////////////////////////////////////////
  Timer? totalsTimer;

// أضف هذه المتغيرات في الـ Cubit لتخزين الإجمالي التراكمي
  double totalPortfolioUsd = 0.0;
  double totalPortfolioEgp = 0.0;

  void startTotalsTimer({
    required num currentUsdPrice,
    required num currentEgpPrice,
  }) {
    totalsTimer?.cancel();

    totalsTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        final result = calculateTotals(
          currentUsdPrice: currentUsdPrice,
          currentEgpPrice: currentEgpPrice,
        );

        // ✅ 1. تحديث المتغيرات بالقيم الإجمالية الجديدة (تجميعة الأراي + المحفظة)
        totalPortfolioUsd = (result['usdTotal'] ?? 0.0).toDouble();
        totalPortfolioEgp = (result['egpTotal'] ?? 0.0).toDouble();

        debugPrint('USD Total: $totalPortfolioUsd');
        debugPrint('EGP Total: $totalPortfolioEgp');

        // ✅ 2. عمل emit لحالة تحديث الإجمالي لكي يستمع إليها الـ BlocBuilder
        emit(WalletTotalsUpdatedState());
      },
    );
  }






}
