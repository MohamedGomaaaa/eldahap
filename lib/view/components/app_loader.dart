import 'package:flutter/material.dart';

class AppLoader {
  static final Map<ValueKey, Route<Object?>> _loaderKeys = {};

  static void showLoader(BuildContext context, ValueKey key) {
    if (_loaderKeys.containsKey(key)) return; // Prevent duplicate loaders

    final route = PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: const Center(
          child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
        ),
      ),
    );

    _loaderKeys[key] = route;

    Navigator.of(context).push(route).then((_) => _loaderKeys.remove(key));
  }

  static void closeLoader(BuildContext context, ValueKey key) {
    if (_loaderKeys.containsKey(key)) {
      Navigator.of(context).removeRoute(_loaderKeys[key]!);
      _loaderKeys.remove(key);
    }
  }
}
