plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

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

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.dukto2.dukto2"
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
