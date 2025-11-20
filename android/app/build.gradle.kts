import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.financeo.financeo"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    defaultConfig {
        applicationId = "com.financeo.financeo"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        
        // Lê as propriedades do local.properties para obter versionCode e versionName
        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localProperties.load(FileInputStream(localPropertiesFile))
        }
        
        // Define versionCode e versionName a partir do local.properties ou usa valores padrão
        versionCode = (localProperties.getProperty("flutter.versionCode") ?: "1").toInt()
        versionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"
    }

    // Carrega as propriedades da keystore se o arquivo existir
    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Ativa minificação e ofuscação para reduzir tamanho e proteger código
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Fallback para debug se key.properties não existir
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Google Play Core (necessário para Flutter deferred components)
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")
}

// Tarefa para copiar o APK para o local esperado pelo Flutter
afterEvaluate {
    tasks.named("assembleDebug") {
        doLast {
            val gradleApkPath = file("build/outputs/flutter-apk/app-debug.apk")
            val flutterApkPath = file("../../build/app/outputs/flutter-apk/app-debug.apk")
            
            if (gradleApkPath.exists()) {
                flutterApkPath.parentFile.mkdirs()
                gradleApkPath.copyTo(flutterApkPath, overwrite = true)
                println("APK copiado para: ${flutterApkPath.absolutePath}")
            }
        }
    }
    
    tasks.named("assembleRelease") {
        doLast {
            val gradleApkPath = file("build/outputs/flutter-apk/app-release.apk")
            val flutterApkPath = file("../../build/app/outputs/flutter-apk/app-release.apk")
            
            if (gradleApkPath.exists()) {
                flutterApkPath.parentFile.mkdirs()
                gradleApkPath.copyTo(flutterApkPath, overwrite = true)
                println("APK Release copiado para: ${flutterApkPath.absolutePath}")
            }
        }
    }
    
    // Tarefa para copiar o App Bundle para o local esperado pelo Flutter
    tasks.named("bundleRelease") {
        doLast {
            val gradleBundlePath = file("build/outputs/bundle/release/app-release.aab")
            val flutterBundlePath = file("../../build/app/outputs/bundle/release/app-release.aab")
            
            if (gradleBundlePath.exists()) {
                flutterBundlePath.parentFile.mkdirs()
                gradleBundlePath.copyTo(flutterBundlePath, overwrite = true)
                println("App Bundle copiado para: ${flutterBundlePath.absolutePath}")
            }
        }
    }
}
