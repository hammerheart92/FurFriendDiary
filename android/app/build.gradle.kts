import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties with fail-fast behavior for release builds
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
// Detect if any requested task is a release task (assembleRelease, bundleRelease, etc.)
val isReleaseTaskRequested = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }

if (!keystorePropertiesFile.exists()) {
    if (isReleaseTaskRequested) {
        throw GradleException(
            "Missing key.properties required for release signing. " +
            "Create android/key.properties (or project root key.properties depending on your setup) with: " +
            "keyAlias, keyPassword, storeFile, storePassword; or configure signing another way."
        )
    } else {
        logger.lifecycle("key.properties not found; skipping release signing configuration for debug/non-release tasks.")
    }
} else {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.furfrienddiary.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.furfrienddiary.app"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                // Safely retrieve properties with validation
                val keyAlias = keystoreProperties["keyAlias"]?.toString()
                val keyPassword = keystoreProperties["keyPassword"]?.toString()
                val storeFilePath = keystoreProperties["storeFile"]?.toString()
                val storePassword = keystoreProperties["storePassword"]?.toString()

                // Validate required properties exist
                requireNotNull(keyAlias) { "Missing 'keyAlias' in key.properties" }
                requireNotNull(keyPassword) { "Missing 'keyPassword' in key.properties" }
                requireNotNull(storeFilePath) { "Missing 'storeFile' in key.properties" }
                requireNotNull(storePassword) { "Missing 'storePassword' in key.properties" }

                // Assign validated values
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
                this.storeFile = file(storeFilePath)
                this.storePassword = storePassword
            }
        }
    }


    buildTypes {
        release {
            // Prevent debugging tools from attaching to release builds
            isDebuggable = false

            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Explicitly skip signing when no keystore is present (debug/non-release tasks)
                // If a release task is actually requested, we already failed fast above.
            }

            // Enable ProGuard for release builds
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}


