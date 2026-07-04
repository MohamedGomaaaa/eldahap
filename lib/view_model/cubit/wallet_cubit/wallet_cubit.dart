import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/wallet_repository.dart';
import 'package:official_gold/view_model/utils/app_constant.dart';
import '../../../model/report_2.dart';
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
  List<num> egpTradesWeights = []; // دي اللي بنخزن فيها الأوزان حالياً
  List<num> usdTradesWeights = [];

  Future<void> getTradess() async {
    emit(GetTradesLoadingState());

    try {
      final result = await WalletRepository().tradess();

      // استقبال الأسعار والأوزان بشكل منفصل وصحيح
      usdTradesPrices = result['usd_prices'] ?? [];
      usdTradesWeights = result['usd_weights'] ?? [];

      egpTradesPrices = result['egp_prices'] ?? [];
      egpTradesWeights = result['egp_weights'] ?? [];

      debugPrint(
          'USD Prices => $usdTradesPrices | USD Weights => $usdTradesWeights');
      debugPrint(
          'EGP Prices => $egpTradesPrices | EGP Weights => $egpTradesWeights');

      emit(GetTradesSuccessState());
    } catch (e) {
      debugPrint(e.toString());
      emit(GetTradesErrorState());
    }
  }

//////////////////////////////////////////////////////
// 📌 قم بتعريف هذه المتغيرات داخل الكلاس الخاص بك (قبل الميثود)
  num? lastCalculatedUsdPrice;
  num? lastCalculatedEgpPrice;

  num cachedUsdTotal = 0;
  num cachedEgpTotal = 0;

// 📌 الميثود بعد التعديل
  Map<String, num> calculateTotals({
    required num liveUsdPrice,
    required num liveEgpPrice,
  }) {
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>. Enter calculation method");
    // 1️⃣ التحقق إذا كان السعر متطابقاً مع آخر سعر تم حسابه (أي لم يتغير)
    if (liveUsdPrice == lastCalculatedUsdPrice &&
        liveEgpPrice == lastCalculatedEgpPrice) {
      // السعر لم يتغير، سنقوم بإرجاع القيم المحسوبة مسبقاً فوراً
      // لنوفر موارد الجهاز ولن يتم تنفيذ الطباعة (Log)
      return {
        'usdTotal': cachedUsdTotal,
        'egpTotal': cachedEgpTotal,
      };
    }
    print(
        ">>>>>>>>>>>>>>>>>>>>>>>>>>. Enter calculation method and upgrade price");
    // 2️⃣ تحديث الأسعار المحفوظة بالأسعار الجديدة لضمان عدم تكرار الحساب المرة القادمة
    lastCalculatedUsdPrice = liveUsdPrice;
    lastCalculatedEgpPrice = liveEgpPrice;

    num usdTotal = 0;
    num egpTotal = 0;

    // 3️⃣ حساب الـ PNL للدولار (كل لستة مع الوزن بتاعها)
    for (int i = 0; i < usdTradesPrices.length; i++) {
      final weight = i < usdTradesWeights.length ? usdTradesWeights[i] : 0;
      usdTotal += (liveUsdPrice * weight) - usdTradesPrices[i];
    }

    // 4️⃣ حساب الـ PNL للمصري (كل لستة مع الوزن بتاعها)
    for (int i = 0; i < egpTradesPrices.length; i++) {
      final weight = i < egpTradesWeights.length ? egpTradesWeights[i] : 0;
      egpTotal += (liveEgpPrice * weight) - egpTradesPrices[i];
    }

    // 5️⃣ حفظ نتائج إجمالي PNL الجديد لتجنب إعادة الحساب مستقبلاً لو ثبت السعر
    cachedUsdTotal = usdTotal;
    cachedEgpTotal = egpTotal;

    // 6️⃣ الطباعة (ستحدث هنا فقط إذا كان هناك تغيير حقيقي في السعر)
    debugPrint('================ PNL Live Calculation ================');
    debugPrint('USD Total pnl => $usdTotal');
    debugPrint('EGP Total pnl => $egpTotal');
    debugPrint('live USD  => $liveUsdPrice');
    debugPrint('live EGP  => $liveEgpPrice');
    debugPrint('======================================================');

    return {
      'usdTotal': usdTotal,
      'egpTotal': egpTotal,
    };
  }
}
