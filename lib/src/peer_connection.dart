import 'dart:async';

import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter/foundation.dart';

enum PeerConnectionState { checking, online, offline, identityChanged }

/// Reachability is independent of multicast discovery and never grants trust.
class PeerConnection extends ChangeNotifier {
  final Future<Peer> Function(Peer) _probe;
  final Duration interval;
  Peer? _peer;
  PeerConnectionState state = PeerConnectionState.checking;
  Timer? _timer;
  int _generation = 0;
  Future<bool>? _pending;
  bool _closed = false;

  PeerConnection({
    Future<Peer> Function(Peer)? probe,
    this.interval = const Duration(seconds: 1),
  }) : _probe =
           probe ??
           ((peer) => TransferClient.probe(
             peer.host,
             peer.port,
             timeout: const Duration(milliseconds: 800),
           ));

  bool watches(Peer peer) =>
      _peer?.id == peer.id &&
      _peer?.fingerprint == peer.fingerprint &&
      _peer?.host == peer.host &&
      _peer?.port == peer.port;

  void watch(Peer peer) {
    if (_closed) return;
    _generation++;
    _peer = peer;
    _pending = null;
    state = PeerConnectionState.checking;
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(check()));
    notifyListeners();
    unawaited(check());
  }

  Future<bool> check() {
    if (_closed || _peer == null) return Future.value(false);
    return _pending ??= _check(_peer!, _generation);
  }

  Future<bool> _check(Peer peer, int generation) async {
    var result = PeerConnectionState.offline;
    try {
      final observed = await Future.sync(() => _probe(peer))
          .timeout(const Duration(seconds: 1));
      result =
          observed.id == peer.id && observed.fingerprint == peer.fingerprint
          ? PeerConnectionState.online
          : PeerConnectionState.identityChanged;
    } on Object {
      // A failed identity-info request cannot establish reachability or trust.
    }
    if (_closed || generation != _generation) return false;
    _pending = null;
    state = result;
    notifyListeners();
    return result == PeerConnectionState.online;
  }

  @override
  void dispose() {
    _closed = true;
    _generation++;
    _timer?.cancel();
    super.dispose();
  }
}
