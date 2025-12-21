import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:official_gold/view_model/utils/colors.dart';

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
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<String>(
          future: rootBundle.loadString(getFilePath()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
            InAppWebView(
            initialData: InAppWebViewInitialData(
            data: snapshot.data!,
              mimeType: "text/html",
              encoding: "utf-8",
            ),
            initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            transparentBackground: true,
            disableVerticalScroll: false,
            disableHorizontalScroll: false,
            supportZoom: true,
            ),
            android: AndroidInAppWebViewOptions(
            useWideViewPort: true,
            loadWithOverviewMode: true,
            domStorageEnabled: true,
            ),
            ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
            ),
            ),
            onWebViewCreated: (controller) {
            // Optional: Add any initialization code here
            },
            onLoadStop: (controller, url) async {
            // Inject custom CSS to ensure proper touch handling
            await controller.evaluateJavascript(source: """
                  // Ensure the chart container handles touch events properly
                  document.addEventListener('DOMContentLoaded', function() {
                    var chartContainer = document.querySelector('.tradingview-widget-container');
                    if (chartContainer) {
                      chartContainer.style.touchAction = 'auto';
                      chartContainer.style.overflow = 'hidden';
                    }
                  });
                """);
            },
            ),
                Positioned(
                  bottom: 0,
                  child: Container(

                    width: 1.sw,
                    height: 27.h,
                    color: AppColors.black,
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}