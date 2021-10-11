import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'constants.dart';

/// A web implementation of the CrossBoard plugin.
class CrossBoardWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'cross_board',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = CrossBoardWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case channelMethodRequestPermission:
        return _requestPermission();
      case channelMethodCopy:
        return copy(call.arguments);
      case channelMethodPaste:
        return paste();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'cross_board for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Copy the value to the clipboard
  Future<dynamic>? copy(String value) {
    // if (value is Uint8List) {
    //   var dataTransfer = html.DataTransfer();
    //   dataTransfer.setData('image/png', html.Blob([value]).toString());
    //   return html.window.navigator.clipboard?.write(dataTransfer);
    // }
    return html.window.navigator.clipboard?.writeText(value);
  }

  /// Get the value from the clipboard
  Future<String> paste() {
    return html.window.navigator.clipboard?.readText() ?? Future.value('');
  }

  /// Request permission to access the clipboard
  Future<bool> _requestPermission() async {
    Completer<bool> permissionCompleter = Completer<bool>();
    html.window.navigator.permissions?.query(
      {'name': "clipboard-write"},
    ).then(
      (result) {
        bool permissionGranted = ['granted', 'prompt'].contains(result.state);
        permissionCompleter.complete(permissionGranted);
      },
    );
    return permissionCompleter.future;
  }
}
