import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/wallet_repository.dart';
import 'package:official_gold/view_model/utils/app_constant.dart';
import '../../../model/report_2.dart';
import '../../../model/trade_order_model.dart';
import '../../../model/transaction_model.dart';
import '../../../model/metal_price_model.dart';
import '../../utils/common_method.dart';
import '../../utils/toast.dart';
import '../live_price_cubit/live_cubit.dart';
import '../live_price_cubit/live_states.dart';
part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(WalletInitial());
  static WalletCubit get(context) => BlocProvider.of<WalletCubit>(context);
  //
  // final LivePriceCubit livePriceCubit;
  // StreamSubscription? _livePriceSubscription;
  //
  // WalletCubit({
  //   required this.livePriceCubit,
  // }) : super(WalletInitial()) {
  //   _livePriceSubscription = livePriceCubit.stream.listen((state) {
  //     if (state is LivePriceLive) {
  //       calculateTotals(
  //         liveUsdPrice: state.metals['USD']?.buy ?? 0,
  //         liveEgpPrice: state.metals['EGP']?.buy ?? 0,
  //       );
  //     }
  //   });
  // }
  //
  // @override
  // Future<void> close() {
  //   _livePriceSubscription?.cancel();
  //   return super.close();
  // }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
      emit(DepositErrorState(msg: error.response?.data?.toString()));
      throw error;
    });
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// get trades
  List<TradeOrOrder> usdTrades = [];
  List<TradeOrOrder> egpTrades = [];

  Future<void> getTradess2() async {
    emit(GetTradesLoadingState2());

    try {
      final result = await WalletRepository().tradess();

      usdTrades = result['usd_trades'] ?? [];
      egpTrades = result['egp_trades'] ?? [];

      cachedUsdTotal = 0.0;
      cachedEgpTotal = 0.0;
      // بمجرد جلب البيانات، يفضل استدعاء الحساب فوراً لتحديث الواجهة بناءً على آخر أسعار مخزنة
      emit(GetTradesSuccessState2());
    } catch (e) {
      debugPrint(e.toString());
      emit(GetTradesErrorState2());
    }
  }

  num cachedUsdTotal = 0;
  num cachedEgpTotal = 0;

  final Map<int, _WalletCacheEntry> _walletSingleTradesPnl = {};
  final Map<String, double> _lastWalletPrices = {};

  Map<String, dynamic> calculateTotals({
    required Map<String, Map<String, MetalPrices>> livePrices,
  }) {
    // 1️⃣ حماية أولى: إذا لم تصل الصفقات بعد من الـ API، اخرج فوراً ولا تخزن كاش صفر
    if (usdTrades.isEmpty && egpTrades.isEmpty) {
      debugPrint(">>>>>>>>> WalletCubit: No Trades Data Loaded Yet >>>>>>>>>>");
      cachedUsdTotal = 0.0;
      cachedEgpTotal = 0.0;
      return {'usdTotal': 0.0, 'egpTotal': 0.0};
    }

    double usdTotal = 0.0;
    double egpTotal = 0.0;

    // 2️⃣ حساب صفقات الـ USD بأمان تام
    for (final trade in usdTrades) {
      final int tradeId = trade.id ?? 0;
      final String metal = (trade.metal ?? 'XAU').toUpperCase();
      final double liveUsdPrice = (livePrices[metal]?['USD']?.buy ?? 0).toDouble();

      final String priceKey = '${metal}_USD';
      final double lastPrice = _lastWalletPrices[priceKey] ?? -1.0;

      final double openPrice = (trade.openPrice ?? 0).toDouble();
      final double unitGramWeight = (trade.unitGramWeight ?? 0).toDouble();
      final double quantity = (trade.quantity ?? 1).toDouble();
      final String currency = (trade.currency ?? 'USD').toUpperCase();

      final cachedEntry = _walletSingleTradesPnl[tradeId];
      final bool tradeChanged = cachedEntry == null ||
          cachedEntry.openPrice != openPrice ||
          cachedEntry.unitGramWeight != unitGramWeight ||
          cachedEntry.quantity != quantity ||
          cachedEntry.metal != metal ||
          cachedEntry.currency != currency;

      if (liveUsdPrice > 0) {
        if (liveUsdPrice != lastPrice || tradeChanged) {
          final double pnl = Methods.calculatePnl(
            livePrice: liveUsdPrice,
            weight: unitGramWeight,
            openPrice: openPrice,
            quantity: quantity,
            log: false,
          ).toDouble();
          _walletSingleTradesPnl[tradeId] = _WalletCacheEntry(
            pnl: pnl,
            openPrice: openPrice,
            unitGramWeight: unitGramWeight,
            quantity: quantity,
            metal: metal,
            currency: currency,
          );
        }
      } else {
        if (cachedEntry == null) {
          _walletSingleTradesPnl[tradeId] = _WalletCacheEntry(
            pnl: 0.0,
            openPrice: openPrice,
            unitGramWeight: unitGramWeight,
            quantity: quantity,
            metal: metal,
            currency: currency,
          );
        }
      }

      usdTotal += _walletSingleTradesPnl[tradeId]!.pnl;
    }

    // 3️⃣ حساب صفقات الـ EGP بأمان تام
    for (final trade in egpTrades) {
      final int tradeId = trade.id ?? 0;
      final String metal = (trade.metal ?? 'XAU').toUpperCase();
      final double liveEgpPrice = (livePrices[metal]?['EGP']?.buy ?? 0).toDouble();

      final String priceKey = '${metal}_EGP';
      final double lastPrice = _lastWalletPrices[priceKey] ?? -1.0;

      final double openPrice = (trade.openPrice ?? 0).toDouble();
      final double unitGramWeight = (trade.unitGramWeight ?? 0).toDouble();
      final double quantity = (trade.quantity ?? 1).toDouble();
      final String currency = (trade.currency ?? 'EGP').toUpperCase();

      final cachedEntry = _walletSingleTradesPnl[tradeId];
      final bool tradeChanged = cachedEntry == null ||
          cachedEntry.openPrice != openPrice ||
          cachedEntry.unitGramWeight != unitGramWeight ||
          cachedEntry.quantity != quantity ||
          cachedEntry.metal != metal ||
          cachedEntry.currency != currency;

      if (liveEgpPrice > 0) {
        if (liveEgpPrice != lastPrice || tradeChanged) {
          final double pnl = Methods.calculatePnl(
            livePrice: liveEgpPrice,
            weight: unitGramWeight,
            openPrice: openPrice,
            quantity: quantity,
            log: false,
          ).toDouble();
          _walletSingleTradesPnl[tradeId] = _WalletCacheEntry(
            pnl: pnl,
            openPrice: openPrice,
            unitGramWeight: unitGramWeight,
            quantity: quantity,
            metal: metal,
            currency: currency,
          );
        }
      } else {
        if (cachedEntry == null) {
          _walletSingleTradesPnl[tradeId] = _WalletCacheEntry(
            pnl: 0.0,
            openPrice: openPrice,
            unitGramWeight: unitGramWeight,
            quantity: quantity,
            metal: metal,
            currency: currency,
          );
        }
      }

      egpTotal += _walletSingleTradesPnl[tradeId]!.pnl;
    }

    // 4️⃣ تحديث أسعار المقارنة المخزنة للأسعار التي كانت صالحة ومتاحة (> 0)
    for (final metal in ['XAU', 'XAG']) {
      for (final currency in ['USD', 'EGP']) {
        final double buyPrice = (livePrices[metal]?[currency]?.buy ?? 0).toDouble();
        if (buyPrice > 0) {
          _lastWalletPrices['${metal}_$currency'] = buyPrice;
        }
      }
    }

    cachedUsdTotal = usdTotal;
    cachedEgpTotal = egpTotal;

    debugPrint('================ 📊 Wallet PNL Live Calculation ================');
    debugPrint('USD Total pnl => $usdTotal');
    debugPrint('EGP Total pnl => $egpTotal');
    debugPrint('================================================================');

    return {
      'usdTotal': usdTotal,
      'egpTotal': egpTotal,
    };
  }

//////////////////////////////////////////////////////////////////////////////////////////
  // 1️⃣ أضف دالة لتصفير الكاش والبيانات عند تغيير الحساب أو تسجيل الخروج
  void resetWalletData() {
    transactionModel = null;
    allTransactions.clear();
    isLoadingMoreTransactions = false;
    hasMoreTransactions = true;
    currentTransactionPage = 1;
    walletDollar = 0;
    walletEgp = 0;
    usdTrades.clear();
    egpTrades.clear();
    _walletSingleTradesPnl.clear();
    _lastWalletPrices.clear();
    cachedUsdTotal = 0;
    cachedEgpTotal = 0;

    emit(WalletInitial()); // إعادة Cubit للحالة البدئية
  }
}

class _WalletCacheEntry {
  final double pnl;
  final double openPrice;
  final double unitGramWeight;
  final double quantity;
  final String metal;
  final String currency;

  _WalletCacheEntry({
    required this.pnl,
    required this.openPrice,
    required this.unitGramWeight,
    required this.quantity,
    required this.metal,
    required this.currency,
  });
}
