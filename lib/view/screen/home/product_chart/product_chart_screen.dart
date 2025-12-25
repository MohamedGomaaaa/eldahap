import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view_model/utils/colors.dart';





////////////////////////////////////////////////////////////////////////////////////// new code by gomaa


class TradingViewPage extends StatelessWidget {
  final int type;
  const TradingViewPage({super.key, required this.type});

  String getFilePath() {
    switch (type) {
      case 1:
        return "assets/html/chart_gold.html";
      case 2:
        return "assets/html/chart_silver.html";
      case 3:
        return "assets/html/chart_bitcoin.html";
      default:
        return "assets/html/chart_gold.html";
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ValueNotifier<bool>(true);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: FutureBuilder<String>(
          future: rootBundle.loadString(getFilePath()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ColoredBox(
                color: AppColors.black,
                child: Center(child: CircularProgressIndicator(backgroundColor: AppColors.yellow,)),
              );
            }

            return Stack(
              children: [
                // 1) خلفية سوداء ثابتة تمنع أي فلاش أبيض
                const Positioned.fill(
                  child: ColoredBox(color: AppColors.black),
                ),

                InAppWebView(
                  initialData: InAppWebViewInitialData(
                    data: snapshot.data!,
                    mimeType: "text/html",
                    encoding: "utf-8",
                    baseUrl: WebUri("about:blank"),
                  ),
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      transparentBackground: false,
                      disableVerticalScroll: false,
                      disableHorizontalScroll: false,
                      supportZoom: true,
                    ),
                    android: AndroidInAppWebViewOptions(
                      useWideViewPort: true,
                      loadWithOverviewMode: true,
                      domStorageEnabled: true,
                      useHybridComposition: true, // يقلل الـ white flash على Android
                    ),
                    ios: IOSInAppWebViewOptions(
                      allowsInlineMediaPlayback: true,
                    ),
                  ),
                  onLoadStart: (controller, url) {
                    loading.value = true;
                  },
                  onLoadStop: (controller, url) async {
                    // خلي الـ HTML نفسه أسود كمان
                    await controller.evaluateJavascript(source: """
                      try {
                        document.documentElement.style.background = '#000';
                        document.body.style.background = '#000';
                        document.body.style.margin = '0';
                      } catch(e) {}
                    """);

                    // كودك الخاص بالـ touch
                    await controller.evaluateJavascript(source: """
                      document.addEventListener('DOMContentLoaded', function() {
                        var chartContainer = document.querySelector('.tradingview-widget-container');
                        if (chartContainer) {
                          chartContainer.style.touchAction = 'auto';
                          chartContainer.style.overflow = 'hidden';
                        }
                      });
                    """);

                    loading.value = false;
                  },
                ),

                // 2) Overlay أسود أثناء التحميل
                ValueListenableBuilder<bool>(
                  valueListenable: loading,
                  builder: (_, isLoading, __) {
                    if (!isLoading) return const SizedBox.shrink();
                    return const Positioned.fill(
                      child: ColoredBox(
                        color: AppColors.black,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  },
                ),

                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 1.sw,
                    height: 27.h,
                    color: AppColors.black,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}










//////////////////////////////////////////////////////////////////////////////////////// old
// class TradingViewPage extends StatelessWidget {
//   final int type;
//   const TradingViewPage({super.key, required this.type});
//
//   String getFilePath() {
//     switch (type) {
//       case 1:
//         return "assets/html/chart_gold.html";
//       case 2:
//         return "assets/html/chart_silver.html";
//       case 3:
//         return "assets/html/chart_bitcoin.html";
//       default:
//         return "assets/html/chart_gold.html";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.black,
//       body: SafeArea(
//         child: FutureBuilder<String>(
//           future: rootBundle.loadString(getFilePath()),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             return Stack(
//               children: [
//                 InAppWebView(
//                   initialData: InAppWebViewInitialData(
//                     data: snapshot.data!,
//                     mimeType: "text/html",
//                     encoding: "utf-8",
//                   ),
//                   initialOptions: InAppWebViewGroupOptions(
//                     crossPlatform: InAppWebViewOptions(
//                       javaScriptEnabled: true,
//                       transparentBackground: false,
//                       disableVerticalScroll: false,
//                       disableHorizontalScroll: false,
//                       supportZoom: true,
//                     ),
//                     android: AndroidInAppWebViewOptions(
//                       useWideViewPort: true,
//                       loadWithOverviewMode: true,
//                       domStorageEnabled: true,
//                     ),
//                     ios: IOSInAppWebViewOptions(
//                       allowsInlineMediaPlayback: true,
//                     ),
//                   ),
//                   onWebViewCreated: (controller) {
//                     // Optional: Add any initialization code here
//                   },
//                   onLoadStop: (controller, url) async {
//                     // Inject custom CSS to ensure proper touch handling
//                     await controller.evaluateJavascript(source: """
//                   // Ensure the chart container handles touch events properly
//                   document.addEventListener('DOMContentLoaded', function() {
//                     var chartContainer = document.querySelector('.tradingview-widget-container');
//                     if (chartContainer) {
//                       chartContainer.style.touchAction = 'auto';
//                       chartContainer.style.overflow = 'hidden';
//                     }
//                   });
//                 """);
//                   },
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   child: Container(
//                     width: 1.sw,
//                     height: 27.h,
//                     color: AppColors.black,
//                   ),
//                 )
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
