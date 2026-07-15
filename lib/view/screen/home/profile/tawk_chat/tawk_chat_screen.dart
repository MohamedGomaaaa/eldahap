import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TawkChatPage extends StatefulWidget {
  const TawkChatPage({super.key});

  @override
  State<TawkChatPage> createState() => _TawkChatPageState();
}

class _TawkChatPageState extends State<TawkChatPage> {
  InAppWebViewController? _webViewController;
  final String _tawkUrl = 'https://tawk.to/chat/6876395b3d9d30190be76cba/1j06t03qo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Top padding for status bar
          SizedBox(height: MediaQuery.of(context).padding.top),

          // WebView takes all available space
          Expanded(
            child: Container(
              color: Colors.black,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(_tawkUrl),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  forceDark: ForceDark.ON,
                  preferredContentMode: UserPreferredContentMode.MOBILE,
                  supportZoom: true,
                  transparentBackground: true,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  await Future.delayed(const Duration(milliseconds: 500));

                  await controller.evaluateJavascript(source: """
                    (function() {
                      var style = document.createElement('style');
                      style.id = 'minimal-dark-theme';
                      style.innerHTML = `
                        body, html {
                          background-color: #131722 !important;
                          background: #131722 !important;
                        }
                        
                        div:empty {
                          background-color: #131722 !important;
                        }
                      `;
                      
                      var existingStyle = document.getElementById('minimal-dark-theme');
                      if (existingStyle) {
                        existingStyle.remove();
                      }
                      
                      document.head.appendChild(style);
                      document.documentElement.style.backgroundColor = '#131722';
                      if (document.body) {
                        document.body.style.backgroundColor = '#131722';
                      }
                    })();
                  """);
                },
                onProgressChanged: (controller, progress) {
                  if (progress >= 30) {
                    controller.evaluateJavascript(source: """
                      document.documentElement.style.backgroundColor = '#131722';
                    """);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}