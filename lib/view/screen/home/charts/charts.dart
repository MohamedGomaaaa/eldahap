import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}
// https://www.tradingview.com/chart/?symbol=OANDA%3AXAUUSD&theme=dark
// https://www.tradingview.com/chart/?symbol=OANDA%3AXAUUSD&theme=dark
class _ChartsState extends State<Charts> {
  final Map<String, String> _links = {
    'gold': 'https://www.tradingview.com/chart/?symbol=OANDA%3AXAUUSD&theme=dark&fullscreen=1&hide_side_toolbar=1&hide_top_toolbar=1&hide_legend=1',
    'silver': 'https://www.tradingview.com/chart/?symbol=OANDA%3AXAGUSD&theme=dark&fullscreen=1&hide_side_toolbar=1&hide_top_toolbar=1&hide_legend=1',
    'bitcoin': 'https://www.tradingview.com/chart/?symbol=BITSTAMP%3ABTCUSD&theme=dark&fullscreen=1&hide_side_toolbar=1&hide_top_toolbar=1&hide_legend=1',
  };

  final Map<String, String> _labelsEN = {
    'gold': 'Gold',
    'silver': 'Silver',
    'bitcoin': 'Bitcoin',
  };

  final Map<String, String> _labelsAR = {
    'gold': 'ذهب',
    'silver': 'فضة',
    'bitcoin': 'بتكوين',
  };

  String _selectedItem = 'gold';
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:        Stack(
        children: [
          // WebView takes remaining space
          Container(
            color: Colors.black,
            height: double.infinity,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(_links[_selectedItem]!),
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

                // Apply dark theme background
                await controller.evaluateJavascript(source: """
    (function() {
      var style = document.createElement('style');
      style.id = 'minimal-dark-theme';
      style.innerHTML = \`
        body, html {
          background-color: #131722 !important;
          background: #131722 !important;
        }

        div:empty {
          background-color: #131722 !important;
        }
      \`;

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

                // Remove popups, modals, ads, toolbars
                await controller.evaluateJavascript(source: """
    (function removePopups() {
      const removeElements = () => {
        const selectors = [
          '[class*="popup"]',
          '[id*="popup"]',
          '[class*="modal"]',
          '[id*="modal"]',
          '[class*="overlay"]',
          '[class*="signin"]',
          '[class*="alert"]',
          '[class*="sheet"]',
          '[class*="notice"]',
          '[class*="subscribe"]',
          '[class*="banner"]',
          '[class*="unsupported"]',
          '.tv-floating-toolbar',
          '.tv-header',
          '.tv-side-toolbar',
          'iframe[src*="ads"]'
        ];

        selectors.forEach(selector => {
          document.querySelectorAll(selector).forEach(el => el.remove());
        });

        // Remove iframes that are not main chart
        document.querySelectorAll('iframe').forEach(iframe => {
          const src = iframe.getAttribute('src') || '';
          if (!src.includes('widgetembed') && !src.includes('chart')) {
            iframe.remove();
          }
        });
      };

      removeElements();

      const observer = new MutationObserver(removeElements);
      observer.observe(document.body, { childList: true, subtree: true });
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
          // Dropdown container at top of body
          Container(
            width: 140,
            color: Colors.transparent,
            padding: const EdgeInsets.all(0),
            child: Container(
              height: 40, // Small height
              width: 120, // Fixed width
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedItem,
                  dropdownColor: Colors.black,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  isDense: true,
                  isExpanded: true, // Fill container width
                  menuMaxHeight: 200,
                  items: _links.keys.map((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Container(
                        height: 32,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _labelsEN[key]!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedItem = value);
                      _webViewController?.loadUrl(
                        urlRequest: URLRequest(url: WebUri(_links[value]!)),
                      );
                    }
                  },
                ),
              ),
            ),
          ),

        ],
      ) ,
    );
  }
}
