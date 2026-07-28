import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:official_gold/view_model/data/network/repos/trades_repository.dart';
import '../../../model/commission_rate_model.dart';
import '../../../model/trade_order_group.dart';
import '../../utils/common_method.dart';
part 'trades_state.dart';

class TradesCubit extends Cubit<TradesState> {
   TradesCubit() : super(TradesInitial());

  static TradesCubit get(context) => BlocProvider.of<TradesCubit>(context);

  final Set<String> _expandedGroupKeys = {};
  bool isGroupExpanded(String key) => _expandedGroupKeys.contains(key);

  void toggleGroup(String key) {
    if (_expandedGroupKeys.contains(key)) {
      _expandedGroupKeys.remove(key);
    } else {
      _expandedGroupKeys.add(key);
    }
    emit(TradesExpandedChanged(Set<String>.from(_expandedGroupKeys)));
  }

  /////////////////////////////////////////////////////////////////////////////////
  // open order list
  final Set<String> _expandedOrderGroupKeys = {};
  bool isOrderGroupExpanded(String key) =>
      _expandedOrderGroupKeys.contains(key);

  void toggleOrderGroup(String key) {
    if (_expandedOrderGroupKeys.contains(key)) {
      _expandedOrderGroupKeys.remove(key);
    } else {
      _expandedOrderGroupKeys.add(key);
    }
    emit(TradesExpandedChanged(Set<String>.from(_expandedOrderGroupKeys)));
  }

  ////////////////////////////////////////////////////////// ///// //////// get Tradess
  // trades list
  List<GroupOfTradesOrOrders> groupOfTradesOrOrders = [];
  bool isTradesRefreshing = false;

  Future<void> getTradess({bool showShimmer = true}) async {
    if (showShimmer) {
      emit(GetTradesLoadingState());
    } else {
      isTradesRefreshing = true;
      emit(TradesRefreshingState());
    }

    try {
      final res = await TradesRepository().tradess();
      groupOfTradesOrOrders = res.groupOfTradesOrOrders ?? [];








      isTradesRefreshing = false;
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> get trades");
      emit(GetTradesSuccessState());
    } on DioException catch (error) {
      isTradesRefreshing = false;
      debugPrint('Error: ${error.response?.data}');
      emit(GetTradesErrorState());
    } catch (error) {
      isTradesRefreshing = false;
      debugPrint('Error: $error');
      emit(GetTradesErrorState());
    }
  }

  ///////////////////////////////////////////////////////////////////////////////// get Orderss
  // orders list
  List<GroupOfTradesOrOrders> wholeOrders = [];
  bool isOrdersRefreshing = false;

  Future<void> getOrderss({bool showShimmer = true}) async {
    print(
        "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ooooooooooooooooooooooooooooooo");
    if (showShimmer) {
      emit(GetOrdersLoadingState());
    } else {
      isOrdersRefreshing = true;
      emit(OrdersRefreshingState());
    }

    try {
      final res = await TradesRepository().orderss();
      wholeOrders = res.groupOfTradesOrOrders ?? [];
      isOrdersRefreshing = false;
      emit(GetOrdersSuccessState());
    } on DioException catch (error) {
      isOrdersRefreshing = false;
      debugPrint('Error: ${error.response?.data}');
      emit(GetOrdersErrorState());
    } catch (error) {
      isOrdersRefreshing = false;
      debugPrint('Error: $error');
      emit(GetOrdersErrorState());
    }
  }

  ///////////////////////////////////////////////////////////////////////////////// close Trade
  // close trade
  Future<void> closeTrade({required orderId, required closePrice}) async {
    print("orderId : $orderId, closePrice: $closePrice");

    emit(CloseTradeLoadingState());
    await TradesRepository()
        .closeTrade(orderId: orderId, closePrice: closePrice)
        .then((value) async {
      emit(CloseTradeSuccessState());
      // ✅ بعد العملية: اعمل get مع shimmer
      await getTradess(showShimmer: false);
    }).catchError((error) {
      if (error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      } else {
        debugPrint('Error: $error');
      }
      emit(CloseTradeErrorState());
    });
  }

  ///////////////////////////////////////////////////////////////////////////////// closeOrder
  // close order (delete pending)
  Future<void> closeOrder({required orderId}) async {
    emit(CloseOrderLoadingState());
    await TradesRepository().closeOrder(orderId: orderId).then((value) async {
      emit(CloseOrderSuccessState());
      // ✅ بعد العملية: اعمل get مع shimmer
      await getOrderss(showShimmer: false);
    }).catchError((error) {
      if (error is DioException) {
        debugPrint('Error: ${error.response?.data}');
      } else {
        debugPrint('Error: $error');
      }
      emit(CloseOrderErrorState());
    });
  }

