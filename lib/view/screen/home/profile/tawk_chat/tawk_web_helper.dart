// import 'dart:html' as html;
// import 'dart:js' as js;
// import 'dart:js_util' as js_util;
//
// void initializeTawkTo({
//   required String propertyId,
//   required String widgetId,
//   Function? onLoaded,
// }) {
//   js.context['Tawk_API'] = js.JsObject.jsify({});
//   js.context['Tawk_LoadStart'] = js.JsObject(js.context['Date']);
//
//   js.context['Tawk_API']['onLoad'] = js.allowInterop(() {
//     print('Tawk.to loaded successfully');
//     if (onLoaded != null) {
//       onLoaded();
//     }
//   });
//
//   js.context['Tawk_API']['onChatStarted'] = js.allowInterop(() {
//     print('Chat started');
//   });
//
//   js.context['Tawk_API']['onChatEnded'] = js.allowInterop(() {
//     print('Chat ended');
//   });
//
//   js.context['Tawk_API']['onChatMessageVisitor'] = js.allowInterop((message) {
//     print('Visitor message: $message');
//   });
//
//   js.context['Tawk_API']['onChatMessageAgent'] = js.allowInterop((message) {
//     print('Agent message: $message');
//   });
//
//   final script = html.ScriptElement()
//     ..type = 'text/javascript'
//     ..async = true
//     ..src = 'https://embed.tawk.to/$propertyId/$widgetId'
//     ..charset = 'UTF-8'
//     ..setAttribute('crossorigin', '*');
//
//   html.document.head!.children.add(script);
// }
//
// void sendMessage(String message) {
//   try {
//     if (js.context.hasProperty('Tawk_API')) {
//       final tawkApi = js.context['Tawk_API'];
//       if (tawkApi != null && js_util.hasProperty(tawkApi, 'sendChatMessage')) {
//         js_util.callMethod(tawkApi, 'sendChatMessage', [message]);
//       }
//     }
//   } catch (e) {
//     print('Error sending message: $e');
//   }
// }
//
// void showWidget() {
//   try {
//     if (js.context.hasProperty('Tawk_API')) {
//       final tawkApi = js.context['Tawk_API'];
//       if (tawkApi != null && js_util.hasProperty(tawkApi, 'showWidget')) {
//         js_util.callMethod(tawkApi, 'showWidget', []);
//       }
//     }
//   } catch (e) {
//     print('Error showing widget: $e');
//   }
// }
//
// void hideWidget() {
//   try {
//     if (js.context.hasProperty('Tawk_API')) {
//       final tawkApi = js.context['Tawk_API'];
//       if (tawkApi != null && js_util.hasProperty(tawkApi, 'hideWidget')) {
//         js_util.callMethod(tawkApi, 'hideWidget', []);
//       }
//     }
//   } catch (e) {
//     print('Error hiding widget: $e');
//   }
// }
//
// void maximizeChat() {
//   try {
//     if (js.context.hasProperty('Tawk_API')) {
//       final tawkApi = js.context['Tawk_API'];
//       if (tawkApi != null && js_util.hasProperty(tawkApi, 'maximize')) {
//         js_util.callMethod(tawkApi, 'maximize', []);
//       }
//     }
//   } catch (e) {
//     print('Error maximizing chat: $e');
//   }
// }
//
// void minimizeChat() {
//   try {
//     if (js.context.hasProperty('Tawk_API')) {
//       final tawkApi = js.context['Tawk_API'];
//       if (tawkApi != null && js_util.hasProperty(tawkApi, 'minimize')) {
//         js_util.callMethod(tawkApi, 'minimize', []);
//       }
//     }
//   } catch (e) {
//     print('Error minimizing chat: $e');
//   }
// }
//
// void setVisitorInfo({String? name, String? email}) {
//   try {
//     if (js.context.hasProperty('Tawk_API')) {
//       final tawkApi = js.context['Tawk_API'];
//       if (tawkApi != null && js_util.hasProperty(tawkApi, 'setAttributes')) {
//         final attributes = js.JsObject.jsify({
//           'name': name ?? 'Flutter User',
//           'email': email ?? 'user@example.com',
//           'hash': ''
//         });
//
//         final callback = js.allowInterop((error) {
//           if (error != null) {
//             print('Error setting visitor info: $error');
//           } else {
//             print('Visitor info set successfully');
//           }
//         });
//
//         js_util.callMethod(tawkApi, 'setAttributes', [attributes, callback]);
//       }
//     }
//   } catch (e) {
//     print('Error setting visitor info: $e');
//   }
// }
