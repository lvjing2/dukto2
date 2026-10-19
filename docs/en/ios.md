# iPhone and iPad

English | [简体中文](../ios.md)

The project targets iOS / iPadOS 15 or newer, with one app for iPhone and iPad. Selected scenarios are tested on iOS 27.0 simulators and physical iPadOS 26.6; physical iPhone, minimum OS and background behavior need separate tests. See [coverage](validation.md).

## Build and sign

Use macOS, full Xcode and Flutter 3.47.7 stable.

```sh
./tool/flutterw pub get
./tool/flutterw build ios --simulator --debug
# Check device architecture without an installable signed IPA:
./tool/flutterw build ios --no-codesign --release
```

Physical-device debugging needs your own Apple team / signing, computer trust and Developer Mode. Put local team configuration in ignored `ios/Flutter/LocalSigning.xcconfig`:

```xcconfig
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

Personal signing material is not committed. Unsigned CI device apps cannot be installed directly; see [Release CI](release-ci.md).

## Discovery and device names

Apple platforms publish / browse `_dukto2._tcp` through Bonjour; candidates still require HTTPS identity confirmation. iOS does not request restricted custom multicast entitlements. Private IPv4 probing, UDP unicast and manual connections remain available. Network isolation and VPNs may affect discovery and connections.

From iOS 16, hardware typically returns iPhone / iPad without Apple's special custom-name entitlement. Simulator names do not prove access to user-defined hardware names. System interface idiom selects phone or tablet icons.

## Files and background

The default is Files → On My iPhone / iPad → Dukto2 → 接收文件 (Received files). Settings can select another folder and remember security-scoped access. The system picker chooses sending sources; system share sheets open or export received files, with a popover anchor on iPad.

Native writes use at most 256 KiB and await acknowledgement. Private staging is copied to an isolated target using file coordination, then length and SHA-256 are rechecked before publishing. Extra disk space is required; external-provider availability depends on that provider.

Startup discards uncommitted targets and preserves published files. History uses app-generated opaque IDs instead of assuming an old sandbox's absolute path stays valid.

Transfers mainly run in the foreground. Background operation requests only the system's limited grace period; expiry stops the transfer and asks for a new send. Completion notifications require permission. Indefinite screen-off transfer, automatic background acceptance and resumption after process death are not provided.
