pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val path = properties.getProperty("flutter.sdk")
        require(!path.isNullOrBlank()) { "flutter.sdk not set in local.properties" }
        path
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        // ✅ REQUIRED for io.flutter:* artifacts (engine + embedding)
        maven(url = uri("https://storage.googleapis.com/download.flutter.io"))

        google()
        mavenCentral()

        // PLUX Maven repository
        maven(url = uri("https://codeberg.org/api/packages/MavenPLUX/maven"))
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

rootProject.name = "01_app"
include(":app")