  ///////////////////////////////////////////////////////////////////////////////// get Commission Rate
  CommissionRateResult? commissionResult;
  num? commissionRate; // الرقم نفسه (0.1)
  Future<void> getCommissionRate() async {
    emit(GetCommissionRateLoadingState());
    try {
      final res = await TradesRepository().getCommissionRate();
      // خزّن الريسبونس كامل
      commissionResult = res.result;
      // خزّن الرقم لوحده
      commissionRate = res.result?.commissionRate;

      emit(GetCommissionRateSuccessState());
    } on DioException catch (error) {
      debugPrint('Commission Rate Error: ${error.response?.data}');
      emit(
        GetCommissionRateErrorState(
          msg: error.response?.data?['message']?.toString(),
        ),
      );
    } catch (error) {
      debugPrint('Commission Rate Error: $error');
      emit(GetCommissionRateErrorState(msg: error.toString()));
    }
  }

//////////////////////////////////////////////////////////////////////////////////////////////// calculate Commission
  num calculateCommission(num amount) {
    final rate = commissionRate ?? 0;
    final result = (amount * rate) / 100;

    // 🔴 طباعة تفاصيل المعادلة في الـ Console لسهولة المتابعة
    debugPrint('🧮 [Commission Calculation]:');
    debugPrint('   🔹 Trade Amount (حجم الصفقة): $amount');
    debugPrint('   🔹 Commission Rate (نسبة العمولة): $rate%');
    debugPrint('   🔹 Equation: ($amount * $rate) / 100');
    debugPrint('   🔹 Result (العمولة الناتجة): $result');
    debugPrint('----------------------------------------------');

    return result;
  }

//////////////////////////////////////////////////////////////////////////////////////////////// calculate Total  and single Pnl

// متغيرات الكاش لمنع التكرار اللانهائي في التجميع والطباعة
  num _lastUsdPrice = 0.0;
  num _lastEgpPrice = 0.0;

  Map<String, num> totalPnlOfEachGroupMap = {};
  num totalUsdPnl = 0.0;
  num totalEgpPnl = 0.0;

