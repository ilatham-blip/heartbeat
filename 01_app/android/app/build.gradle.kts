plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.heartbeat"
    compileSdk = flutter.compileSdkVersion

    buildFeatures {
        buildConfig = true
    }
    defaultConfig {
        applicationId = "com.example.heartbeat"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("info.plux.api:api:1.5.2")
}


// --- Flutter APK output compatibility (fixes "couldn't find .apk") ---
// Copies: android/app/build/outputs/apk/debug/app-debug.apk
// To:     <project>/build/app/outputs/flutter-apk/app-debug.apk

val copyDebugApkForFlutter by tasks.registering(org.gradle.api.tasks.Copy::class) {
    val fromApk = layout.buildDirectory.file("outputs/apk/debug/app-debug.apk")
    val toDir = rootProject.projectDir.parentFile.resolve("build/app/outputs/flutter-apk")

    from(fromApk)
    into(toDir)
    rename { "app-debug.apk" }
}

afterEvaluate {
    // Only hook it up if the task exists (prevents "Task not found" crashes)
    tasks.findByName("assembleDebug")?.finalizedBy(copyDebugApkForFlutter)
    // Some setups name tasks differently; these are harmless if they don't exist
    tasks.findByName("assembleDevDebug")?.finalizedBy(copyDebugApkForFlutter)
    tasks.findByName("assembleProfileDebug")?.finalizedBy(copyDebugApkForFlutter)
}