import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Owns a user-started, non-persistent receive window, not file consent.
class BackgroundReceive extends ChangeNotifier {
  final MethodChannel channel;
  final Duration duration;
  final void Function() onDisabled;
  final DateTime Function() clock;
  DateTime? _deadline;
  Future<void> _operations = Future.value();
  Timer? _timer;
  bool _enabled = false;
  bool get enabled =>
      _enabled && (_deadline == null || clock().isBefore(_deadline!));
  bool changing = false;
  bool unavailable = false;
  bool _nativeRunning = false;
  bool _busy = false;
  bool _closed = false;
  int _generation = 0;
  String? _request;

  BackgroundReceive({
    required this.channel,
    required this.onDisabled,
    this.duration = const Duration(minutes: 30),
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _operations.then((_) => action());
    _operations = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<bool> setEnabled(bool value) {
    if (_closed) return Future.value(false);
    final generation = ++_generation;
    if (!value) {
      _enabled = false;
      _timer?.cancel();
      onDisabled();
    }
    changing = true;
    notifyListeners();
    return _serial(() async {
      try {
        if (generation != _generation) return enabled;
        if (value) {
          final allowed =
              await channel.invokeMethod<bool>('backgroundReceiveStatus') ==
              true;
          if (generation != _generation || _closed) return false;
          if (!allowed) {
            unavailable = true;
            _enabled = false;
            onDisabled();
            await _stopNative();
            return false;
          }
          await channel.invokeMethod<void>('startBackgroundReceive', {
            'milliseconds': duration.inMilliseconds,
          });
          _nativeRunning = true;
          if (generation != _generation || _closed) return false;
          _enabled = true;
          _deadline = clock().add(duration);
          unavailable = false;
          _timer?.cancel();
          _timer = Timer(duration, () => unawaited(setEnabled(false)));
        } else {
          await _clearRequest();
          if (!_busy) await _stopNative();
        }
        return enabled;
      } on Object {
        _enabled = false;
        unavailable = true;
        onDisabled();
        await _clearRequest();
        await _stopNative();
        return false;
      } finally {
        if (generation == _generation) {
          changing = false;
          if (!_closed) notifyListeners();
        }
      }
    });
  }

  Future<void> _stopNative() async {
    if (!_nativeRunning) return;
    try {
      await channel.invokeMethod<void>('stopBackgroundReceive');
    } on Object {
      unavailable = true;
    } finally {
      _nativeRunning = false;
    }
  }

  Future<void> setBusy(bool value) async {
    _busy = value;
    if (!value && !enabled) await _serial(_stopNative);
  }

  Future<bool> notifyRequest(String id) async {
    if (!enabled || _closed) return false;
    _request = id;
    try {
      final shown =
          await channel.invokeMethod<bool>('showReceiveRequest', {'id': id}) ==
          true;
      if (shown && enabled && _request == id && !_closed) return true;
    } on Object {
      /* Revoked permission is a reception failure, not consent. */
    }
    await setEnabled(false);
    return false;
  }

  bool matchesRequest(String id) => enabled && !_closed && _request == id;

  Future<void> clearRequest(String id) async {
    if (_request != id) return;
    await _clearRequest();
  }

  Future<void> _clearRequest() async {
    final id = _request;
    _request = null;
    if (id == null) return;
    try {
      await channel.invokeMethod<void>('clearReceiveRequest', {'id': id});
    } on Object {
      /* System removal cannot preserve a local grant. */
    }
  }

  Future<void> refreshPermission() async {
    if (!enabled) {
      if (_nativeRunning) await setEnabled(false);
      return;
    }
    try {
      if (await channel.invokeMethod<bool>('backgroundReceiveStatus') != true) {
        unavailable = true;
        await setEnabled(false);
      }
    } on Object {
      unavailable = true;
      await setEnabled(false);
    }
  }

  Future<void> close() async {
    if (_closed) return;
    await setEnabled(false);
    _closed = true;
    _timer?.cancel();
    _busy = false;
    await _serial(_stopNative);
  }
}
