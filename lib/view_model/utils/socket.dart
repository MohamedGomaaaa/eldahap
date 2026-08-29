import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../model/live_price_model.dart';

class LivePriceSocketService {
  LivePriceSocketService._();
  static final instance = LivePriceSocketService._();

  WebSocket? _ws;
  StreamSubscription? _sub;

  bool isConnected = false;

  bool _closing = false;
  bool _subscribed = false;

  bool _connecting = false;

  /// ✅ Lock يمنع disconnect يتكرر
  Future<void>? _disconnecting;

  // ✅ URL الحقيقي (Pusher)
  final String url =
      'wss://ws.officialgold.site/app/newGoldKey2026?protocol=7&client=js&version=8.4.0&flash=false';

  // ✅ Origin لازم
  final String origin = 'https://officialgold.site';

  // ✅ Channel ثابت
  final String channel = 'gold-price';

  void _log(String m) {
    // ignore: avoid_print
    print('🧩 [LiveSocket] $m');
  }

  Future<void> connectAndListen({
    required void Function() onConnected,
    required void Function(LivePriceModel p) onPrice,
    required void Function(String msg) onError,
    required Future<void> Function() onDisconnected,
  }) async {
    _log(
      'connectAndListen() called | isConnected=$isConnected connecting=$_connecting closing=$_closing',
    );

    if (isConnected) {
      _log('connect skipped: already connected ✅');
      return;
    }

    if (_connecting) {
      _log('connect skipped: already connecting...');
      return;
    }

    _connecting = true;

    // ✅ لو فيه disconnect شغال استناه
    if (_disconnecting != null) {
      _log('waiting for disconnect to finish...');
      await _disconnecting;
    }

    _closing = false;
    _subscribed = false;

    try {
      _log('URL => $url');
      _log('Origin => $origin');
      _log('Channel => $channel');
      _log('CONNECTING...');

      _ws = await WebSocket.connect(
        url,
        headers: {'Origin': origin},
      );

      _ws!.pingInterval = const Duration(seconds: 10);

      isConnected = true;
      _log('CONNECTED ✅ pingInterval=10s');
      onConnected();

      _sub = _ws!.listen(
            (dynamic data) {
          if (_closing) return;

          try {
            final raw = data is String ? data : data.toString();
            _log('RAW <= $raw');

            final Map<String, dynamic> parsed = jsonDecode(raw);
            _log('PARSED keys => ${parsed.keys.toList()}');

            final event = parsed['event']?.toString();
            final ch = parsed['channel']?.toString();

            _log('EVENT=$event CHANNEL=$ch');

            // ✅ pusher connection established
            if (event == 'pusher:connection_established') {
              _log('PUSHER established ✅ -> subscribing...');
              _subscribe();
              return;
            }

            // ✅ subscription succeeded
            if (event == 'pusher_internal:subscription_succeeded' ||
                event == 'pusher:subscription_succeeded') {
              _subscribed = true;
              _log('SUBSCRIBED ✅ channel=$ch');
              return;
            }

            // ✅ prices
            if (event != 'PriceUpdated') {
              _log('SKIP (event != PriceUpdated)');
              return;
            }

            // ✅ channel لازم يطابق
            if (ch != null && ch.isNotEmpty && ch != channel) {
              _log('SKIP (wrong channel=$ch)');
              return;
            }

            final inner = parsed['data'];
            final Map<String, dynamic> payload = inner is String
                ? jsonDecode(inner)
                : Map<String, dynamic>.from(inner);

            final model = LivePriceModel.fromJson(payload);

            // ✅ XAU و XAG فقط
            final metal = model.metal.toUpperCase();
            if (metal != 'XAU' && metal != 'XAG') {
              _log('SKIP (metal=${model.metal})');
              return;
            }

            _log('PRICE ✅ ${model.currency} buy=${model.buy} sell=${model.sell}');
            onPrice(model);
          } catch (e) {
            _log('parse error => $e');
            if (!_closing) onError('parse error: $e');
          }
        },
        onError: (Object e, StackTrace st) {
          // ✅ لو بنقفل تجاهل
          if (_closing) return;
          _log('stream onError() => $e');
          onError(e.toString());
        },
        onDone: () async {
          _log('stream onDone() called | closing=$_closing');
          isConnected = false;

          if (_closing) {
            _log('DISCONNECTED ✅ (closed by us)');
            return;
          }

          _log('DISCONNECTED ❌ (server/network)');
          await onDisconnected();
        },
        cancelOnError: false,
      );
    } catch (e) {
      isConnected = false;
      _log('connect exception => $e');
      if (!_closing) onError(e.toString());
      await disconnect(); // تنظيف
    } finally {
      _connecting = false;
      _log('connectAndListen() finished | connecting=$_connecting isConnected=$isConnected');
    }
  }

  void _subscribe() {
    final ws = _ws;
    if (ws == null) return;
    if (_closing) return;

    if (_subscribed) {
      _log('subscribe skipped: already subscribed ✅');
      return;
    }

    final msg = {
      'event': 'pusher:subscribe',
      'data': {'channel': channel},
    };

    final encoded = jsonEncode(msg);
    _log('SEND => $encoded');
    ws.add(encoded);
  }

  /// ✅ disconnect ثابت + Lock (Future) لمنع التكرار
  Future<void> disconnect() async {
    if (_disconnecting != null) {
      _log('disconnect() skipped: already disconnecting...');
      return _disconnecting!;
    }

    final completer = Completer<void>();
    _disconnecting = completer.future;

    final ws = _ws; // snapshot
    final sub = _sub;

    _log('disconnect() called | ws=${ws != null} sub=${sub != null}');

    // flags بدري
    _closing = true;
    isConnected = false;
    _subscribed = false;

    // افصل الريفرنس بدري
    _ws = null;
    _sub = null;

    try {
      // 1) cancel subscription
      try {
        _log('cancel subscription...');
        await sub?.cancel();
        _log('subscription cancelled ✅');
      } catch (e) {
        _log('subscription cancel error => $e');
      }

      // 2) اقفل ping
      try {
        ws?.pingInterval = null;
      } catch (_) {}

      // 3) close socket
      try {
        if (ws != null) {
          _log('CLOSING socket...');
          await ws.close(1000, 'going away');
          _log('close() called ✅');
        }
      } catch (e) {
        _log('socket close error => $e');
      }

      // 4) استنى done
      try {
        if (ws != null) {
          _log('await ws.done...');
          await ws.done.timeout(const Duration(seconds: 2));
          _log('ws.done ✅');
        }
      } catch (e) {
        _log('ws.done timeout/error => $e');
      }

      await Future.delayed(const Duration(milliseconds: 50));
    } finally {
      _closing = false;
      _disconnecting = null;
      _log('DISCONNECTED ✅ (disconnect finished)');
      completer.complete();
    }
  }
}
