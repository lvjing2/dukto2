import 'dart:async';

import 'package:dukto2/src/transfer_session.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const offer = FileOffer(sender: 'Peer', name: 'file.bin', size: 3);
  test('approval has one result and cancellation before consent cannot start receiving', () async {
    final s = TransferSession.incoming(offer);
    final decision = s.awaitApproval();
    expect(identical(decision, s.awaitApproval()), isTrue);
    expect(s.receiving, isFalse);
    expect(s.pendingOffer, same(offer));
    s.cancel();
    expect(await decision, isFalse);
    expect(s.pendingOffer, isNull);
    await s.finish(SessionPhase.cancelled, () async {});
    expect(s.active, isFalse);
    expect(s.receiving, isFalse);
  });
  test(
    'an approved batch remains busy between files and counts completion once',
    () async {
      final s = TransferSession.incoming(
        batchOfferFromJson({
          'sender': 'Peer',
          'files': [
            {'name': 'one.bin', 'size': 3},
            {'name': 'empty.bin', 'size': 0},
          ],
        }, '127.0.0.1'),
      );
      final decision = s.awaitApproval();
      s.answer(true);
      expect(await decision, isTrue);
      s.beginFile(offer: offer, alreadyApproved: true);
      s.updateProgress(
        const TransferProgress(
          id: 'private-token',
          name: 'one.bin',
          total: 3,
          bytes: 3,
          incoming: true,
        ),
      );
      expect(s.phase, SessionPhase.verifying);
      expect(s.completeFile(), isNotNull);
      expect(s.active, isTrue);
      expect(s.remainingFiles, 1);
      s.beginFile(alreadyApproved: true);
      s.updateProgress(
        const TransferProgress(
          id: 'private-token',
          name: 'empty.bin',
          total: 0,
          bytes: 0,
          incoming: true,
        ),
      );
      expect(s.completeFile(), isNotNull);
      expect(s.remainingFiles, 0);
      s.completeFile();
      expect(s.remainingFiles, 0);
      await s.finish(SessionPhase.completed, () async {});
      expect(s.active, isFalse);
      s.updateProgress(
        const TransferProgress(
          id: 'late',
          name: 'old.bin',
          total: 3,
          bytes: 1,
          incoming: true,
        ),
      );
      expect(s.phase, SessionPhase.completed);
      expect(s.progress, isNull);
    },
  );
  test('cancel and duplicate finishes release resources once and stay busy until release', () async {
    final s = TransferSession.outgoing(peerName: 'Peer');
    final release = Completer<void>();
    var calls = 0;
    s.cancel();
    final first = s.finish(SessionPhase.cancelled, () {
      calls++;
      return release.future;
    });
    final second = s.finish(SessionPhase.failed, () async {
      calls++;
    });
    expect(identical(first, second), isTrue);
    expect(s.active, isTrue);
    expect(s.cancellation.isCancelled, isTrue);
    release.complete();
    await first;
    expect(calls, 1);
    expect(s.phase, SessionPhase.cancelled);
    expect(s.active, isFalse);
  });
  test('a failed cleanup still settles state and does not allow repeated acquisition', () async {
    final s = TransferSession.outgoing(peerName: 'Peer');
    await expectLater(
      s.finish(SessionPhase.failed, () async => throw StateError('cleanup')),
      throwsStateError,
    );
    expect(s.phase, SessionPhase.failed);
    expect(s.active, isFalse);
  });
  test(
    'cancel during resource start waits for that start before releasing once',
    () async {
      final s = TransferSession.outgoing(peerName: 'Peer');
      final nativeStart = Completer<void>();
      late Future<void> finishing;
      var stops = 0;
      final acquiring = s.acquire(() {
        s.cancel();
        finishing = s.finish(SessionPhase.cancelled, () async {
          stops++;
        });
        return nativeStart.future;
      });
      await Future<void>.delayed(Duration.zero);
      expect(stops, 0);
      expect(s.active, isTrue);
      nativeStart.complete();
      await acquiring;
      await finishing;
      expect(stops, 1);
      expect(s.active, isFalse);
      await expectLater(
        s.acquire(() async {
          fail('must not reacquire');
        }),
        throwsA(isA<TransferCancelled>()),
      );
    },
  );
}
