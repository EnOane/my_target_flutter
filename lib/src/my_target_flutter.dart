import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'ad_status_listener.dart';

/// Implementing displaying MyTarget ads, currently supported by Interstitial Ads only.
class MyTargetFlutter {
  static const MethodChannel _channel = MethodChannel('my_target_flutter');
  static const channel = EventChannel('my_target_flutter/ad_listener');

  static const _methodInitialize = 'initialize';
  static const _methodCreateInterstitialAd = 'createInterstitialAd';
  static const _methodLoad = 'load';
  static const _methodShow = 'show';

  final bool isDebug;

  Stream<AdEventMessage>? _stream;

  MyTargetFlutter({required this.isDebug});

  Stream<AdEventMessage> get _adListenStream {
    return _stream ??= channel
        .receiveBroadcastStream()
        .cast<Map<dynamic, dynamic>>()
        .transform(StreamTransformer.fromHandlers(
      handleData: (event, sink) {
        final data = AdEventMessage.fromJson(event.cast<String, dynamic>());
        sink.add(data);
      },
    ));
  }

  /// Initializing MyTarget ads.
  /// [useDebugMode] enabling debug mode.
  /// Pass the test device ID to [testDevices] if needed.
  /// For full details on test mode see [https://target.my.com/help/partners/mob/debug/en]
  Future<void> initialize({bool? useDebugMode, String? testDevices}) async {
    await _channel.invokeMethod(_methodInitialize,
        _getInitialData(useDebugMode ?? isDebug, testDevices));
  }

  /// Create an Interstitial ads with [slotId]
  Future<InterstitialAd> createInterstitialAd(int slotId) async {
    final uid = await _channel.invokeMethod<String>(
      _methodCreateInterstitialAd,
      {'slotId': slotId},
    );
    if (uid == null) {
      throw FlutterError('Can not create Interstitial ad');
    } else {
      return InterstitialAd(this, uid);
    }
  }

  Future<void> _load(String uid) async {
    await _channel.invokeMethod(_methodLoad, uid);
  }

  Future<void> _show(String uid) async {
    await _channel.invokeMethod(_methodShow, uid);
  }

  Map<String, dynamic> _getInitialData(bool useDebugMode, String? testDevices) {
    return <String, dynamic>{
      'useDebugMode': useDebugMode,
      'testDevices': testDevices,
    };
  }
}

class InterstitialAd {
  final MyTargetFlutter _plugin;
  final String uid;

  final _listeners = <AdStatusListener>{};

  InterstitialAd(this._plugin, this.uid) {
    _plugin._adListenStream.listen(_handleMessage);
  }

  Future<void> _handleMessage(AdEventMessage data) async {
    if (data.uid == uid) {
      _listeners.handleEvent(data);
    }
  }

  Future<void> load() async {
   await _plugin._load(uid);
  }

  Future<void> show() async {
    await _plugin._show(uid);
  }

  void addListener(AdStatusListener listener) {
    _listeners.add(listener);
  }

  void removeListener(AdStatusListener listener) {
    _listeners.remove(listener);
  }

  void clearListeners() {
    _listeners.clear();
  }
}

extension _SetAdStatusListenerExtension on Set<AdStatusListener> {
  void handleEvent(AdEventMessage data) {
    var listeners = toList();
    for (final listener in listeners) {
      listener.handleEvent(data);
    }
  }
}
