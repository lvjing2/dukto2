plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val backgroundPreview = System.getenv("DUKTO2_BACKGROUND_PREVIEW") == "true"
val privacyPreview = System.getenv("DUKTO2_PRIVACY_PREVIEW") == "true"
require(!(backgroundPreview && privacyPreview)) { "Choose only one isolated preview" }

val signedRelease = System.getenv("DUKTO2_ANDROID_SIGNED") == "true"
val unsignedRelease = System.getenv("DUKTO2_ANDROID_UNSIGNED") == "true"
require(!(signedRelease && unsignedRelease)) { "Conflicting Android signing modes" }
fun signingValue(name: String): String =
    requireNotNull(System.getenv(name)?.takeIf { it.isNotBlank() }) {
        "Missing Android signing setting: $name"
    }

android {
    namespace = "dev.dukto2.dukto2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = when {
            privacyPreview -> "dev.dukto2.privacyvalidation"
            backgroundPreview -> "dev.dukto2.bgvalidation"
            else -> "dev.dukto2.dukto2"
        }
        manifestPlaceholders["dukto2Label"] = when {
            privacyPreview -> "Dukto2 隐私验证"
            backgroundPreview -> "Dukto2 后台预览"
            else -> "Dukto2"
        }
        testInstrumentationRunner = "dev.dukto2.dukto2.PrivacyDeviceInstrumentation"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // GitHub ships a universal APK, not ABI splits, so it shares this version
        // code with the Play AAB and can be updated across the two channels.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signedRelease) {
            create("dukto2Release") {
                storeFile = file(signingValue("DUKTO2_ANDROID_STORE_FILE"))
                storeType = "PKCS12"
                storePassword = signingValue("DUKTO2_ANDROID_STORE_PASSWORD")
                keyAlias = signingValue("DUKTO2_ANDROID_KEY_ALIAS")
                keyPassword = signingValue("DUKTO2_ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                signedRelease -> signingConfigs.getByName("dukto2Release")
                unsignedRelease -> null
                else -> signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Explicit public API for consent-delayed initialization; same version as
    // the bundled barcode scanner's resolved ML Kit dependency.
    implementation("com.google.mlkit:common:18.11.0")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.robolectric:robolectric:4.16.1")
}

// Flutter adds its assets after AGP's host-test task is configured. Gradle 9
// requires the real producer dependency before packaging Robolectric resources.
tasks.configureEach {
    Regex("package(.+)UnitTestForUnitTest").matchEntire(name)?.let { task ->
        dependsOn("copyFlutterAssets${task.groupValues[1]}")
    }
}
