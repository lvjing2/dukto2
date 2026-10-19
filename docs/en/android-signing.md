# Android signing for two distribution channels

English | [Simplified Chinese](../android-signing.md)

Google Play uses an upload-key-signed AAB; GitHub uses a universal APK signed with the application key. **When first enabling Play App Signing, import the existing project application key rather than asking Google to generate a different key.** Matching application identities are required for updates across channels. See [Android signing](https://developer.android.com/studio/publish/app-signing) and the [cross-store FAQ](https://developer.android.com/guide/app-bundle/faq).

## Signing material

- Application ID: `dev.dukto2.dukto2`. Confirm availability when registering the Play app; signing certificates do not reserve an application ID.
- Separate RSA-4096 application and upload keys, with certificates valid for 10,000 days.
- The repository contains only the [application public certificate](../../certificates/android/app-signing.pem), [upload public certificate](../../certificates/android/upload-signing.pem) and [fingerprints](../../tool/ci/android-signing.json), not private keys or passwords.
- GitHub Secrets stores the two private keystores separately. Gradle receives only the role-specific parameters for the current build; temporary material is cleaned up afterward.

| Purpose | Certificate SHA-256, ignoring case and colons |
| --- | --- |
| Play application signing / GitHub APK | `4f0c7dab4b81912270656b3e7c0c5cdcd11702fb2b16eca6b6b89f4aad207823` |
| Play AAB upload | `c2576e3d890f4a0c08dfcf03bae7540c77de120f2704bdf5bcc8e4f8eb2aab28` |

Both `ANDROID_APP_` and `ANDROID_UPLOAD_` secret groups contain `KEYSTORE_BASE64`, `STORE_PASSWORD`, `KEY_ALIAS` and `KEY_PASSWORD`. Missing values fail the build, with no debug-key or unsigned-release fallback.

## Local originals and backup

Private originals are under `~/Library/Application Support/Dukto2/AndroidSigning/`, accessible only to the current user. Each PKCS#12 keystore has a separate random password. Keystore and backup passwords are in the macOS login keychain item **Dukto2 Android release signing**, service `dev.dukto2.android.release`, account `lvjing2`. Use Keychain Access to unlock it. Its JSON contains `app`, `upload` and `backupPassword`; do not copy these values to issues, chat or logs.

AES-256 encrypted DMG backups are under `~/Dukto2-Key-Backups/`. Creation was followed by read-only decryption and comparison of both keystores and password records. This is a local backup on the same Mac; maintainers still need an offline copy and separately stored recovery password. Losing both the Mac and login keychain cannot be recovered with the encrypted image alone. Do not regenerate published app keys to fix a build problem.

## Initial Google Play setup

1. Create Dukto2 in Play Console, with the first AAB application ID `dev.dukto2.dukto2`.
2. Choose to use / import an existing application key in Play App Signing. Follow Console's Google PEPK tool and encryption-key instructions to export and upload an encrypted package of `dukto2-app-signing.p12`, alias `dukto2-app`. A public PEM certificate does not replace importing the private key.
3. Use the separate `dukto2-upload-signing.p12`, alias `dukto2-upload`, for uploads. Register `upload-signing.pem` when an upload certificate is requested.
4. Match Console's application and upload certificate SHA-256 to the corresponding entries above; do not swap their roles.
5. Manually upload CI's `*-android-play.aab` to a test track, complete required app / release setup, then test real Play ↔ GitHub installation upgrades.

Keys and CI preparation do not mean the Play app, PEPK import or automatic Play-upload account has been configured. Build reports retain `playAppSigningKeyImportRequired: true` until that setup is actually complete.

## CI checks and versions

Actions → Release builds → Run workflow can select `android` only; `all` or version tags build all five platforms. Signing accepts only `main` or a matching `v*` release tag.

CI produces an installable universal `.apk`, a Play-upload `.aab`, and a notices zip with licenses, public certificates and reports, each with SHA-256. The universal APK supports ARMv7, ARM64 and x86_64 without Flutter split-ABI version offsets.

Both packages use `pubspec.yaml`'s version name and build suffix. For `0.1.6+7`, both versionCodes are **7**; raise both to **8** or higher for the next release. Do not keep separate channel version sequences. Equal versions usually do not trigger a Play update prompt; later higher versions should update from either channel. See [Android versioning](https://developer.android.com/studio/publish/versioning).

Checks cover APK signing, AAB JAR signature / structure, pinned application ID, version and certificates. Digest-verified Google bundletool derives an application-key-signed universal APK from the AAB and compares its update identity with the GitHub APK. Debug keys, upload-key APK signing, ABI version offsets or modified signed files prevent packaging. Reports omit private keys, passwords and keystore paths.

Local derivation is not a substitute for real validation after Play key import. Future Play application-key upgrades require a corresponding GitHub signing / rotation plan. Existing debug packages use a different identity and cannot serve as an upgrade baseline for the release channels. Testing must not automatically uninstall apps or delete user data.

## Verified CI record

On 2026-10-19, the [Android signed build](https://github.com/lvjing2/dukto2/actions/runs/39201426782) passed at commit `f6bdcca`: 69 application tests, 46 core tests, 11 build-tool tests, static analysis, formatting, native APK/AAB builds and cross-channel update-identity checks. The artifacts are `0.1.6+7`; both APK and AAB use versionCode `7`.

This verifies builds and the signing identity of a locally derived APK. The Google Play app has not been created; PEPK key import and real Play ↔ GitHub upgrade tests remain pending.
