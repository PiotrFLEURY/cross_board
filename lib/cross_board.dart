import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cross_board/constants.dart';
import 'package:flutter/services.dart';

class CrossBoard {
  static const MethodChannel _channel = MethodChannel('cross_board');

  static Future<void> copy(dynamic value) async {
    if (value is String) {
      return _channel.invokeMethod(channelMethodCopy, value);
    } else if (value is ui.Image) {
      ui.Image _image = value;
      ByteData? bytes = await _image.toByteData(format: ui.ImageByteFormat.png);
      return _channel.invokeMethod(
          channelMethodCopy, bytes?.buffer.asUint8List());
    } else {
      return _channel.invokeMethod(channelMethodCopy, value);
    }
  }

  static Future<dynamic> paste() async {
    dynamic _value = await _channel.invokeMethod(channelMethodPaste);
    if (_value is Uint8List) {
      ui.Codec codec = await ui.instantiateImageCodec(_value);
      ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    }
    return _value;
  }

  static Future<bool> requestPermission() async {
    bool _granted = await _channel.invokeMethod(channelMethodRequestPermission);
    return _granted;
  }
}
