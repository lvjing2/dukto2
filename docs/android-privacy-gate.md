# Android privacy startup

Huawei's 2026-11-17 review of 0.1.7 reported no first-use notice,
undisclosed accelerometer access, and camera/sensor use before agreement.
The scanner's `DeviceOrientationListener` uses `OrientationEventListener`
as a rotation fallback. The merged APK also had an ML Kit startup provider.

The Android launcher is now a native `PrivacyActivity`. It shows a localized
summary, an external policy link, and separate agree/exit actions before
creating Flutter or registering plugins.
The notice is a centered modal over a native, presentation-only home surface.
The background uses the same localized home labels, but does not load saved
devices/history or start Flutter. Only the summary scrolls; policy and decision
buttons remain outside that scroll area. Background elements are hidden from
accessibility navigation and blocked by a scrim. The acceptance is saved synchronously
with a policy revision; a missing or older revision requires a new choice.
Reading the policy does not count as agreement. Refusal exits without saving
agreement. No transfer/discovery operation is started by this activity.

The ML Kit automatic provider is removed during manifest merging. Its public
manual initializer runs only after `PrivacyConsent` has been checked in
`DuktoRuntime.engine`. The Flutter activity is not exported. Existing internal
notification intents continue to use that activity after agreement.

The first-use notice has ten Android translations generated from the ARB
catalogs by `tool/sync_native_localizations.py`. The linked policy currently
has Chinese content. Its public alias is unchanged at the owner's request.

## Verification

Run `tool/check.sh` for the application/core checks. With the configured
Android SDK, run from `android/`:

```
./gradlew :app:testDebugUnitTest --tests dev.dukto2.dukto2.PrivacyActivityTest
```

The native tests cover the actual launcher, first use without runtime/ML Kit,
policy reading, refusal/relaunch, explicit agreement/persistence, and an older
policy revision. These are host tests, not a real-device privacy audit.

For an isolated device smoke test, build with `DUKTO2_PRIVACY_PREVIEW=true`.
This selects `dev.dukto2.privacyvalidation` and the label “Dukto2 隐私验证”;
the production package and its data stay separate. Build the debug APK and
`:app:assembleDebugAndroidTest`, install both on the test device, then run
`adb shell am instrument -w dev.dukto2.privacyvalidation.test/dev.dukto2.dukto2.PrivacyDeviceInstrumentation`.
The device runner refuses to run against the production package or an already
accepted validation install. It covers the native notice, rejection/relaunch,
durable agreement and actual Flutter runtime startup. Scanner permissions,
rotation and transfers require separate device checks.

Before resubmission, inspect the final signed APK's merged manifest and verify
on an isolated Android install: first launch, back/refusal, policy-link return,
agreement and restart, camera denial, scanning and rotation, transfer, optional
background reception, and upgrade from the existing production signature.
Do not clear or uninstall a user's production app to run these checks.

Huawei also rejected a mismatch between the public policy's developer name
and the account's certified identity. The owner has not authorized publishing
the legal name; that review item remains unresolved. Do not claim the build
or application is approved, or resubmit it as fully corrected.

References: [ML Kit manual initialization](https://developers.google.com/android/reference/com/google/mlkit/common/MlKit),
[Huawei review guide](https://developer.huawei.com/consumer/cn/doc/doccenter-submission/50104#section599875815368).
