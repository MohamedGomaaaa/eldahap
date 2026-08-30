import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/metal_price_model.dart';
import '../../../model/live_price_model.dart';
import '../../data/local/shared_helper.dart';
import '../../data/local/shared_keys.dart';
import '../../utils/socket.dart';
import 'live_states.dart';
import 'dart:convert';
import 'dart:async';

class LivePriceCubit extends Cubit<LivePriceState> {
  LivePriceCubit() : super(LivePriceInitial()) {
    _log('onCreate -- LivePriceCubit');
    _listenToConnectivity();
  }

  final LivePriceSocketService _socket =
      LivePriceSocketService.instance;

  bool _starting = false;

  /// true = foreground
  /// false = background/manual stop
  bool _wantRunning = false;

  Timer? _reconnectTimer;

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>?
  _connectivitySub;

  bool _hasInternet = true;

  // ============================================================
  // METALS
  // ============================================================

  final Map<String, Map<String, MetalPrices>> metals = {
    'XAU': {
      'USD': const MetalPrices(
        market: 0,
        buy: 0,
        sell: 0,
        currency: 'USD',
        timestamp: '',
      ),
      'EGP': const MetalPrices(
        market: 0,
        buy: 0,
        sell: 0,
        currency: 'EGP',
        timestamp: '',
      ),
    },
    'XAG': {
      'USD': const MetalPrices(
        market: 0,
        buy: 0,
        sell: 0,
        currency: 'USD',
        timestamp: '',
      ),
      'EGP': const MetalPrices(
        market: 0,
        buy: 0,
        sell: 0,
        currency: 'EGP',
        timestamp: '',
      ),
    },
  };

  // ============================================================
  // XAG TRACKING
  // ============================================================

  bool _receivedXAG = false;

  // ============================================================
  // CACHE
  // ============================================================

  bool _cacheLoaded = false;

  /// يوضح هل السعر المعروض حاليًا من الـ Cache
  /// أم أن آخر تحديث جاء من الـ WebSocket
  bool _usingCachedPrices = false;

  // ============================================================
  // LOG
  // ============================================================

  void _log(String message) {
    // ignore: avoid_print
    print('🟦 [LiveCubit] $message');
  }

  // ============================================================
  // LOAD CACHED PRICES
  // ============================================================

  Future<void> _loadCachedPrices() async {
    if (_cacheLoaded) {
      return;
    }

    try {
      final cachedValue =
      SharedHelper.get(SharedKeys.liveMetalsPrices);

      if (cachedValue == null) {
        _log(
          '⚪ [CACHE] No cached live prices found.',
        );

        _cacheLoaded = true;
        return;
      }

      final cachedString = cachedValue.toString();

      if (cachedString.isEmpty) {
        _log(
          '⚪ [CACHE] Cached live prices are empty.',
        );

        _cacheLoaded = true;
        return;
      }

      final decoded = jsonDecode(cachedString);

      if (decoded is! Map) {
        _log(
          '❌ [CACHE] Invalid cached live prices format.',
        );

        _cacheLoaded = true;
        return;
      }

      bool loadedAnyPrice = false;

      for (final metalEntry in decoded.entries) {
        final metal =
        metalEntry.key.toString().toUpperCase();

        if (metalEntry.value is! Map) {
          continue;
        }

        final currencies =
        metalEntry.value as Map;

        metals[metal] ??= {};

        for (final currencyEntry
        in currencies.entries) {
          final currency =
          currencyEntry.key.toString().toUpperCase();

          if (currencyEntry.value is! Map) {
            continue;
          }

          final data =
          Map<String, dynamic>.from(
            currencyEntry.value,
          );

          final market =
          _parseNum(data['market']);

          final buy =
          _parseNum(data['buy']);

          final sell =
          _parseNum(data['sell']);

          final timestamp =
              data['timestamp']?.toString() ?? '';

          // لا نحمل سعر غير صالح
          if (market <= 0 &&
              buy <= 0 &&
              sell <= 0) {
            continue;
          }

          metals[metal]![currency] =
              MetalPrices(
                market: market.toDouble(),
                buy: buy.toDouble(),
                sell: sell.toDouble(),
                currency: currency,
                timestamp: timestamp,
              );

          loadedAnyPrice = true;
        }
      }

      if (loadedAnyPrice) {
        _usingCachedPrices = true;

        _log(
          '🟡 ==================================================',
        );

        _log(
          '🟡 [PRICE SOURCE] CACHE',
        );

        _log(
          '🟡 الأسعار الحالية محملة من الـ كااااااش',
        );

        _log(
          '🟡 ==================================================',
        );

        _logCachedPrices();
      } else {
        _usingCachedPrices = false;

        _log(
          '⚪ [CACHE] Cache exists but contains no valid prices.',
        );
      }

      _cacheLoaded = true;
    } catch (e) {
      _log(
        '❌ [CACHE] Error loading cached prices: $e',
      );

      _cacheLoaded = true;
    }
  }