  Map<int, Map<String, dynamic>> cachedSingleTrades = {};
  Map<String, num> lastSingleCurrencyPrices = {'USD': 0.0, 'EGP': 0.0};






// ✅ استبدلنا cachedSingleTrades بالخريطتين دول عشان يكونوا أسهل في القراءة في الـ UI
  Map<int, num> singleTradePnlMap = {};
  Map<int, num> singleTradeLivePriceMap = {};
// ده بتحيب اجمالي المكسب والخساره واجمالي لكل الثفقت و لكل ثفقه لوحدها
  void calculateTotalAndSinglePnl({
    required num liveUsdPrice,
    required num liveEgpPrice,
  })
  {
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>. Enter calculation method");

    // 1️⃣ حماية أولى: لا تحسب قبل تحميل الصفقات الفعالة لمنع تثبيت كاش الصفر
    if (groupOfTradesOrOrders.isEmpty) {
      print(">>>>>>>>>>>> No Trades Loaded Yet");
      totalUsdPnl = 0.0;
      totalEgpPnl = 0.0;
      _lastUsdPrice = 0.0;
      _lastEgpPrice = 0.0;
      totalPnlOfEachGroupMap.clear();
      singleTradePnlMap.clear();       // ✅ تنظيف السنجل كاش
      singleTradeLivePriceMap.clear(); // ✅ تنظيف السنجل كاش
      return;
    }

    // 2️⃣ حماية ثانية: انتظر حتى يصل السعران اللحظيان الحقيقيان من السوكت
    if (liveUsdPrice <= 0 || liveEgpPrice <= 0) {
      totalUsdPnl = 0;
      totalEgpPnl = 0;
      print(">>>>>>>>>> first enter (Zero Live Price) >>>>>>>>>>>>>>>>. cachedEgpTotal : $totalEgpPnl  cachedUsdTotal : $totalUsdPnl");
      return;
    }

    // 3️⃣ حماية ثالثة: نعتمد الخروج السريع بالكاش المخزن فقط إذا كان يحتوي على قيم فعلية محسوبة سابقاً وليس أصفاراً
    if (_lastUsdPrice == liveUsdPrice &&
        _lastEgpPrice == liveEgpPrice &&
        totalPnlOfEachGroupMap.isNotEmpty) {
      if (totalUsdPnl != 0.0 || totalEgpPnl != 0.0) {
        print(">>>>>>>>>>>> return without calculation -> returning cached values >>>>>>>>>>>>>>. cachedEgpTotal : $totalEgpPnl  cachedUsdTotal : $totalUsdPnl");
        return;
      }
    }

    print(">>>>>>>>>>>>>>>>>>>>>>>>>>. Enter calculation method and upgrade price cachedEgpTotal : $totalEgpPnl  cachedUsdTotal : $totalUsdPnl");

    _lastUsdPrice = liveUsdPrice;
    _lastEgpPrice = liveEgpPrice;

    num usdTotal = 0;
    num egpTotal = 0;

    final Map<String, num> localGroupsPnl = {};
    final Map<int, num> localSinglePnl = {};       // ✅ متغير محلي مؤقت للسنجل
    final Map<int, num> localSingleLivePrice = {}; // ✅ متغير محلي مؤقت للسنجل

    for (final group in groupOfTradesOrOrders) {
      final groupKey = '${group.metal}_${group.currency}';
      final currency = (group.currency ?? '').toUpperCase();

      final livePrice = currency == 'USD' ? liveUsdPrice : liveEgpPrice;
      num groupTotal = 0;
      final trades = group.tradesOrOrders ?? [];

      for (final trade in trades) {
        final pnl = Methods.calculatePnl(
          livePrice: livePrice,
          weight: trade.unitGramWeight ?? 0,
          openPrice: trade.openPrice!,
          quantity: trade.quantity ?? 1,
          log: false, // تم جعلها false لتقليل التكرار غير المفيد في الـ Console
        );

        groupTotal += pnl;

        // ✅ [تمت الإضافة هنا] تخزين حسابات كل صفقة لوحدها بناءً على الـ ID
        final int tradeId = trade.id ?? 0;
        localSinglePnl[tradeId] = pnl;
        localSingleLivePrice[tradeId] = livePrice;

        if (currency == 'USD') {
          usdTotal += pnl;
        } else {
          egpTotal += pnl;
        }
      }

      localGroupsPnl[groupKey] = groupTotal;
    }

    // ✅ تحديث المتغيرات العامة مرة واحدة بعد انتهاء الحسابات
    totalPnlOfEachGroupMap = localGroupsPnl;
    singleTradePnlMap = localSinglePnl;             // ✅ حفظ السنجل
    singleTradeLivePriceMap = localSingleLivePrice; // ✅ حفظ السنجل
    totalUsdPnl = usdTotal;
    totalEgpPnl = egpTotal;




    for (final group in groupOfTradesOrOrders) {
      final groupKey = '${group.metal}_${group.currency}';
      final groupTotal = totalPnlOfEachGroupMap[groupKey] ?? 0.0;

      // طباعة رأس المجموعة (الجروب الأب)
      debugPrint('📦 Card Group [$groupKey] Total PNL => $groupTotal');

      final trades = group.tradesOrOrders ?? [];
      for (final trade in trades) {
        final int tradeId = trade.id ?? 0;
        final num tradePnl = singleTradePnlMap[tradeId] ?? 0.0;
        final num tradeLivePrice = singleTradeLivePriceMap[tradeId] ?? 0.0;

        // طباعة تفاصيل كل صفقة تابعة للمجموعة (الابن)
        debugPrint('   └── 🔹 Single Trade ID [$tradeId] | Weight: ${trade.unitGramWeight}g | Qty: ${trade.quantity} | LivePrice: $tradeLivePrice | PNL => $tradePnl');
      }
      debugPrint('------------------------------------------------------------------');
    }















    // ✅ البرنتات بتاعتك كلها محفوظة زي ما هي
    debugPrint('================ 📊 TradesCubit Live Calculation ================');
    debugPrint('📈 Live Prices  => USD: $liveUsdPrice | EGP: $liveEgpPrice');
    debugPrint('------------------------------------------------------------------');

    totalPnlOfEachGroupMap.forEach((key, value) {
      debugPrint('📦 Card Group [$key] PNL => $value');
    });

    debugPrint('------------------------------------------------------------------');
    debugPrint('🇺🇸 USD Total PNL => $totalUsdPnl');
    debugPrint('🇪🇬 EGP Total PNL => $totalEgpPnl');
    debugPrint('==================================================================');
  }








/////////////////////////////////////////////////////////////////////////////////
  // 📌 ميثود تصفير البيانات والكاش بالكامل (Clean Reset)
  void clearCubitData() {
    // 1. تصفير بيانات التوتال (Total PNL)
    totalUsdPnl = 0.0;
    totalEgpPnl = 0.0;
    _lastUsdPrice = 0.0;
    _lastEgpPrice = 0.0;
    totalPnlOfEachGroupMap.clear();

    // 2. تصفير كاش الصفقات الفردية (Single Trades Cache)
    cachedSingleTrades.clear();
    lastSingleCurrencyPrices = {'USD': 0.0, 'EGP': 0.0};

    // 3. تصفير أي متغيرات متعلقة بالصفقات/الأوامر إذا لزم الأمر
    // groupOfTradesOrOrders.clear();
    // wholeOrders.clear();

    debugPrint('🧹 TradesCubit: All caches and variables have been cleared.');

    // إشعار الـ UI بأن البيانات تغيرت (اختياري حسب احتياجك)
    emit(TradesInitial());
  }
}
