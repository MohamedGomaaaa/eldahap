import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/live_price_model.dart';
import '../../../model/metal_price_model.dart';
import '../../utils/socket.dart';
import 'live_states.dart';

class LivePriceCubit extends Cubit<LivePriceState> {
  LivePriceCubit() : super(LivePriceInitial()) {
    _log('onCreate -- LivePriceCubit');
    _listenToConnectivity();
  }

  final LivePriceSocketService _socket = LivePriceSocketService.instance;

  bool _starting = false;

  /// ✅ true = foreground (عايز السوكت شغال)
  /// ✅ false = background/manual stop (مش عايزين reconnect)
  bool _wantRunning = false;

  Timer? _reconnectTimer;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool _hasInternet = true;

  final Map<String, Map<String, MetalPrices>> metals = {
    'XAU': {
      'USD': const MetalPrices(market: 0, buy: 0, sell: 0, currency: 'USD', timestamp: ''),
      'EGP': const MetalPrices(market: 0, buy: 0, sell: 0, currency: 'EGP', timestamp: ''),
    },
    'XAG': {
      'USD': const MetalPrices(market: 0, buy: 0, sell: 0, currency: 'USD', timestamp: ''),
      'EGP': const MetalPrices(market: 0, buy: 0, sell: 0, currency: 'EGP', timestamp: ''),
    },
  };

  /// ✅ تتبع هل وصلت بيانات XAG من السوكت
  bool _receivedXAG = false;

  void _log(String m) {
    // ignore: avoid_print
    print('🟦 [LiveCubit] $m');
  }

  void _listenToConnectivity() {
    _log('Connectivity listener started ✅');

    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final nowHasInternet = results.any((r) => r != ConnectivityResult.none);

      _log(
        'Connectivity => $results nowHasInternet=$nowHasInternet '
            '(old=$_hasInternet) wantRunning=$_wantRunning',
      );

      if (nowHasInternet == _hasInternet) return;
      _hasInternet = nowHasInternet;

      if (_hasInternet) {
        if (_wantRunning) {
          _log('Internet back ✅ -> start()');
          emit(LivePriceConnecting());
          start();
        } else {
          _log('Internet back but wantRunning=false -> keep stopped');
          emit(LivePriceStopped(message: '⛔ Live price stopped'));
        }
      } else {
        _log('Internet lost ❌ -> stop()');
        stop(message: '⛔ No internet connection');
      }
    });
  }

  Future<void> start() async {
    _wantRunning = true;

    _log(
      'start() called | hasInternet=$_hasInternet starting=$_starting '
          'socketConnected=${_socket.isConnected}',
    );

    if (!_hasInternet) {
      _log('start blocked: no internet');
      emit(LivePriceStopped(message: '⛔ No internet connection'));
      return;
    }

    if (_socket.isConnected) {
      _log('start skipped: already connected ✅');
      emit(
        LivePriceLive(
          message: '✅ السعر لايف شغال',
          metals: metals.map((k, v) => MapEntry(k, Map<String, MetalPrices>.from(v))),
          lastTick: null,
        ),
      );
      return;
    }

    if (_starting) {
      _log('start skipped: already starting');
      return;
    }

    _starting = true;
    emit(LivePriceConnecting());

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      await _socket.connectAndListen(
        onConnected: () {
          _log('socket CONNECTED ✅');
        },
        onPrice: (LivePriceModel p) {
          if (!_wantRunning) {
            _log('tick ignored (wantRunning=false)');
            return;
          }

          final c = p.currency.toUpperCase(); // USD/EGP
          if (c != 'USD' && c != 'EGP') {
            _log('tick ignored: currency=$c');
            return;
          }

          final m = p.metal.toUpperCase(); // XAU/XAG

          final normalized = MetalPrices(
            market: p.market,
            buy: p.buy,
            sell: p.sell,
            currency: c,
            timestamp: p.timestamp,
          ).normalized(decimals: 5);

          metals[m] ??= {};
          metals[m]![c] = normalized;

          // ✅ تتبع وصول XAG
          if (m == 'XAG' && !_receivedXAG) {
            _receivedXAG = true;
            _log('✅ أول tick فضة XAG وصل!');
          }

          // ✅ Live Price Log
          final emoji = m == 'XAU' ? '🟨' : '⬜';
          final label = m == 'XAU' ? 'GOLD' : 'SILVER';
          _log(
            '\n$emoji $label LIVE PRICE\n'
            'Metal: $m\n'
            'Currency: $c\n'
            'Market: ${normalized.market}\n'
            'Buy: ${normalized.buy}\n'
            'Sell: ${normalized.sell}\n'
            'Time: ${normalized.timestamp}\n',
          );

          emit(
            LivePriceLive(
              message: '✅ السعر لايف شغال',
              metals: metals.map((k, v) => MapEntry(k, Map<String, MetalPrices>.from(v))),
              lastTick: p,
            ),
          );
        },
        onError: (msg) {
          _log('ERROR => $msg | wantRunning=$_wantRunning');

          if (!_wantRunning) return;

          emit(LivePriceStopped(message: '⚠️ $msg'));

          if (_hasInternet && _wantRunning) {
            _reconnectTimer?.cancel();
            _reconnectTimer = Timer(const Duration(seconds: 3), () {
              _log('RECONNECT after error...');
              start();
            });
          }
        },
        onDisconnected: () async {
          _log('DISCONNECTED callback | wantRunning=$_wantRunning hasInternet=$_hasInternet');

          if (!_wantRunning) {
            _log('No reconnect: wantRunning=false (background/manual stop)');
            return;
          }

          emit(LivePriceStopped(message: '⛔ Live price stopped'));

          if (_hasInternet && _wantRunning) {
            _reconnectTimer?.cancel();
            _reconnectTimer = Timer(const Duration(seconds: 3), () {
              _log('RECONNECT attempt...');
              start();
            });
          }
        },
      );
    } catch (e) {
      _log('start exception => $e');
      emit(LivePriceStopped(message: '⛔ Live price stopped'));

      if (_hasInternet && _wantRunning) {
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 3), () {
          _log('RECONNECT attempt after exception...');
          start();
        });
      }
    } finally {
      _starting = false;
      _log('start() finished | starting=$_starting');
    }
  }

  Future<void> stop({String message = '⛔ stopped'}) async {
    _wantRunning = false;

    _log('stop() called message="$message" socketConnected=${_socket.isConnected}');

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // ✅ disconnect حتى لو isConnected false (عشان safety)
    await _socket.disconnect();

    emit(LivePriceStopped(message: message));
  }

  @override
  Future<void> close() async {
    _log('close() called');

    _wantRunning = false;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _connectivitySub?.cancel();
    _connectivitySub = null;

    await _socket.disconnect();

    return super.close();
  }
}