  // ============================================================
  // SAVE CURRENT PRICES
  // ============================================================

  Future<void> _saveCachedPrices() async {
    try {
      final Map<String, dynamic> cache = {};

      metals.forEach((metal, currencies) {
        cache[metal] = {};

        currencies.forEach(
              (currency, price) {
            cache[metal][currency] = {
              'market': price.market,
              'buy': price.buy,
              'sell': price.sell,
              'currency': price.currency,
              'timestamp': price.timestamp,
            };
          },
        );
      });

      await SharedHelper.save(
        SharedKeys.liveMetalsPrices,
        jsonEncode(cache),
      );

      _log(
        '💾 [CACHE SAVE] Live metals prices saved to cache.',
      );
    } catch (e) {
      _log(
        '❌ [CACHE SAVE] Error saving live prices: $e',
      );
    }
  }

  // ============================================================
  // LOG CACHED PRICES
  // ============================================================

  void _logCachedPrices() {
    _log(
      '🟡 [CACHE PRICE] XAU/USD => '
          'buy=${metals['XAU']?['USD']?.buy} '
          'sell=${metals['XAU']?['USD']?.sell} '
          'market=${metals['XAU']?['USD']?.market}',
    );

    _log(
      '🟡 [CACHE PRICE] XAU/EGP => '
          'buy=${metals['XAU']?['EGP']?.buy} '
          'sell=${metals['XAU']?['EGP']?.sell} '
          'market=${metals['XAU']?['EGP']?.market}',
    );

    _log(
      '🟡 [CACHE PRICE] XAG/USD => '
          'buy=${metals['XAG']?['USD']?.buy} '
          'sell=${metals['XAG']?['USD']?.sell} '
          'market=${metals['XAG']?['USD']?.market}',
    );

    _log(
      '🟡 [CACHE PRICE] XAG/EGP => '
          'buy=${metals['XAG']?['EGP']?.buy} '
          'sell=${metals['XAG']?['EGP']?.sell} '
          'market=${metals['XAG']?['EGP']?.market}',
    );
  }

  // ============================================================
  // PARSE NUMBER
  // ============================================================

