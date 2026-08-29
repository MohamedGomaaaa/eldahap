import '../../../model/live_price_model.dart';
import '../../../model/metal_price_model.dart';

abstract class LivePriceState {}

class LivePriceInitial extends LivePriceState {}

class LivePriceConnecting extends LivePriceState {}

class LivePriceStopped extends LivePriceState {
  final String message;
  LivePriceStopped({required this.message});
}

class LivePriceLive extends LivePriceState {
  final String message;
  final Map<String, Map<String, MetalPrices>> metals; // keys: "XAU"/"XAG" → "USD"/"EGP"
  final LivePriceModel? lastTick; // ✅ nullable

  LivePriceLive({
    required this.message,
    required this.metals,
    required this.lastTick,
  });
}
