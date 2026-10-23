# Android background reception: assessment

English | [Simplified Chinese](../android-background-receive.md)

Pre-implementation assessment dated 2026-10-23, retained as design context. Integration into main is now approved, off by default; see [behavior and validation](../android-background-receive-option.md) for implementation and actual coverage. Battery testing was stopped at the owner's request; manufacturer freezing remains a limitation.

**A user-started, time-limited receive window with notifications is conditionally feasible. It cannot guarantee immediate reception before launch, after force-stop or during deep sleep.**

## Proposed behavior

- Off by default. Start from the visible app, initially for 30 minutes, with a quiet status notification, countdown and stop action. Do not automatically restart after reboot or process death.
- Incoming requests get a separate notification. Tapping opens the original manifest; explicit approval still precedes upload. No direct accept button, filenames or text on the lock screen. Names are untrusted; rate-limit and coalesce alerts.
- Expiry stops new background offers without interrupting an approved transfer. Disabling waiting preserves normal foreground reception.
- Require notifications and the request channel to be enabled. This is a product prerequisite, not an Android requirement to start every foreground service.

## Design constraints

`connectedDevice` is a candidate for network-device interaction; the existing multicast permission satisfies one launch prerequisite, not proof of approval for arbitrary idle listening. Validate the concrete use case and declare it for future Play review. Keep `dataSync` for actual transfers, not indefinite waiting; newer targets have a daily background runtime budget.

The service does not own the Dart listener today. `MainActivity.onDestroy` stops the service and releases discovery/storage resources. A service-owned runtime/FlutterEngine with an attached UI must preserve one server/session through Activity recreation. Changing the Manifest alone is insufficient.

Use a dedicated request channel and immutable Activity PendingIntent carrying a local request identifier, never an authorization token. Revalidate on tap and withdraw notifications on cancellation, rejection, timeout or shutdown. Reuse the existing five-minute approval window and exact manifests; expired grants cannot be restored. Offline queues are outside this proposal.

Do not hold transfer CPU/high-performance Wi-Fi locks throughout idle waiting or repeatedly scan subnets. Measure reachability and power use without long-held locks first. Foreground service presence does not guarantee networking during Doze. Existing HyperOS freezing remains a documented limitation under [issue #2](https://github.com/lvjing2/dukto2/issues/2), with no planned bypass. Stop on user/system termination or task removal; never silently relaunch.

The current toolchain targets SDK 36. Local-network permission adoption belongs to a future target-37 update, not this feature at target 36.

## Gates before implementation rollout

1. Verify Home, Activity recreation and UI reattachment preserve one runtime; stopping releases sockets and resources.
2. Test denied/disabled notifications, lock-screen taps, stale notifications, repeated offers and cancellation without accidental approval. Retain foreground and batch behavior.
3. Cover Android 13, 14, 15+ and the existing HyperOS device: screen on/off, natural/forced Doze, expiry, network switches and system stop. Record unreachable states rather than claiming reliable delivery.
4. Compare 30-minute idle power, CPU, traffic and lock usage. Do not enable broadly if acceptable reliability requires aggressive keepalive.

Notification work is smaller than runtime lifecycle changes. An isolated validation should precede exposing the option. This assessment does not establish hardware reliability or Play acceptance.

References: [service types](https://developer.android.com/develop/background-work/services/fgs/service-types), [timeouts](https://developer.android.com/develop/background-work/services/fgs/timeout), [background starts](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start), [notification permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission), [Doze](https://developer.android.com/training/monitoring-device-state/doze-standby), [Play declarations](https://support.google.com/googleplay/android-developer/answer/13392821?hl=en), [local-network permission](https://developer.android.com/privacy-and-security/local-network-permission).
