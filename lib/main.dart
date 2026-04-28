import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view_model/data/local/shared_helper.dart';
import 'package:flutter/foundation.dart';
import 'view_model/cubit/observer.dart';
import 'l10n/localization.dart';
import 'my_app.dart';
import 'dart:async';
import 'dart:io';

/// token 227|0uXa77GZ3DjN2jLWr5UnDseKwSxV8h9ztijLWUJ74d9bfac4


///  اتاكد انه ميعملش كلوز والصفقه مفتوحه


// also wallet with pl  in all pages and in buy and details




void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await EasyLocalization.ensureInitialized();
    await ScreenUtil.ensureScreenSize();
    await SharedHelper.init();
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);

    Bloc.observer = MyBlocObserver();

    EasyLocalization.logger.enableLevels = [];

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (error is SocketException &&
          error.message.contains('Reading from a closed socket')) {
        debugPrint('🟡 Ignored SocketException: Reading from a closed socket');
        return true;
      }
      return false;
    };

    runApp(
      EasyLocalization(
        supportedLocales: L10n.all,
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    );
  }, (Object error, StackTrace stack) {
    if (error is SocketException &&
        error.message.contains('Reading from a closed socket')) {
      debugPrint('🟡 Ignored (zone) Reading from a closed socket');
      return;
    }
    debugPrint('🔴 Unhandled zone error: $error');
  });
}
