import 'dart:io';

import 'package:flutter/services.dart';
import 'package:jni/jni.dart';
import 'package:objective_c/objective_c.dart';

import '../android_api.g.dart' as android;
import '../ios_api.g.dart' as ios;

/// The same three native calls, made two ways.
abstract interface class DirectApi {
  int uptimeMs();
  String osVersion();
  bool isMainThread();

  /// FFIgen bindings on iOS, JNIgen bindings on Android. All synchronous.
  static DirectApi forPlatform() =>
      Platform.isIOS ? IosDirectApi() : AndroidDirectApi();

  static String get label => Platform.isIOS ? 'FFIgen' : 'JNIgen';
}

class IosDirectApi implements DirectApi {
  @override
  int uptimeMs() =>
      (ios.NSProcessInfo.getProcessInfo().systemUptime * 1000).round();

  @override
  String osVersion() => ios.NSProcessInfo.getProcessInfo()
      .operatingSystemVersionString
      .toDartString();

  @override
  bool isMainThread() => ios.NSThread.getIsMainThread$1();
}

class AndroidDirectApi implements DirectApi {
  @override
  int uptimeMs() => android.SystemClock.uptimeMillis();

  @override
  String osVersion() =>
      android.Build$VERSION.RELEASE!.toDartString(releaseOriginal: true);

  @override
  bool isMainThread() {
    final mine = android.Looper.myLooper();
    final main = android.Looper.mainLooper;
    final result = mine != null && mine == main;
    mine?.release();
    main?.release();
    return result;
  }
}

/// The platform-channel baseline. Every call is async and goes through
/// the standard method codec to a handler on the platform's main thread.
class ChannelApi {
  static const _channel = MethodChannel('bench');

  Future<int> uptimeMs() async {
    final v = await _channel.invokeMethod<Object>('uptime');
    return v is double ? (v * 1000).round() : v as int;
  }

  Future<String> osVersion() async =>
      (await _channel.invokeMethod<String>('osVersion'))!;

  Future<bool> isMainThread() async =>
      (await _channel.invokeMethod<bool>('isMainThread'))!;
}
