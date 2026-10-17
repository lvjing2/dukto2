pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val localProperties = file("local.properties")
            localProperties.reader(Charsets.UTF_8).use { properties.load(it) }
            // Java Properties consumers use ISO-8859-1. Escape non-ASCII SDK paths
            // so builds also work from directories such as this workspace's Chinese name.
            localProperties.outputStream().use { properties.store(it, null) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    // Pass the decoded path directly; the upstream loader otherwise reads it
    // again with InputStream's legacy encoding.
    settings.extra.set("flutterSdkPath", flutterSdkPath)
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
