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
// https://officialgold.site/api/





void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await EasyLocalization.ensureInitialized();
    await ScreenUtil.ensureScreenSize();
    await SharedHelper.init();

    // 🔴 التعديل هنا: تشغيل وضع الفحص للـ WebView على الأندرويد والآيفون فقط
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await InAppWebViewController.setWebContentsDebuggingEnabled(true);
      } catch (e) {
        debugPrint("WebView debugging is not supported on this platform.");
      }
    }

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



// void main() {
//   runZonedGuarded(() async {
//     WidgetsFlutterBinding.ensureInitialized();
//
//     await EasyLocalization.ensureInitialized();
//     await ScreenUtil.ensureScreenSize();
//     await SharedHelper.init();
//     await InAppWebViewController.setWebContentsDebuggingEnabled(true);
//
//     Bloc.observer = MyBlocObserver();
//
//     EasyLocalization.logger.enableLevels = [];
//
//     PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
//       if (error is SocketException &&
//           error.message.contains('Reading from a closed socket')) {
//         debugPrint('🟡 Ignored SocketException: Reading from a closed socket');
//         return true;
//       }
//       return false;
//     };
//
//     runApp(
//       EasyLocalization(
//         supportedLocales: L10n.all,
//         path: 'assets/translations',
//         fallbackLocale: const Locale('en'),
//         child: const MyApp(),
//       ),
//     );
//   }, (Object error, StackTrace stack) {
//     if (error is SocketException &&
//         error.message.contains('Reading from a closed socket')) {
//       debugPrint('🟡 Ignored (zone) Reading from a closed socket');
//       return;
//     }
//     debugPrint('🔴 Unhandled zone error: $error');
//   });
// }