  num _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }

    return num.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  // ============================================================
  // CONNECTIVITY
  // ============================================================

  void _listenToConnectivity() {
    _log(
      'Connectivity listener started ✅',
    );

    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(
              (results) {
            final nowHasInternet =
            results.any(
                  (r) =>
              r != ConnectivityResult.none,
            );

            _log(
              'Connectivity => $results '
                  'nowHasInternet=$nowHasInternet '
                  '(old=$_hasInternet) '
                  'wantRunning=$_wantRunning',
            );

            if (nowHasInternet == _hasInternet) {
              return;
            }

            _hasInternet = nowHasInternet;

            if (_hasInternet) {
              if (_wantRunning) {
                _log(
                  'Internet back ✅ -> start()',
                );

                emit(
                  LivePriceConnecting(),
                );

                start();
              } else {
                _log(
                  'Internet back but '
                      'wantRunning=false -> keep stopped',
                );

                emit(
                  LivePriceStopped(
                    message:
                    '⛔ Live price stopped',
                  ),
                );
              }
            } else {
              _log(
                'Internet lost ❌ -> stop()',
              );

              stop(
                message:
                '⛔ No internet connection',
              );
            }
          },
        );
  }

  // ============================================================
  // START
  // ============================================================

  Future<void> start() async {
    _wantRunning = true;

    _log(
      'start() called | '
          'hasInternet=$_hasInternet '
          'starting=$_starting '
          'socketConnected=${_socket.isConnected}',
    );

    if (!_hasInternet) {
      _log(
        'start blocked: no internet',
      );

      emit(
        LivePriceStopped(
          message:
          '⛔ No internet connection',
        ),
      );

      return;
    }

    // ==========================================================
    // LOAD CACHE FIRST
    // ==========================================================

    await _loadCachedPrices();

    // ==========================================================
    // SOCKET ALREADY CONNECTED
    // ==========================================================

    if (_socket.isConnected) {
      _log(
        '🟢 [PRICE SOURCE] LIVE SOCKET '
            '→ Socket already connected.',
      );

      emit(
        LivePriceLive(
          message:
          '✅ السعر لايف شغال',
          metals: metals.map(
                (key, value) =>
                MapEntry(
                  key,
                  Map<String, MetalPrices>.from(
                    value,
                  ),
                ),
          ),
          lastTick: null,
        ),
      );

      return;
    }

    if (_starting) {
      _log(
        'start skipped: already starting',
      );

      return;
    }

    _starting = true;

    // ==========================================================
    // SHOW CACHE IMMEDIATELY
    // ==========================================================

    final hasCachedPrices =
    metals.values.any(
          (currencies) =>
          currencies.values.any(
                (price) =>
            price.buy > 0 ||
                price.sell > 0 ||
                price.market > 0,
          ),
    );

    if (hasCachedPrices) {
      _usingCachedPrices = true;

      _log(
        '🟡 ==================================================',
      );

      _log(
        '🟡 [PRICE SOURCE] CACHE',
      );

      _log(
        '🟡 عرض آخر سعر محفوظ قبل وصول Live Socket',
      );

      _log(
        '🟡 ==================================================',
      );

      emit(
        LivePriceLive(
          message:
          '⚡ آخر سعر محفوظ - جاري التحديث...',
          metals: metals.map(
                (key, value) =>
                MapEntry(
                  key,
                  Map<String, MetalPrices>.from(
                    value,
                  ),
                ),
          ),
          lastTick: null,
        ),
      );
    } else {
      _usingCachedPrices = false;

      _log(
        '⚪ [PRICE SOURCE] NO CACHE '
            '→ لا يوجد سعر محفوظ، في انتظار WebSocket',
      );

      emit(
        LivePriceConnecting(),
      );
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // ==========================================================
    // CONNECT SOCKET
    // ==========================================================

    try {
      await _socket.connectAndListen(
        onConnected: () {
          _log(
            '🟢 [SOCKET] CONNECTED ✅',
          );

          _log(
            '🟢 الاتصال تم بنجاح، '
                'لكن السعر يعتبر LIVE فقط عند وصول onPrice.',
          );
        },

        // ======================================================
        // NEW PRICE TICK
        // ======================================================

        onPrice: (LivePriceModel p) {
          if (!_wantRunning) {
            _log(
              'tick ignored '
                  '(wantRunning=false)',
            );

            return;
          }

          final c =
          p.currency.toUpperCase();

          if (c != 'USD' &&
              c != 'EGP') {
            _log(
              'tick ignored: currency=$c',
            );

            return;
          }

          final m =
          p.metal.toUpperCase();

          final normalized =
          MetalPrices(
            market: p.market,
            buy: p.buy,
            sell: p.sell,
            currency: c,
            timestamp: p.timestamp,
          ).normalized(
            decimals: 5,
          );

          metals[m] ??= {};

          metals[m]![c] =
              normalized;

          // ====================================================
          // TRACK XAG
          // ====================================================

          if (m == 'XAG' &&
              !_receivedXAG) {
            _receivedXAG = true;

            _log(
              '✅ أول tick فضة XAG وصل!',
            );
          }

          // ====================================================
          // SOURCE = LIVE SOCKET
          // ====================================================

          _usingCachedPrices = false;

          _log(
            '🟢 ==================================================',
          );

          _log(
            '🟢 [PRICE SOURCE] LIVE SOCKET',
          );

          _log(
            '🟢 السعر الحالي جاء من السيرفر عبر WebSocket',
          );

          _log(
            '🟢 Metal: $m',
          );

          _log(
            '🟢 Currency: $c',
          );

          _log(
            '🟢 Market: ${normalized.market}',
          );

          _log(
            '🟢 Buy: ${normalized.buy}',
          );

          _log(
            '🟢 Sell: ${normalized.sell}',
          );

          _log(
            '🟢 Timestamp: ${normalized.timestamp}',
          );

          _log(
            '🟢 ==================================================',
          );

          // ====================================================
          // SAVE TO CACHE
          // ====================================================

          unawaited(
            _saveCachedPrices(),
          );

          // ====================================================
          // UPDATE UI
          // ====================================================

          emit(
            LivePriceLive(
              message:
              '✅ السعر لايف شغال',
              metals: metals.map(
                    (key, value) =>
                    MapEntry(
                      key,
                      Map<String, MetalPrices>.from(
                        value,
                      ),
                    ),
              ),
              lastTick: p,
            ),
          );
        },

        // ======================================================
        // ERROR
        // ======================================================

        onError: (msg) {
          _log(
            'ERROR => $msg | '
                'wantRunning=$_wantRunning',
          );

          if (!_wantRunning) {
            return;
          }

          // لو عندنا Cache صالح، نوضح أن السعر المعروض
          // ما زال من آخر Cache وليس Live
          if (_usingCachedPrices) {
            _log(
              '🟡 [PRICE SOURCE] CACHE '
                  '→ Socket error، السعر المعروض ما زال من الـ Cache.',
            );
          }

          emit(
            LivePriceStopped(
              message:
              '⚠️ $msg',
            ),
          );

          if (_hasInternet &&
              _wantRunning) {
            _reconnectTimer?.cancel();

            _reconnectTimer =
                Timer(
                  const Duration(
                    seconds: 3,
                  ),
                      () {
                    _log(
                      'RECONNECT after error...',
                    );

                    start();
                  },
                );
          }
        },

        // ======================================================
        // DISCONNECTED
        // ======================================================

        onDisconnected: () async {
          _log(
            'DISCONNECTED callback | '
                'wantRunning=$_wantRunning '
                'hasInternet=$_hasInternet',
          );

          if (!_wantRunning) {
            _log(
              'No reconnect: '
                  'wantRunning=false '
                  '(background/manual stop)',
            );

            return;
          }

          if (_usingCachedPrices) {
            _log(
              '🟡 [PRICE SOURCE] CACHE '
                  '→ Socket disconnected، السعر المعروض من الـ Cache.',
            );
          }

          emit(
            LivePriceStopped(
              message:
              '⛔ Live price stopped',
            ),
          );

          if (_hasInternet &&
              _wantRunning) {
            _reconnectTimer?.cancel();

            _reconnectTimer =
                Timer(
                  const Duration(
                    seconds: 3,
                  ),
                      () {
                    _log(
                      'RECONNECT attempt...',
                    );

                    start();
                  },
                );
          }
        },
      );
    } catch (e) {
      _log(
        'start exception => $e',
      );

      if (_usingCachedPrices) {
        _log(
          '🟡 [PRICE SOURCE] CACHE '
              '→ فشل الاتصال، السعر المتاح ما زال من الـ Cache.',
        );
      }

      emit(
        LivePriceStopped(
          message:
          '⛔ Live price stopped',
        ),
      );

      if (_hasInternet &&
          _wantRunning) {
        _reconnectTimer?.cancel();

        _reconnectTimer =
            Timer(
              const Duration(
                seconds: 3,
              ),
                  () {
                _log(
                  'RECONNECT attempt '
                      'after exception...',
                );

                start();
              },
            );
      }
    } finally {
      _starting = false;

      _log(
        'start() finished | '
            'starting=$_starting',
      );
    }
  }

  // ============================================================
  // STOP
  // ============================================================

  Future<void> stop({
    String message = '⛔ stopped',
  }) async {
    _wantRunning = false;

    _log(
      'stop() called '
          'message="$message" '
          'socketConnected=${_socket.isConnected}',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // مهم:
    // لا نمسح الـ Cache عند stop
    await _socket.disconnect();

    emit(
      LivePriceStopped(
        message: message,
      ),
    );
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  Future<void> close() async {
    _log(
      'close() called',
    );

    _wantRunning = false;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _connectivitySub?.cancel();

    _connectivitySub = null;

    await _socket.disconnect();

    return super.close();
  }
}

////////////////////////////////////////////////////////
// النسخع ده اللي شغاله قبل منعمل الكاش

// class LivePriceCubit extends Cubit<LivePriceState> {
//   LivePriceCubit() : super(LivePriceInitial()) {
//     _log('onCreate -- LivePriceCubit');
//     _listenToConnectivity();
//   }
//
//   final LivePriceSocketService _socket = LivePriceSocketService.instance;
//
//   bool _starting = false;
//
//   /// ✅ true = foreground (عايز السوكت شغال)
//   /// ✅ false = background/manual stop (مش عايزين reconnect)
//   bool _wantRunning = false;
//
//   Timer? _reconnectTimer;
//
//   final Connectivity _connectivity = Connectivity();
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
//
//   bool _hasInternet = true;
//
//   final Map<String, Map<String, MetalPrices>> metals = {
//     'XAU': {
//       'USD': const MetalPrices(market: 0, buy: 0, sell: 0, currency: 'USD', timestamp: ''),
//       'EGP': const MetalPrices(market: 0, buy: 0, sell: 0, currency: 'EGP', timestamp: ''),
//     },
//     'XAG': {
//       'USD': const MetalPrices(market: 0, buy: 0, sell: 0, currency: 'USD', timestamp: ''),
//       'EGP': const MetalPrices(market: 0, buy: 0, sell: 0, currency: 'EGP', timestamp: ''),
//     },
//   };
//
//   /// ✅ تتبع هل وصلت بيانات XAG من السوكت
//   bool _receivedXAG = false;
//
//   void _log(String m) {
//     // ignore: avoid_print
//     print('🟦 [LiveCubit] $m');
//   }
//
//   void _listenToConnectivity() {
//     _log('Connectivity listener started ✅');
//
//     _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
//       final nowHasInternet = results.any((r) => r != ConnectivityResult.none);
//
//       _log(
//         'Connectivity => $results nowHasInternet=$nowHasInternet '
//             '(old=$_hasInternet) wantRunning=$_wantRunning',
//       );
//
//       if (nowHasInternet == _hasInternet) return;
//       _hasInternet = nowHasInternet;
//
//       if (_hasInternet) {
//         if (_wantRunning) {
//           _log('Internet back ✅ -> start()');
//           emit(LivePriceConnecting());
//           start();
//         } else {
//           _log('Internet back but wantRunning=false -> keep stopped');
//           emit(LivePriceStopped(message: '⛔ Live price stopped'));
//         }
//       } else {
//         _log('Internet lost ❌ -> stop()');
//         stop(message: '⛔ No internet connection');
//       }
//     });
//   }
//
//   Future<void> start() async {
//     _wantRunning = true;
//
//     _log(
//       'start() called | hasInternet=$_hasInternet starting=$_starting '
//           'socketConnected=${_socket.isConnected}',
//     );
//
//     if (!_hasInternet) {
//       _log('start blocked: no internet');
//       emit(LivePriceStopped(message: '⛔ No internet connection'));
//       return;
//     }
//
//     if (_socket.isConnected) {
//       _log('start skipped: already connected ✅');
//       emit(
//         LivePriceLive(
//           message: '✅ السعر لايف شغال',
//           metals: metals.map((k, v) => MapEntry(k, Map<String, MetalPrices>.from(v))),
//           lastTick: null,
//         ),
//       );
//       return;
//     }
//
//     if (_starting) {
//       _log('start skipped: already starting');
//       return;
//     }
//
//     _starting = true;
//     emit(LivePriceConnecting());
//
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;
//
//     try {
//       await _socket.connectAndListen(
//         onConnected: () {
//           _log('socket CONNECTED ✅');
//         },
//         onPrice: (LivePriceModel p) {
//           if (!_wantRunning) {
//             _log('tick ignored (wantRunning=false)');
//             return;
//           }
//
//           final c = p.currency.toUpperCase(); // USD/EGP
//           if (c != 'USD' && c != 'EGP') {
//             _log('tick ignored: currency=$c');
//             return;
//           }
//
//           final m = p.metal.toUpperCase(); // XAU/XAG
//
//           final normalized = MetalPrices(
//             market: p.market,
//             buy: p.buy,
//             sell: p.sell,
//             currency: c,
//             timestamp: p.timestamp,
//           ).normalized(decimals: 5);
//
//           metals[m] ??= {};
//           metals[m]![c] = normalized;
//
//           // ✅ تتبع وصول XAG
//           if (m == 'XAG' && !_receivedXAG) {
//             _receivedXAG = true;
//             _log('✅ أول tick فضة XAG وصل!');
//           }
//
//           // ✅ Live Price Log
//           final emoji = m == 'XAU' ? '🟨' : '⬜';
//           final label = m == 'XAU' ? 'GOLD' : 'SILVER';
//           _log(
//             '\n$emoji $label LIVE PRICE\n'
//             'Metal: $m\n'
//             'Currency: $c\n'
//             'Market: ${normalized.market}\n'
//             'Buy: ${normalized.buy}\n'
//             'Sell: ${normalized.sell}\n'
//             'Time: ${normalized.timestamp}\n',
//           );
//
//           emit(
//             LivePriceLive(
//               message: '✅ السعر لايف شغال',
//               metals: metals.map((k, v) => MapEntry(k, Map<String, MetalPrices>.from(v))),
//               lastTick: p,
//             ),
//           );
//         },
//         onError: (msg) {
//           _log('ERROR => $msg | wantRunning=$_wantRunning');
//
//           if (!_wantRunning) return;
//
//           emit(LivePriceStopped(message: '⚠️ $msg'));
//
//           if (_hasInternet && _wantRunning) {
//             _reconnectTimer?.cancel();
//             _reconnectTimer = Timer(const Duration(seconds: 3), () {
//               _log('RECONNECT after error...');
//               start();
//             });
//           }
//         },
//         onDisconnected: () async {
//           _log('DISCONNECTED callback | wantRunning=$_wantRunning hasInternet=$_hasInternet');
//
//           if (!_wantRunning) {
//             _log('No reconnect: wantRunning=false (background/manual stop)');
//             return;
//           }
//
//           emit(LivePriceStopped(message: '⛔ Live price stopped'));
//
//           if (_hasInternet && _wantRunning) {
//             _reconnectTimer?.cancel();
//             _reconnectTimer = Timer(const Duration(seconds: 3), () {
//               _log('RECONNECT attempt...');
//               start();
//             });
//           }
//         },
//       );
//     } catch (e) {
//       _log('start exception => $e');
//       emit(LivePriceStopped(message: '⛔ Live price stopped'));
//
//       if (_hasInternet && _wantRunning) {
//         _reconnectTimer?.cancel();
//         _reconnectTimer = Timer(const Duration(seconds: 3), () {
//           _log('RECONNECT attempt after exception...');
//           start();
//         });
//       }
//     } finally {
//       _starting = false;
//       _log('start() finished | starting=$_starting');
//     }
//   }
//
//   Future<void> stop({String message = '⛔ stopped'}) async {
//     _wantRunning = false;
//
//     _log('stop() called message="$message" socketConnected=${_socket.isConnected}');
//
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;
//
//     // ✅ disconnect حتى لو isConnected false (عشان safety)
//     await _socket.disconnect();
//
//     emit(LivePriceStopped(message: message));
//   }
//
//   @override
//   Future<void> close() async {
//     _log('close() called');
//
//     _wantRunning = false;
//
//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;
//
//     await _connectivitySub?.cancel();
//     _connectivitySub = null;
//
//     await _socket.disconnect();
//
//     return super.close();
//   }
// }
