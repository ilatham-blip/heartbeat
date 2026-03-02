// Top-level build file for the Android part of the Flutter project.
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://codeberg.org/api/packages/MavenPLUX/maven") }
    }
}
plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}